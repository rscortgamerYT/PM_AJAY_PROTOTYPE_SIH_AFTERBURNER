-- Function to find nearby agencies
CREATE OR REPLACE FUNCTION find_nearby_agencies(
    target_longitude double precision,
    target_latitude double precision,
    radius_meters double precision,
    agency_type_filter text DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    name text,
    type text,
    state_id uuid,
    district_id uuid,
    location geometry,
    coverage_area geometry,
    address text,
    contact_person text,
    phone text,
    email text,
    capacity_score numeric,
    performance_rating numeric,
    is_active boolean,
    metadata jsonb,
    created_at timestamptz,
    updated_at timestamptz,
    distance_meters double precision
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.*,
        ST_Distance(
            a.location::geography,
            ST_SetSRID(ST_MakePoint(target_longitude, target_latitude), 4326)::geography
        ) as distance_meters
    FROM agencies a
    WHERE ST_DWithin(
        a.location::geography,
        ST_SetSRID(ST_MakePoint(target_longitude, target_latitude), 4326)::geography,
        radius_meters
    )
    AND (agency_type_filter IS NULL OR a.type::text = agency_type_filter)
    AND a.is_active = true
    ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql;

-- Function to find nearby projects
CREATE OR REPLACE FUNCTION find_nearby_projects(
    target_longitude double precision,
    target_latitude double precision,
    radius_meters double precision,
    status_filter text DEFAULT NULL,
    component_filter text DEFAULT NULL
)
RETURNS TABLE (
    id uuid,
    name text,
    description text,
    agency_id uuid,
    state_id uuid,
    district_id uuid,
    location geometry,
    project_area geometry,
    status text,
    component text,
    total_budget numeric,
    allocated_budget numeric,
    utilized_budget numeric,
    start_date date,
    end_date date,
    completion_percentage numeric,
    beneficiaries_count integer,
    metadata jsonb,
    created_at timestamptz,
    updated_at timestamptz,
    distance_meters double precision
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.*,
        ST_Distance(
            p.location::geography,
            ST_SetSRID(ST_MakePoint(target_longitude, target_latitude), 4326)::geography
        ) as distance_meters
    FROM projects p
    WHERE p.location IS NOT NULL
    AND ST_DWithin(
        p.location::geography,
        ST_SetSRID(ST_MakePoint(target_longitude, target_latitude), 4326)::geography,
        radius_meters
    )
    AND (status_filter IS NULL OR p.status::text = status_filter)
    AND (component_filter IS NULL OR p.component::text = component_filter)
    ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql;

-- Function to find projects within a polygon
CREATE OR REPLACE FUNCTION find_projects_in_polygon(
    polygon_coords jsonb
)
RETURNS SETOF projects AS $$
DECLARE
    polygon_geom geometry;
BEGIN
    -- Convert JSON coordinates to PostGIS polygon
    polygon_geom := ST_SetSRID(
        ST_GeomFromGeoJSON(
            json_build_object(
                'type', 'Polygon',
                'coordinates', array[polygon_coords]
            )::text
        ),
        4326
    );
    
    RETURN QUERY
    SELECT p.*
    FROM projects p
    WHERE p.location IS NOT NULL
    AND ST_Within(p.location, polygon_geom);
END;
$$ LANGUAGE plpgsql;

-- Function to calculate distance between two points
CREATE OR REPLACE FUNCTION calculate_distance(
    from_longitude double precision,
    from_latitude double precision,
    to_longitude double precision,
    to_latitude double precision
)
RETURNS double precision AS $$
BEGIN
    RETURN ST_Distance(
        ST_SetSRID(ST_MakePoint(from_longitude, from_latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(to_longitude, to_latitude), 4326)::geography
    );
END;
$$ LANGUAGE plpgsql;

-- Function to check if point is in coverage area
CREATE OR REPLACE FUNCTION is_point_in_coverage(
    agency_uuid uuid,
    point_longitude double precision,
    point_latitude double precision
)
RETURNS boolean AS $$
DECLARE
    coverage geometry;
BEGIN
    SELECT coverage_area INTO coverage
    FROM agencies
    WHERE id = agency_uuid;
    
    IF coverage IS NULL THEN
        RETURN false;
    END IF;
    
    RETURN ST_Within(
        ST_SetSRID(ST_MakePoint(point_longitude, point_latitude), 4326),
        coverage
    );
END;
$$ LANGUAGE plpgsql;

-- Function to find overlapping agencies
CREATE OR REPLACE FUNCTION find_overlapping_agencies(
    polygon_coords jsonb
)
RETURNS SETOF agencies AS $$
DECLARE
    polygon_geom geometry;
BEGIN
    polygon_geom := ST_SetSRID(
        ST_GeomFromGeoJSON(
            json_build_object(
                'type', 'Polygon',
                'coordinates', array[polygon_coords]
            )::text
        ),
        4326
    );
    
    RETURN QUERY
    SELECT a.*
    FROM agencies a
    WHERE a.coverage_area IS NOT NULL
    AND ST_Intersects(a.coverage_area, polygon_geom);
END;
$$ LANGUAGE plpgsql;

-- Function to find projects along a route
CREATE OR REPLACE FUNCTION find_projects_along_route(
    route_coords jsonb,
    buffer_meters double precision
)
RETURNS SETOF projects AS $$
DECLARE
    route_geom geometry;
    buffered_route geography;
BEGIN
    route_geom := ST_SetSRID(
        ST_GeomFromGeoJSON(
            json_build_object(
                'type', 'LineString',
                'coordinates', route_coords
            )::text
        ),
        4326
    );
    
    buffered_route := ST_Buffer(route_geom::geography, buffer_meters);
    
    RETURN QUERY
    SELECT p.*
    FROM projects p
    WHERE p.location IS NOT NULL
    AND ST_DWithin(p.location::geography, route_geom::geography, buffer_meters);
END;
$$ LANGUAGE plpgsql;

-- Function to get district at a point
CREATE OR REPLACE FUNCTION get_district_at_point(
    point_longitude double precision,
    point_latitude double precision
)
RETURNS TABLE (
    id uuid,
    state_id uuid,
    name text,
    code text,
    headquarters text,
    population bigint,
    area_sq_km numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id,
        d.state_id,
        d.name,
        d.code,
        d.headquarters,
        d.population,
        d.area_sq_km
    FROM districts d
    WHERE ST_Within(
        ST_SetSRID(ST_MakePoint(point_longitude, point_latitude), 4326),
        d.boundary
    )
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate district coverage
CREATE OR REPLACE FUNCTION calculate_district_coverage(
    district_uuid uuid
)
RETURNS double precision AS $$
DECLARE
    district_area double precision;
    covered_area double precision;
BEGIN
    SELECT ST_Area(boundary::geography) INTO district_area
    FROM districts
    WHERE id = district_uuid;
    
    IF district_area IS NULL OR district_area = 0 THEN
        RETURN 0;
    END IF;
    
    SELECT SUM(ST_Area(project_area::geography)) INTO covered_area
    FROM projects
    WHERE district_id = district_uuid
    AND project_area IS NOT NULL;
    
    IF covered_area IS NULL THEN
        RETURN 0;
    END IF;
    
    RETURN (covered_area / district_area) * 100;
END;
$$ LANGUAGE plpgsql;

-- Create spatial indexes if not already created
CREATE INDEX IF NOT EXISTS idx_agencies_location_geography ON agencies USING GIST (location::geography);
CREATE INDEX IF NOT EXISTS idx_projects_location_geography ON projects USING GIST (location::geography);

-- Create materialized view for agency performance analytics
CREATE MATERIALIZED VIEW IF NOT EXISTS agency_performance_summary AS
SELECT 
    a.id as agency_id,
    a.name as agency_name,
    a.type as agency_type,
    a.state_id,
    COUNT(DISTINCT p.id) as total_projects,
    COUNT(DISTINCT CASE WHEN p.status = 'completed' THEN p.id END) as completed_projects,
    COALESCE(AVG(p.completion_percentage), 0) as avg_completion_percentage,
    COALESCE(SUM(p.allocated_budget), 0) as total_allocated_budget,
    COALESCE(SUM(p.utilized_budget), 0) as total_utilized_budget,
    COALESCE(SUM(p.beneficiaries_count), 0) as total_beneficiaries,
    a.capacity_score,
    a.performance_rating,
    a.location
FROM agencies a
LEFT JOIN projects p ON p.agency_id = a.id
WHERE a.is_active = true
GROUP BY a.id, a.name, a.type, a.state_id, a.capacity_score, a.performance_rating, a.location;

CREATE INDEX IF NOT EXISTS idx_agency_performance_summary_location 
ON agency_performance_summary USING GIST (location);

-- Refresh materialized view function
CREATE OR REPLACE FUNCTION refresh_agency_performance_summary()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY agency_performance_summary;
END;
$$ LANGUAGE plpgsql;