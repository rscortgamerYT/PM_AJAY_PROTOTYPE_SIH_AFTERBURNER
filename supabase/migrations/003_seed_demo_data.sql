-- ============================================
-- DEMO DATA SEED FOR FUND FLOW SYSTEM
-- PM-AJAY Platform - Production Testing Data
-- ============================================

-- Clear existing demo data (if any)
TRUNCATE TABLE fund_flow, milestones, projects, agencies, districts, states, users CASCADE;

-- ============================================
-- STATES DATA
-- ============================================

INSERT INTO states (id, name, code, capital, population, area_sq_km, boundary) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Delhi', 'DL', 'New Delhi', 19000000, 1484, 
 ST_GeomFromText('MULTIPOLYGON(((77.0 28.4, 77.3 28.4, 77.3 28.9, 77.0 28.9, 77.0 28.4)))', 4326)),
('550e8400-e29b-41d4-a716-446655440002', 'Maharashtra', 'MH', 'Mumbai', 112000000, 307713,
 ST_GeomFromText('MULTIPOLYGON(((72.6 18.9, 77.0 18.9, 77.0 21.0, 72.6 21.0, 72.6 18.9)))', 4326)),
('550e8400-e29b-41d4-a716-446655440003', 'Karnataka', 'KA', 'Bangalore', 61000000, 191791,
 ST_GeomFromText('MULTIPOLYGON(((74.0 12.0, 78.5 12.0, 78.5 18.5, 74.0 18.5, 74.0 12.0)))', 4326)),
('550e8400-e29b-41d4-a716-446655440004', 'Uttar Pradesh', 'UP', 'Lucknow', 200000000, 240928,
 ST_GeomFromText('MULTIPOLYGON(((77.0 24.0, 84.5 24.0, 84.5 30.5, 77.0 30.5, 77.0 24.0)))', 4326)),
('550e8400-e29b-41d4-a716-446655440005', 'Tamil Nadu', 'TN', 'Chennai', 72000000, 130060,
 ST_GeomFromText('MULTIPOLYGON(((76.2 8.0, 80.5 8.0, 80.5 13.5, 76.2 13.5, 76.2 8.0)))', 4326));

-- ============================================
-- DISTRICTS DATA
-- ============================================

INSERT INTO districts (id, state_id, name, code, headquarters, population, area_sq_km, boundary) VALUES
-- Delhi Districts
('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Central Delhi', 'DL-CD', 'Connaught Place', 582320, 25, 
 ST_GeomFromText('MULTIPOLYGON(((77.2 28.6, 77.25 28.6, 77.25 28.65, 77.2 28.65, 77.2 28.6)))', 4326)),
('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'South Delhi', 'DL-SD', 'Saket', 2731929, 250,
 ST_GeomFromText('MULTIPOLYGON(((77.15 28.5, 77.3 28.5, 77.3 28.6, 77.15 28.6, 77.15 28.5)))', 4326)),
-- Maharashtra Districts
('650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 'Mumbai City', 'MH-MC', 'Mumbai', 3145966, 157,
 ST_GeomFromText('MULTIPOLYGON(((72.8 18.9, 72.95 18.9, 72.95 19.05, 72.8 19.05, 72.8 18.9)))', 4326)),
('650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'Pune', 'MH-PU', 'Pune', 9429408, 15642,
 ST_GeomFromText('MULTIPOLYGON(((73.7 18.4, 74.2 18.4, 74.2 18.9, 73.7 18.9, 73.7 18.4)))', 4326)),
-- Karnataka Districts
('650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440003', 'Bangalore Urban', 'KA-BU', 'Bangalore', 9621551, 2190,
 ST_GeomFromText('MULTIPOLYGON(((77.4 12.8, 77.8 12.8, 77.8 13.2, 77.4 13.2, 77.4 12.8)))', 4326));

-- ============================================
-- USERS DATA (Demo Users for Each Role)
-- ============================================

INSERT INTO users (id, email, role, full_name, phone, state_id, district_id, location, is_active, metadata) VALUES
-- Centre Admins
('750e8400-e29b-41d4-a716-446655440001', 'admin.centre@pmajay.gov.in', 'centre_admin', 'Dr. Rajesh Kumar', '+91-11-23456789', NULL, NULL,
 ST_GeomFromText('POINT(77.2090 28.6139)', 4326), true, '{"designation": "Joint Secretary", "department": "Ministry of Social Justice"}'),
('750e8400-e29b-41d4-a716-446655440002', 'finance.centre@pmajay.gov.in', 'centre_admin', 'Ms. Priya Sharma', '+91-11-23456790', NULL, NULL,
 ST_GeomFromText('POINT(77.2090 28.6139)', 4326), true, '{"designation": "Director Finance", "department": "Ministry of Social Justice"}'),

-- State Officers
('750e8400-e29b-41d4-a716-446655440003', 'officer.delhi@pmajay.gov.in', 'state_officer', 'Mr. Amit Singh', '+91-11-23456791', '550e8400-e29b-41d4-a716-446655440001', NULL,
 ST_GeomFromText('POINT(77.2090 28.6139)', 4326), true, '{"designation": "State Nodal Officer", "experience_years": 8}'),
('750e8400-e29b-41d4-a716-446655440004', 'officer.maharashtra@pmajay.gov.in', 'state_officer', 'Dr. Sneha Patil', '+91-22-23456792', '550e8400-e29b-41d4-a716-446655440002', NULL,
 ST_GeomFromText('POINT(72.8777 19.0760)', 4326), true, '{"designation": "State Nodal Officer", "experience_years": 10}'),
('750e8400-e29b-41d4-a716-446655440005', 'officer.karnataka@pmajay.gov.in', 'state_officer', 'Mr. Karthik Rao', '+91-80-23456793', '550e8400-e29b-41d4-a716-446655440003', NULL,
 ST_GeomFromText('POINT(77.5946 12.9716)', 4326), true, '{"designation": "State Nodal Officer", "experience_years": 6}'),

-- Agency Users
('750e8400-e29b-41d4-a716-446655440006', 'dda@delhi.gov.in', 'agency_user', 'Mr. Vikram Mehta', '+91-11-24622600', '550e8400-e29b-41d4-a716-446655440001', NULL,
 ST_GeomFromText('POINT(77.2090 28.6139)', 4326), true, '{"designation": "Project Manager", "agency_name": "Delhi Development Authority"}'),
('750e8400-e29b-41d4-a716-446655440007', 'mud@maharashtra.gov.in', 'agency_user', 'Ms. Anita Desai', '+91-22-22694727', '550e8400-e29b-41d4-a716-446655440002', NULL,
 ST_GeomFromText('POINT(72.8777 19.0760)', 4326), true, '{"designation": "Project Manager", "agency_name": "Mumbai Urban Development"}'),

-- Overwatch
('750e8400-e29b-41d4-a716-446655440008', 'overwatch@pmajay.gov.in', 'overwatch', 'Dr. Arun Verma', '+91-11-23456794', NULL, NULL,
 ST_GeomFromText('POINT(77.2090 28.6139)', 4326), true, '{"designation": "Chief Monitoring Officer", "clearance_level": "L5"}');

-- ============================================
-- AGENCIES DATA
-- ============================================

INSERT INTO agencies (id, name, type, state_id, district_id, location, address, contact_person, phone, email, capacity_score, performance_rating, is_active, metadata) VALUES
-- Delhi Agencies
('850e8400-e29b-41d4-a716-446655440001', 'Delhi Development Authority', 'implementing_agency', '550e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001',
 ST_GeomFromText('POINT(77.2090 28.6139)', 4326), 'Vikas Sadan, INA, New Delhi - 110023', 'Mr. Vikram Mehta', '+91-11-24622600', 'dda@delhi.gov.in', 0.92, 0.88, true,
 '{"established": "1957", "staff_count": 1200, "active_projects": 45}'),

-- Maharashtra Agencies
('850e8400-e29b-41d4-a716-446655440002', 'Mumbai Urban Development', 'implementing_agency', '550e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440003',
 ST_GeomFromText('POINT(72.8777 19.0760)', 4326), 'BMC Building, Mahapalika Marg, Mumbai - 400001', 'Ms. Anita Desai', '+91-22-22694727', 'mud@maharashtra.gov.in', 0.88, 0.85, true,
 '{"established": "1888", "staff_count": 2500, "active_projects": 78}'),
('850e8400-e29b-41d4-a716-446655440003', 'Pune Development Authority', 'nodal_agency', '550e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440004',
 ST_GeomFromText('POINT(73.8567 18.5204)', 4326), 'PDA Complex, Yerwada, Pune - 411006', 'Mr. Rahul Joshi', '+91-20-26054321', 'pda@maharashtra.gov.in', 0.85, 0.82, true,
 '{"established": "1967", "staff_count": 650, "active_projects": 52}'),

-- Karnataka Agencies
('850e8400-e29b-41d4-a716-446655440004', 'Bangalore Development Authority', 'implementing_agency', '550e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440005',
 ST_GeomFromText('POINT(77.5946 12.9716)', 4326), 'BDA Complex, Kumara Krupa Road, Bangalore - 560001', 'Mr. Suresh Kumar', '+91-80-22212520', 'bda@karnataka.gov.in', 0.86, 0.82, true,
 '{"established": "1976", "staff_count": 800, "active_projects": 63}');

-- Update agency_id for agency users
UPDATE users SET agency_id = '850e8400-e29b-41d4-a716-446655440001' WHERE id = '750e8400-e29b-41d4-a716-446655440006';
UPDATE users SET agency_id = '850e8400-e29b-41d4-a716-446655440002' WHERE id = '750e8400-e29b-41d4-a716-446655440007';

-- ============================================
-- PROJECTS DATA
-- ============================================

INSERT INTO projects (id, name, description, agency_id, state_id, district_id, location, status, component, total_budget, allocated_budget, utilized_budget, start_date, end_date, completion_percentage, beneficiaries_count, metadata) VALUES
-- Delhi Projects
('950e8400-e29b-41d4-a716-446655440001', 'Adarsh Gram Scheme - Dwarka Phase 1', 'Comprehensive village development in Dwarka region', '850e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440002',
 ST_GeomFromText('POINT(77.0469 28.5820)', 4326), 'in_progress', 'adarsh_gram', 50000000.00, 50000000.00, 43750000.00, '2024-04-01', '2025-03-31', 87.50, 2500,
 '{"villages": 5, "infrastructure_score": 85, "social_development_score": 90}'),

('950e8400-e29b-41d4-a716-446655440002', 'GIA Infrastructure - Central Delhi', 'Grant-in-Aid for infrastructure development', '850e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001',
 ST_GeomFromText('POINT(77.2167 28.6358)', 4326), 'review', 'gia', 30000000.00, 30000000.00, 25000000.00, '2024-01-01', '2024-12-31', 83.33, 1200,
 '{"beneficiary_institutions": 8, "completion_timeline": "on_track"}'),

-- Maharashtra Projects
('950e8400-e29b-41d4-a716-446655440003', 'Adarsh Gram Scheme - Mumbai Suburban', 'Village development in Mumbai suburban areas', '850e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440003',
 ST_GeomFromText('POINT(72.8479 19.0970)', 4326), 'in_progress', 'adarsh_gram', 75000000.00, 75000000.00, 61875000.00, '2024-03-01', '2025-06-30', 82.50, 4200,
 '{"villages": 8, "infrastructure_score": 82, "social_development_score": 88}'),

('950e8400-e29b-41d4-a716-446655440004', 'Hostel Construction - Pune', 'SC/ST hostel construction project', '850e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440004',
 ST_GeomFromText('POINT(73.8567 18.5204)', 4326), 'in_progress', 'hostel', 45000000.00, 45000000.00, 22500000.00, '2024-06-01', '2025-12-31', 50.00, 800,
 '{"capacity": 400, "floors": 4, "amenities": "library,computer_lab,sports"}'),

-- Karnataka Projects
('950e8400-e29b-41d4-a716-446655440005', 'Adarsh Gram Scheme - Bangalore Rural', 'Rural development in Bangalore outskirts', '850e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440005',
 ST_GeomFromText('POINT(77.5155 12.8996)', 4326), 'in_progress', 'adarsh_gram', 60000000.00, 60000000.00, 47880000.00, '2024-02-01', '2025-05-31', 79.80, 3500,
 '{"villages": 6, "infrastructure_score": 78, "social_development_score": 85}');

-- ============================================
-- FUND FLOW DATA (Comprehensive Transaction History)
-- ============================================

INSERT INTO fund_flow (id, transaction_id, from_entity_type, from_entity_id, to_entity_type, to_entity_id, project_id, component, amount, status, transaction_date, uc_date, remarks, pfms_reference, metadata) VALUES
-- Centre to State Allocations
('a50e8400-e29b-41d4-a716-446655440001', 'PFMS2024001', 'centre', NULL, 'state', '550e8400-e29b-41d4-a716-446655440001', NULL, 'adarsh_gram', 50000000.00, 'completed', '2024-09-25 10:00:00+00', '2024-09-27 15:30:00+00',
 'Q3 FY2024-25 allocation for Adarsh Gram component', 'PFMS/AG/2024/001', '{"fiscal_year": "2024-25", "quarter": "Q3", "approval_date": "2024-09-20"}'),

('a50e8400-e29b-41d4-a716-446655440002', 'PFMS2024002', 'centre', NULL, 'state', '550e8400-e29b-41d4-a716-446655440001', NULL, 'gia', 30000000.00, 'completed', '2024-09-28 11:30:00+00', '2024-09-30 14:00:00+00',
 'Q3 FY2024-25 GIA allocation', 'PFMS/GIA/2024/001', '{"fiscal_year": "2024-25", "quarter": "Q3", "approval_date": "2024-09-22"}'),

('a50e8400-e29b-41d4-a716-446655440003', 'PFMS2024003', 'centre', NULL, 'state', '550e8400-e29b-41d4-a716-446655440002', NULL, 'adarsh_gram', 75000000.00, 'completed', '2024-09-26 09:00:00+00', '2024-09-28 16:00:00+00',
 'Q3 FY2024-25 Maharashtra allocation', 'PFMS/AG/2024/002', '{"fiscal_year": "2024-25", "quarter": "Q3", "approval_date": "2024-09-21"}'),

('a50e8400-e29b-41d4-a716-446655440004', 'PFMS2024004', 'centre', NULL, 'state', '550e8400-e29b-41d4-a716-446655440002', NULL, 'hostel', 45000000.00, 'completed', '2024-10-01 10:30:00+00', '2024-10-03 12:00:00+00',
 'Q3 FY2024-25 Hostel construction allocation', 'PFMS/HST/2024/001', '{"fiscal_year": "2024-25", "quarter": "Q3", "approval_date": "2024-09-28"}'),

('a50e8400-e29b-41d4-a716-446655440005', 'PFMS2024005', 'centre', NULL, 'state', '550e8400-e29b-41d4-a716-446655440003', NULL, 'adarsh_gram', 60000000.00, 'completed', '2024-10-02 08:00:00+00', '2024-10-04 17:00:00+00',
 'Q3 FY2024-25 Karnataka allocation', 'PFMS/AG/2024/003', '{"fiscal_year": "2024-25", "quarter": "Q3", "approval_date": "2024-09-29"}'),

-- State to Agency Transfers
('a50e8400-e29b-41d4-a716-446655440006', 'PFMS2024006', 'state', '550e8400-e29b-41d4-a716-446655440001', 'agency', '850e8400-e29b-41d4-a716-446655440001', '950e8400-e29b-41d4-a716-446655440001', 'adarsh_gram', 50000000.00, 'completed', '2024-09-28 10:00:00+00', '2024-09-30 16:00:00+00',
 'Transferred to DDA for Dwarka project', 'PFMS/DL-DDA/001', '{"transfer_mode": "rtgs", "processing_days": 2}'),

('a50e8400-e29b-41d4-a716-446655440007', 'PFMS2024007', 'state', '550e8400-e29b-41d4-a716-446655440001', 'agency', '850e8400-e29b-41d4-a716-446655440001', '950e8400-e29b-41d4-a716-446655440002', 'gia', 30000000.00, 'completed', '2024-10-01 11:00:00+00', '2024-10-03 15:00:00+00',
 'Transferred to DDA for GIA infrastructure', 'PFMS/DL-DDA/002', '{"transfer_mode": "rtgs", "processing_days": 2}'),

('a50e8400-e29b-41d4-a716-446655440008', 'PFMS2024008', 'state', '550e8400-e29b-41d4-a716-446655440002', 'agency', '850e8400-e29b-41d4-a716-446655440002', '950e8400-e29b-41d4-a716-446655440003', 'adarsh_gram', 75000000.00, 'completed', '2024-09-29 09:30:00+00', '2024-10-01 14:00:00+00',
 'Transferred to MUD for suburban project', 'PFMS/MH-MUD/001', '{"transfer_mode": "rtgs", "processing_days": 2}'),

('a50e8400-e29b-41d4-a716-446655440009', 'PFMS2024009', 'state', '550e8400-e29b-41d4-a716-446655440002', 'agency', '850e8400-e29b-41d4-a716-446655440003', '950e8400-e29b-41d4-a716-446655440004', 'hostel', 45000000.00, 'transferred', '2024-10-04 10:00:00+00', NULL,
 'Transferred to PDA for hostel construction', 'PFMS/MH-PDA/001', '{"transfer_mode": "rtgs", "processing_days": 0}'),

('a50e8400-e29b-41d4-a716-446655440010', 'PFMS2024010', 'state', '550e8400-e29b-41d4-a716-446655440003', 'agency', '850e8400-e29b-41d4-a716-446655440004', '950e8400-e29b-41d4-a716-446655440005', 'adarsh_gram', 60000000.00, 'transferred', '2024-10-05 08:30:00+00', NULL,
 'Transferred to BDA for rural development', 'PFMS/KA-BDA/001', '{"transfer_mode": "rtgs", "processing_days": 0}'),

-- Agency to Project Utilizations
('a50e8400-e29b-41d4-a716-446655440011', 'PFMS2024011', 'agency', '850e8400-e29b-41d4-a716-446655440001', 'project', NULL, '950e8400-e29b-41d4-a716-446655440001', 'adarsh_gram', 43750000.00, 'utilized', '2024-10-01 12:00:00+00', '2024-10-08 16:00:00+00',
 'Fund utilization for Dwarka Adarsh Gram', 'PFMS/DDA-AGP1/001', '{"milestone_payments": 7, "retention": 12.5}'),

('a50e8400-e29b-41d4-a716-446655440012', 'PFMS2024012', 'agency', '850e8400-e29b-41d4-a716-446655440001', 'project', NULL, '950e8400-e29b-41d4-a716-446655440002', 'gia', 25000000.00, 'utilized', '2024-10-03 13:00:00+00', NULL,
 'Fund utilization for GIA infrastructure', 'PFMS/DDA-GIA1/001', '{"milestone_payments": 5, "retention": 16.67}'),

('a50e8400-e29b-41d4-a716-446655440013', 'PFMS2024013', 'agency', '850e8400-e29b-41d4-a716-446655440002', 'project', NULL, '950e8400-e29b-41d4-a716-446655440003', 'adarsh_gram', 61875000.00, 'utilized', '2024-10-02 11:30:00+00', NULL,
 'Fund utilization for Mumbai suburban project', 'PFMS/MUD-AGP1/001', '{"milestone_payments": 8, "retention": 17.5}'),

('a50e8400-e29b-41d4-a716-446655440014', 'PFMS2024014', 'agency', '850e8400-e29b-41d4-a716-446655440003', 'project', NULL, '950e8400-e29b-41d4-a716-446655440004', 'hostel', 22500000.00, 'utilized', '2024-10-06 10:00:00+00', NULL,
 'Fund utilization for Pune hostel construction - Phase 1', 'PFMS/PDA-HST1/001', '{"milestone_payments": 3, "retention": 50.0}'),

('a50e8400-e29b-41d4-a716-446655440015', 'PFMS2024015', 'agency', '850e8400-e29b-41d4-a716-446655440004', 'project', NULL, '950e8400-e29b-41d4-a716-446655440005', 'adarsh_gram', 47880000.00, 'pending_uc', '2024-10-07 09:00:00+00', NULL,
 'Fund utilization for Bangalore rural project', 'PFMS/BDA-AGP1/001', '{"milestone_payments": 6, "retention": 20.2}');

-- ============================================
-- MILESTONES DATA
-- ============================================

INSERT INTO milestones (id, project_id, name, description, status, due_date, completion_date, budget_allocation, submitted_by, reviewed_by, metadata) VALUES
-- Delhi Adarsh Gram Milestones
('b50e8400-e29b-41d4-a716-446655440001', '950e8400-e29b-41d4-a716-446655440001', 'Site Survey & Planning', 'Comprehensive survey and project planning phase', 'approved', '2024-04-30', '2024-04-28', 5000000.00, '750e8400-e29b-41d4-a716-446655440006', '750e8400-e29b-41d4-a716-446655440003',
 '{"villages_surveyed": 5, "beneficiaries_mapped": 2500}'),
('b50e8400-e29b-41d4-a716-446655440002', '950e8400-e29b-41d4-a716-446655440001', 'Infrastructure Development', 'Roads, water supply, and sanitation', 'approved', '2024-08-31', '2024-08-29', 20000000.00, '750e8400-e29b-41d4-a716-446655440006', '750e8400-e29b-41d4-a716-446655440003',
 '{"roads_km": 15, "water_connections": 500, "toilets": 400}'),
('b50e8400-e29b-41d4-a716-446655440003', '950e8400-e29b-41d4-a716-446655440001', 'Social Development Programs', 'Education and skill development initiatives', 'under_review', '2024-12-31', NULL, 18750000.00, '750e8400-e29b-41d4-a716-446655440006', NULL,
 '{"training_programs": 12, "participants": 800}'),

-- Maharashtra Projects Milestones
('b50e8400-e29b-41d4-a716-446655440004', '950e8400-e29b-41d4-a716-446655440003', 'Baseline Assessment', 'Initial assessment and DPR preparation', 'approved', '2024-04-15', '2024-04-12', 7500000.00, '750e8400-e29b-41d4-a716-446655440007', '750e8400-e29b-41d4-a716-446655440004',
 '{"dprs_prepared": 8, "baseline_surveys": 8}'),
('b50e8400-e29b-41d4-a716-446655440005', '950e8400-e29b-41d4-a716-446655440004', 'Foundation & Structure', 'Building foundation and main structure', 'under_review', '2024-11-30', NULL, 22500000.00, '750e8400-e29b-41d4-a716-446655440007', NULL,
 '{"floors_completed": 2, "percentage": 50}');

-- Create audit trail entries for major transactions
INSERT INTO audit_trail (previous_hash, user_id, entity_type, entity_id, action, data, ip_address) VALUES
(NULL, '750e8400-e29b-41d4-a716-446655440001', 'fund_flow', 'a50e8400-e29b-41d4-a716-446655440001', 'ALLOCATION_APPROVED', 
 '{"amount": 50000000, "state": "Delhi", "component": "adarsh_gram"}'::jsonb, '10.0.1.100'),
('', '750e8400-e29b-41d4-a716-446655440003', 'fund_flow', 'a50e8400-e29b-41d4-a716-446655440006', 'TRANSFER_COMPLETED',
 '{"amount": 50000000, "agency": "DDA", "project": "Dwarka Phase 1"}'::jsonb, '10.0.2.50');

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Verify data insertion
SELECT 'States' as entity, count(*) as count FROM states
UNION ALL
SELECT 'Districts', count(*) FROM districts
UNION ALL
SELECT 'Users', count(*) FROM users
UNION ALL
SELECT 'Agencies', count(*) FROM agencies
UNION ALL
SELECT 'Projects', count(*) FROM projects
UNION ALL
SELECT 'Fund Flow Transactions', count(*) FROM fund_flow
UNION ALL
SELECT 'Milestones', count(*) FROM milestones;

-- Summary statistics
SELECT 
    'Total Allocated' as metric,
    SUM(amount) as value
FROM fund_flow
WHERE from_entity_type = 'centre'
UNION ALL
SELECT 
    'Total Utilized',
    SUM(amount)
FROM fund_flow
WHERE status = 'utilized'
UNION ALL
SELECT 
    'Pending UC',
    SUM(amount)
FROM fund_flow
WHERE status = 'pending_uc';

COMMIT;