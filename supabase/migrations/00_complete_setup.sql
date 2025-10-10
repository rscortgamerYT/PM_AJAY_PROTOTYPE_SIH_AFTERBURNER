-- =====================================================
-- COMPLETE DATABASE SETUP FOR PM-AJAY PLATFORM
-- Run this single script in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- STEP 1: ENABLE EXTENSIONS
-- =====================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- =====================================================
-- STEP 2: CREATE BASE TABLES
-- =====================================================

-- States table
CREATE TABLE IF NOT EXISTS states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(10) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Agencies table
CREATE TABLE IF NOT EXISTS agencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    state_id UUID REFERENCES states(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Projects table
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    agency_id UUID NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    state_id UUID NOT NULL REFERENCES states(id) ON DELETE CASCADE,
    location GEOMETRY(Point, 4326),
    status VARCHAR(50) NOT NULL DEFAULT 'proposed',
    budget_allocated DECIMAL(15,2),
    budget_utilized DECIMAL(15,2) DEFAULT 0,
    start_date DATE,
    end_date DATE,
    completion_percentage DECIMAL(5,2) DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Fund allocations table
CREATE TABLE IF NOT EXISTS fund_allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    amount DECIMAL(15,2) NOT NULL,
    allocated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- STEP 3: CREATE ADVANCED FEATURE TABLES
-- =====================================================

-- Project flags table
CREATE TABLE IF NOT EXISTS project_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    agency_id UUID NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    reason VARCHAR(50) NOT NULL CHECK (reason IN ('delay', 'fund_issue', 'quality_issue', 'compliance_violation', 'safety_issue', 'documentation_issue', 'custom')),
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    status VARCHAR(20) NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'acknowledged', 'in_progress', 'resolved', 'escalated')),
    description TEXT NOT NULL,
    custom_reason TEXT,
    flagged_by UUID NOT NULL REFERENCES auth.users(id),
    flagged_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    acknowledged_by UUID REFERENCES auth.users(id),
    acknowledged_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES auth.users(id),
    resolved_at TIMESTAMPTZ,
    resolution_notes TEXT,
    attachment_urls TEXT[] DEFAULT ARRAY[]::TEXT[],
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Project milestones table
CREATE TABLE IF NOT EXISTS project_milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    agency_id UUID NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('planning', 'design', 'procurement', 'construction', 'inspection', 'completion', 'handover', 'custom')),
    status VARCHAR(20) NOT NULL DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'submitted', 'under_review', 'approved', 'rejected', 'delayed')),
    planned_start_date DATE NOT NULL,
    planned_end_date DATE NOT NULL,
    actual_start_date DATE,
    actual_end_date DATE,
    completion_percentage DECIMAL(5,2) DEFAULT 0.00 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    geo_fence JSONB,
    requires_geo_validation BOOLEAN DEFAULT FALSE,
    evidence JSONB DEFAULT '[]'::JSONB,
    submitted_by UUID REFERENCES auth.users(id),
    submitted_at TIMESTAMPTZ,
    reviewed_by UUID REFERENCES auth.users(id),
    reviewed_at TIMESTAMPTZ,
    review_notes TEXT,
    sla_hours INTEGER,
    sla_due_date TIMESTAMPTZ,
    dependencies UUID[] DEFAULT ARRAY[]::UUID[],
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_dates CHECK (planned_end_date >= planned_start_date)
);

-- Communication channels table
CREATE TABLE IF NOT EXISTS communication_channels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL CHECK (type IN ('centre_state', 'state_agency', 'centre_agency', 'overwatch_centre', 'overwatch_state', 'overwatch_agency', 'general', 'project_specific')),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    agency_id UUID REFERENCES agencies(id) ON DELETE CASCADE,
    state_id UUID,
    is_private BOOLEAN DEFAULT FALSE,
    participant_ids UUID[] NOT NULL DEFAULT ARRAY[]::UUID[],
    metadata JSONB DEFAULT '{}'::JSONB,
    created_by UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Communication messages table
CREATE TABLE IF NOT EXISTS communication_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    channel_id UUID NOT NULL REFERENCES communication_channels(id) ON DELETE CASCADE,
    parent_message_id UUID REFERENCES communication_messages(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id),
    content TEXT NOT NULL,
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    mentioned_user_ids UUID[] DEFAULT ARRAY[]::UUID[],
    attachment_urls TEXT[] DEFAULT ARRAY[]::TEXT[],
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMPTZ,
    read_by UUID[] DEFAULT ARRAY[]::UUID[],
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- E-sign documents table
CREATE TABLE IF NOT EXISTS esign_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    document_type VARCHAR(100) NOT NULL,
    document_url TEXT NOT NULL,
    document_hash VARCHAR(64) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'pending', 'signed', 'rejected', 'expired')),
    created_by UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    workflow JSONB NOT NULL,
    metadata JSONB DEFAULT '{}'::JSONB,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- E-sign signatures table
CREATE TABLE IF NOT EXISTS esign_signatures (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES esign_documents(id) ON DELETE CASCADE,
    signer_id UUID NOT NULL REFERENCES auth.users(id),
    signer_name VARCHAR(255) NOT NULL,
    signer_role VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('digital', 'biometric', 'otp', 'aadhaar')),
    signature_hash VARCHAR(64) NOT NULL,
    biometric_data TEXT,
    otp_verification VARCHAR(255),
    aadhaar_number VARCHAR(12),
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ip_address INET NOT NULL,
    device_info TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- E-sign audit trail table
CREATE TABLE IF NOT EXISTS esign_audit_trail (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES esign_documents(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    details JSONB DEFAULT '{}'::JSONB
);

-- =====================================================
-- STEP 4: CREATE INDEXES
-- =====================================================

-- Base table indexes
CREATE INDEX IF NOT EXISTS idx_agencies_state_id ON agencies(state_id);
CREATE INDEX IF NOT EXISTS idx_projects_agency_id ON projects(agency_id);
CREATE INDEX IF NOT EXISTS idx_projects_state_id ON projects(state_id);
CREATE INDEX IF NOT EXISTS idx_projects_location ON projects USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_fund_allocations_project_id ON fund_allocations(project_id);

-- Flag indexes
CREATE INDEX IF NOT EXISTS idx_project_flags_project_id ON project_flags(project_id);
CREATE INDEX IF NOT EXISTS idx_project_flags_agency_id ON project_flags(agency_id);
CREATE INDEX IF NOT EXISTS idx_project_flags_status ON project_flags(status);
CREATE INDEX IF NOT EXISTS idx_project_flags_severity ON project_flags(severity);
CREATE INDEX IF NOT EXISTS idx_project_flags_flagged_at ON project_flags(flagged_at DESC);

-- Milestone indexes
CREATE INDEX IF NOT EXISTS idx_project_milestones_project_id ON project_milestones(project_id);
CREATE INDEX IF NOT EXISTS idx_project_milestones_agency_id ON project_milestones(agency_id);
CREATE INDEX IF NOT EXISTS idx_project_milestones_status ON project_milestones(status);
CREATE INDEX IF NOT EXISTS idx_project_milestones_planned_dates ON project_milestones(planned_start_date, planned_end_date);
CREATE INDEX IF NOT EXISTS idx_project_milestones_sla_due_date ON project_milestones(sla_due_date);

-- Communication indexes
CREATE INDEX IF NOT EXISTS idx_communication_channels_type ON communication_channels(type);
CREATE INDEX IF NOT EXISTS idx_communication_channels_project_id ON communication_channels(project_id);
CREATE INDEX IF NOT EXISTS idx_communication_channels_agency_id ON communication_channels(agency_id);
CREATE INDEX IF NOT EXISTS idx_communication_channels_participants ON communication_channels USING GIN(participant_ids);
CREATE INDEX IF NOT EXISTS idx_communication_messages_channel_id ON communication_messages(channel_id);
CREATE INDEX IF NOT EXISTS idx_communication_messages_parent_id ON communication_messages(parent_message_id);
CREATE INDEX IF NOT EXISTS idx_communication_messages_sender_id ON communication_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_communication_messages_created_at ON communication_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_communication_messages_mentioned_users ON communication_messages USING GIN(mentioned_user_ids);

-- E-sign indexes
CREATE INDEX IF NOT EXISTS idx_esign_documents_status ON esign_documents(status);
CREATE INDEX IF NOT EXISTS idx_esign_documents_created_by ON esign_documents(created_by);
CREATE INDEX IF NOT EXISTS idx_esign_documents_created_at ON esign_documents(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_esign_documents_expires_at ON esign_documents(expires_at);
CREATE INDEX IF NOT EXISTS idx_esign_signatures_document_id ON esign_signatures(document_id);
CREATE INDEX IF NOT EXISTS idx_esign_signatures_signer_id ON esign_signatures(signer_id);
CREATE INDEX IF NOT EXISTS idx_esign_signatures_timestamp ON esign_signatures(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_esign_audit_trail_document_id ON esign_audit_trail(document_id);
CREATE INDEX IF NOT EXISTS idx_esign_audit_trail_timestamp ON esign_audit_trail(timestamp DESC);

-- =====================================================
-- STEP 5: CREATE TRIGGERS
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_states_updated_at ON states;
CREATE TRIGGER update_states_updated_at BEFORE UPDATE ON states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_agencies_updated_at ON agencies;
CREATE TRIGGER update_agencies_updated_at BEFORE UPDATE ON agencies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_projects_updated_at ON projects;
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_project_flags_updated_at ON project_flags;
CREATE TRIGGER update_project_flags_updated_at BEFORE UPDATE ON project_flags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_project_milestones_updated_at ON project_milestones;
CREATE TRIGGER update_project_milestones_updated_at BEFORE UPDATE ON project_milestones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_communication_channels_updated_at ON communication_channels;
CREATE TRIGGER update_communication_channels_updated_at BEFORE UPDATE ON communication_channels
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_communication_messages_updated_at ON communication_messages;
CREATE TRIGGER update_communication_messages_updated_at BEFORE UPDATE ON communication_messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_esign_documents_updated_at ON esign_documents;
CREATE TRIGGER update_esign_documents_updated_at BEFORE UPDATE ON esign_documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- STEP 6: INSERT SAMPLE DATA
-- =====================================================

-- Sample state
INSERT INTO states (name, code) VALUES
('Maharashtra', 'MH')
ON CONFLICT (code) DO NOTHING;

-- Get the state ID
DO $$
DECLARE
    v_state_id UUID;
    v_agency_id UUID;
    v_project_id UUID;
BEGIN
    -- Get or create state
    SELECT id INTO v_state_id FROM states WHERE code = 'MH';
    
    IF v_state_id IS NULL THEN
        INSERT INTO states (name, code) VALUES ('Maharashtra', 'MH') RETURNING id INTO v_state_id;
    END IF;
    
    -- Insert agency
    INSERT INTO agencies (name, state_id, type, contact_email)
    VALUES ('Maharashtra Public Works', v_state_id, 'state', 'mpw@maharashtra.gov.in')
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_agency_id;
    
    -- If agency already exists, get its ID
    IF v_agency_id IS NULL THEN
        SELECT id INTO v_agency_id FROM agencies WHERE name = 'Maharashtra Public Works' LIMIT 1;
    END IF;
    
    -- Insert project
    INSERT INTO projects (
        name, description, agency_id, state_id,
        location, status, budget_allocated, start_date, end_date
    ) VALUES (
        'Highway Construction Project',
        'Construction of 50km highway connecting Mumbai to Pune',
        v_agency_id,
        v_state_id,
        ST_SetSRID(ST_MakePoint(72.8777, 19.0760), 4326),
        'in_progress',
        50000000,
        '2024-01-01',
        '2025-12-31'
    )
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_project_id;
    
    -- If project already exists, get its ID
    IF v_project_id IS NULL THEN
        SELECT id INTO v_project_id FROM projects WHERE name = 'Highway Construction Project' LIMIT 1;
    END IF;
    
    -- Insert fund allocation
    IF v_project_id IS NOT NULL THEN
        INSERT INTO fund_allocations (project_id, amount, allocated_at, status)
        VALUES (v_project_id, 25000000, NOW(), 'approved')
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'Database setup completed successfully!';
    RAISE NOTICE 'Next step: Run the RLS policies script';
    RAISE NOTICE '====================================================';
END $$;