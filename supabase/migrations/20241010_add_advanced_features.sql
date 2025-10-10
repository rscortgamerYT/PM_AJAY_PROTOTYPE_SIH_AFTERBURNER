-- Migration: Add Advanced Features (Flags, Milestones, Communication, E-Sign)
-- Created: 2024-10-10

-- =====================================================
-- PROJECT FLAGS TABLE
-- =====================================================
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

CREATE INDEX idx_project_flags_project_id ON project_flags(project_id);
CREATE INDEX idx_project_flags_agency_id ON project_flags(agency_id);
CREATE INDEX idx_project_flags_status ON project_flags(status);
CREATE INDEX idx_project_flags_severity ON project_flags(severity);
CREATE INDEX idx_project_flags_flagged_at ON project_flags(flagged_at DESC);

-- =====================================================
-- PROJECT MILESTONES TABLE
-- =====================================================
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

CREATE INDEX idx_project_milestones_project_id ON project_milestones(project_id);
CREATE INDEX idx_project_milestones_agency_id ON project_milestones(agency_id);
CREATE INDEX idx_project_milestones_status ON project_milestones(status);
CREATE INDEX idx_project_milestones_planned_dates ON project_milestones(planned_start_date, planned_end_date);
CREATE INDEX idx_project_milestones_sla_due_date ON project_milestones(sla_due_date);

-- =====================================================
-- COMMUNICATION CHANNELS TABLE
-- =====================================================
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

CREATE INDEX idx_communication_channels_type ON communication_channels(type);
CREATE INDEX idx_communication_channels_project_id ON communication_channels(project_id);
CREATE INDEX idx_communication_channels_agency_id ON communication_channels(agency_id);
CREATE INDEX idx_communication_channels_participants ON communication_channels USING GIN(participant_ids);

-- =====================================================
-- COMMUNICATION MESSAGES TABLE
-- =====================================================
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

CREATE INDEX idx_communication_messages_channel_id ON communication_messages(channel_id);
CREATE INDEX idx_communication_messages_parent_id ON communication_messages(parent_message_id);
CREATE INDEX idx_communication_messages_sender_id ON communication_messages(sender_id);
CREATE INDEX idx_communication_messages_created_at ON communication_messages(created_at DESC);
CREATE INDEX idx_communication_messages_mentioned_users ON communication_messages USING GIN(mentioned_user_ids);

-- =====================================================
-- E-SIGN DOCUMENTS TABLE
-- =====================================================
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

CREATE INDEX idx_esign_documents_status ON esign_documents(status);
CREATE INDEX idx_esign_documents_created_by ON esign_documents(created_by);
CREATE INDEX idx_esign_documents_created_at ON esign_documents(created_at DESC);
CREATE INDEX idx_esign_documents_expires_at ON esign_documents(expires_at);

-- =====================================================
-- E-SIGN SIGNATURES TABLE
-- =====================================================
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

CREATE INDEX idx_esign_signatures_document_id ON esign_signatures(document_id);
CREATE INDEX idx_esign_signatures_signer_id ON esign_signatures(signer_id);
CREATE INDEX idx_esign_signatures_timestamp ON esign_signatures(timestamp DESC);

-- =====================================================
-- E-SIGN AUDIT TRAIL TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS esign_audit_trail (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES esign_documents(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    details JSONB DEFAULT '{}'::JSONB
);

CREATE INDEX idx_esign_audit_trail_document_id ON esign_audit_trail(document_id);
CREATE INDEX idx_esign_audit_trail_timestamp ON esign_audit_trail(timestamp DESC);

-- =====================================================
-- UPDATE TRIGGERS
-- =====================================================

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to all tables
CREATE TRIGGER update_project_flags_updated_at BEFORE UPDATE ON project_flags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_project_milestones_updated_at BEFORE UPDATE ON project_milestones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_communication_channels_updated_at BEFORE UPDATE ON communication_channels
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_communication_messages_updated_at BEFORE UPDATE ON communication_messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_esign_documents_updated_at BEFORE UPDATE ON esign_documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to check if milestone is delayed
CREATE OR REPLACE FUNCTION is_milestone_delayed(milestone_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    milestone_record RECORD;
BEGIN
    SELECT status, planned_end_date INTO milestone_record
    FROM project_milestones
    WHERE id = milestone_id;
    
    IF milestone_record.status = 'approved' THEN
        RETURN FALSE;
    END IF;
    
    RETURN CURRENT_DATE > milestone_record.planned_end_date;
END;
$$ LANGUAGE plpgsql;

-- Function to check if milestone SLA is breached
CREATE OR REPLACE FUNCTION is_milestone_sla_breached(milestone_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    milestone_record RECORD;
BEGIN
    SELECT status, sla_due_date INTO milestone_record
    FROM project_milestones
    WHERE id = milestone_id;
    
    IF milestone_record.sla_due_date IS NULL OR milestone_record.status = 'approved' THEN
        RETURN FALSE;
    END IF;
    
    RETURN NOW() > milestone_record.sla_due_date;
END;
$$ LANGUAGE plpgsql;

-- Function to get unread message count for a user
CREATE OR REPLACE FUNCTION get_unread_message_count(user_id UUID, channel_id UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM communication_messages
        WHERE communication_messages.channel_id = get_unread_message_count.channel_id
        AND NOT (user_id = ANY(read_by))
        AND sender_id != user_id
    );
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE project_flags IS 'Stores flags raised by Overwatch for problematic projects';
COMMENT ON TABLE project_milestones IS 'Tracks project milestones with geo-fencing and approval gates';
COMMENT ON TABLE communication_channels IS 'Communication channels between different stakeholders';
COMMENT ON TABLE communication_messages IS 'Messages within communication channels with threading support';
COMMENT ON TABLE esign_documents IS 'Documents requiring digital signatures';
COMMENT ON TABLE esign_signatures IS 'Digital signatures on documents';
COMMENT ON TABLE esign_audit_trail IS 'Audit trail for e-sign operations';