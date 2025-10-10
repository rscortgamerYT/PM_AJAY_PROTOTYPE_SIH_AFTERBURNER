-- Enable PostGIS extension for spatial data
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE user_role AS ENUM ('centre_admin', 'state_officer', 'agency_user', 'overwatch', 'public');
CREATE TYPE project_status AS ENUM ('planning', 'in_progress', 'review', 'completed', 'on_hold', 'cancelled');
CREATE TYPE fund_status AS ENUM ('allocated', 'transferred', 'utilized', 'pending_uc', 'completed');
CREATE TYPE milestone_status AS ENUM ('pending', 'submitted', 'under_review', 'approved', 'rejected');
CREATE TYPE agency_type AS ENUM ('implementing_agency', 'nodal_agency', 'technical_agency', 'monitoring_agency');

-- Users table with role-based access
CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    email text UNIQUE NOT NULL,
    role user_role NOT NULL,
    full_name text NOT NULL,
    phone text,
    state_id uuid,
    district_id uuid,
    agency_id uuid,
    location geometry(Point, 4326),
    is_active boolean DEFAULT true,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- States table
CREATE TABLE states (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    code text UNIQUE NOT NULL,
    boundary geometry(MultiPolygon, 4326),
    capital text,
    population bigint,
    area_sq_km numeric,
    created_at timestamptz DEFAULT now()
);

-- Districts table
CREATE TABLE districts (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    state_id uuid REFERENCES states(id) ON DELETE CASCADE,
    name text NOT NULL,
    code text NOT NULL,
    boundary geometry(MultiPolygon, 4326),
    headquarters text,
    population bigint,
    area_sq_km numeric,
    created_at timestamptz DEFAULT now(),
    UNIQUE(state_id, code)
);

-- Agencies table with spatial data
CREATE TABLE agencies (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    type agency_type NOT NULL,
    state_id uuid REFERENCES states(id),
    district_id uuid REFERENCES districts(id),
    location geometry(Point, 4326) NOT NULL,
    coverage_area geometry(Polygon, 4326),
    address text,
    contact_person text,
    phone text,
    email text,
    capacity_score numeric(3,2) DEFAULT 0.00,
    performance_rating numeric(3,2) DEFAULT 0.00,
    is_active boolean DEFAULT true,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Projects table
CREATE TABLE projects (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    description text,
    agency_id uuid REFERENCES agencies(id),
    state_id uuid REFERENCES states(id),
    district_id uuid REFERENCES districts(id),
    location geometry(Point, 4326),
    project_area geometry(Polygon, 4326),
    status project_status DEFAULT 'planning',
    component text NOT NULL, -- 'adarsh_gram', 'gia', 'hostel', 'admin'
    total_budget numeric(15,2),
    allocated_budget numeric(15,2),
    utilized_budget numeric(15,2),
    start_date date,
    end_date date,
    completion_percentage numeric(5,2) DEFAULT 0.00,
    beneficiaries_count integer DEFAULT 0,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Milestones table
CREATE TABLE milestones (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    name text NOT NULL,
    description text,
    status milestone_status DEFAULT 'pending',
    due_date date,
    completion_date date,
    budget_allocation numeric(15,2),
    evidence_urls text[],
    location geometry(Point, 4326),
    submitted_by uuid REFERENCES users(id),
    reviewed_by uuid REFERENCES users(id),
    review_comments text,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Fund Flow table for tracking financial transactions
CREATE TABLE fund_flow (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id text UNIQUE NOT NULL,
    from_entity_type text NOT NULL, -- 'centre', 'state', 'agency'
    from_entity_id uuid,
    to_entity_type text NOT NULL,
    to_entity_id uuid,
    project_id uuid REFERENCES projects(id),
    component text NOT NULL,
    amount numeric(15,2) NOT NULL,
    status fund_status DEFAULT 'allocated',
    transaction_date timestamptz DEFAULT now(),
    uc_date timestamptz,
    remarks text,
    pfms_reference text,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now()
);

-- Audit Trail table with blockchain-inspired structure
CREATE TABLE audit_trail (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    previous_hash text,
    current_hash text GENERATED ALWAYS AS (
        encode(sha256(
            (id || user_id || action || timestamp || data)::bytea
        ), 'hex')
    ) STORED,
    user_id uuid REFERENCES users(id),
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    action text NOT NULL,
    data jsonb NOT NULL,
    ip_address inet,
    user_agent text,
    timestamp timestamptz DEFAULT now()
);

-- Chat Channels table
CREATE TABLE chat_channels (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    type text NOT NULL, -- 'direct', 'group', 'role_based'
    participants uuid[],
    metadata jsonb DEFAULT '{}',
    created_by uuid REFERENCES users(id),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Chat Messages table
CREATE TABLE chat_messages (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    channel_id uuid REFERENCES chat_channels(id) ON DELETE CASCADE,
    sender_id uuid REFERENCES users(id),
    message text NOT NULL,
    message_type text DEFAULT 'text', -- 'text', 'file', 'image', 'location'
    attachments jsonb DEFAULT '[]',
    reply_to uuid REFERENCES chat_messages(id),
    is_edited boolean DEFAULT false,
    is_deleted boolean DEFAULT false,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Tickets table for issue management
CREATE TABLE tickets (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title text NOT NULL,
    description text,
    priority text DEFAULT 'medium', -- 'low', 'medium', 'high', 'critical'
    status text DEFAULT 'open', -- 'open', 'in_progress', 'resolved', 'closed'
    category text,
    created_by uuid REFERENCES users(id),
    assigned_to uuid REFERENCES users(id),
    project_id uuid REFERENCES projects(id),
    agency_id uuid REFERENCES agencies(id),
    location geometry(Point, 4326),
    sla_due_date timestamptz,
    resolved_at timestamptz,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Documents table
CREATE TABLE documents (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    description text,
    file_path text NOT NULL,
    file_size bigint,
    mime_type text,
    category text,
    uploaded_by uuid REFERENCES users(id),
    project_id uuid REFERENCES projects(id),
    milestone_id uuid REFERENCES milestones(id),
    is_public boolean DEFAULT false,
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now()
);

-- Meetings table
CREATE TABLE meetings (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title text NOT NULL,
    description text,
    scheduled_at timestamptz NOT NULL,
    duration_minutes integer DEFAULT 60,
    location text,
    meeting_url text,
    organizer_id uuid REFERENCES users(id),
    participants uuid[],
    agenda jsonb DEFAULT '[]',
    minutes jsonb DEFAULT '{}',
    status text DEFAULT 'scheduled', -- 'scheduled', 'in_progress', 'completed', 'cancelled'
    metadata jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Create spatial indexes for performance
CREATE INDEX idx_agencies_location ON agencies USING GIST (location);
CREATE INDEX idx_agencies_coverage_area ON agencies USING GIST (coverage_area);
CREATE INDEX idx_projects_location ON projects USING GIST (location);
CREATE INDEX idx_projects_project_area ON projects USING GIST (project_area);
CREATE INDEX idx_milestones_location ON milestones USING GIST (location);
CREATE INDEX idx_users_location ON users USING GIST (location);
CREATE INDEX idx_states_boundary ON states USING GIST (boundary);
CREATE INDEX idx_districts_boundary ON districts USING GIST (boundary);

-- Create regular indexes for performance
CREATE INDEX idx_projects_agency_id ON projects(agency_id);
CREATE INDEX idx_projects_state_id ON projects(state_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_component ON projects(component);
CREATE INDEX idx_fund_flow_project_id ON fund_flow(project_id);
CREATE INDEX idx_fund_flow_status ON fund_flow(status);
CREATE INDEX idx_fund_flow_transaction_date ON fund_flow(transaction_date);
CREATE INDEX idx_milestones_project_id ON milestones(project_id);
CREATE INDEX idx_milestones_status ON milestones(status);
CREATE INDEX idx_audit_trail_entity ON audit_trail(entity_type, entity_id);
CREATE INDEX idx_audit_trail_timestamp ON audit_trail(timestamp);
CREATE INDEX idx_chat_messages_channel_id ON chat_messages(channel_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_tickets_priority ON tickets(priority);
CREATE INDEX idx_tickets_created_by ON tickets(created_by);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_agencies_updated_at BEFORE UPDATE ON agencies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_milestones_updated_at BEFORE UPDATE ON milestones FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_chat_channels_updated_at BEFORE UPDATE ON chat_channels FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_chat_messages_updated_at BEFORE UPDATE ON chat_messages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tickets_updated_at BEFORE UPDATE ON tickets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_meetings_updated_at BEFORE UPDATE ON meetings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
