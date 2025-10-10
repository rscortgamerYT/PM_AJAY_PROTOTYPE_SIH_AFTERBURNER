-- Migration: Row Level Security Policies for Advanced Features
-- Created: 2024-10-10

-- =====================================================
-- PROJECT FLAGS RLS POLICIES
-- =====================================================

ALTER TABLE project_flags ENABLE ROW LEVEL SECURITY;

-- Overwatch can view all flags
CREATE POLICY "overwatch_view_all_flags" ON project_flags
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.raw_user_meta_data->>'role' = 'overwatch'
        )
    );

-- Overwatch can create flags
CREATE POLICY "overwatch_create_flags" ON project_flags
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.raw_user_meta_data->>'role' = 'overwatch'
        )
    );

-- Overwatch can update flags
CREATE POLICY "overwatch_update_flags" ON project_flags
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.raw_user_meta_data->>'role' = 'overwatch'
        )
    );

-- State can view flags for their projects
CREATE POLICY "state_view_flags" ON project_flags
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            JOIN projects ON projects.state_id = (auth.users.raw_user_meta_data->>'state_id')::uuid
            WHERE auth.users.id = auth.uid()
            AND auth.users.raw_user_meta_data->>'role' = 'state'
            AND projects.id = project_flags.project_id
        )
    );

-- Centre can view all flags
CREATE POLICY "centre_view_all_flags" ON project_flags
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.raw_user_meta_data->>'role' = 'centre'
        )
    );

-- Agency can view flags for their projects
CREATE POLICY "agency_view_flags" ON project_flags
    FOR SELECT
    USING (
        agency_id = auth.uid()
    );

-- =====================================================
-- PROJECT MILESTONES RLS POLICIES
-- =====================================================

ALTER TABLE project_milestones ENABLE ROW LEVEL SECURITY;

-- Agency can manage their own milestones
CREATE POLICY "agency_manage_milestones" ON project_milestones
    FOR ALL
    USING (
        agency_id = auth.uid()
    );

-- Overwatch can view all milestones
CREATE POLICY "overwatch_view_all_milestones" ON project_milestones
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.raw_user_meta_data->>'role' = 'overwatch'
        )
    );

-- Overwatch can update milestones (for approval)
CREATE POLICY "overwatch_approve_milestones" ON project_milestones
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.raw_user_meta_data->>'role' = 'overwatch'
        )
    );

-- State can view milestones for their projects
CREATE POLICY "state_view_milestones" ON project_milestones
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            JOIN projects ON projects.state_id = (auth.users.raw_user_meta_data->>'state_id')::uuid
            WHERE auth.users.id = auth.uid()
            AND auth.users.raw_user_meta_data->>'role' = 'state'
            AND projects.id = project_milestones.project_id
        )
    );

-- Centre can view all milestones
CREATE POLICY "centre_view_all_milestones" ON project_milestones
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.raw_user_meta_data->>'role' = 'centre'
        )
    );

-- =====================================================
-- COMMUNICATION CHANNELS RLS POLICIES
-- =====================================================

ALTER TABLE communication_channels ENABLE ROW LEVEL SECURITY;

-- Users can view channels they're participants in
CREATE POLICY "view_participant_channels" ON communication_channels
    FOR SELECT
    USING (
        auth.uid() = ANY(participant_ids)
    );

-- Users with appropriate roles can create channels
CREATE POLICY "create_channels" ON communication_channels
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.raw_user_meta_data->>'role' IN ('centre', 'state', 'overwatch')
        )
    );

-- Channel creators can update their channels
CREATE POLICY "update_own_channels" ON communication_channels
    FOR UPDATE
    USING (created_by = auth.uid());

-- =====================================================
-- COMMUNICATION MESSAGES RLS POLICIES
-- =====================================================

ALTER TABLE communication_messages ENABLE ROW LEVEL SECURITY;

-- Users can view messages in channels they're part of
CREATE POLICY "view_channel_messages" ON communication_messages
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM communication_channels
            WHERE communication_channels.id = communication_messages.channel_id
            AND auth.uid() = ANY(communication_channels.participant_ids)
        )
    );

-- Users can send messages in channels they're part of
CREATE POLICY "send_channel_messages" ON communication_messages
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM communication_channels
            WHERE communication_channels.id = channel_id
            AND auth.uid() = ANY(communication_channels.participant_ids)
        )
    );

-- Users can update their own messages
CREATE POLICY "update_own_messages" ON communication_messages
    FOR UPDATE
    USING (sender_id = auth.uid());

-- Users can delete their own messages
CREATE POLICY "delete_own_messages" ON communication_messages
    FOR DELETE
    USING (sender_id = auth.uid());

-- =====================================================
-- E-SIGN DOCUMENTS RLS POLICIES
-- =====================================================

ALTER TABLE esign_documents ENABLE ROW LEVEL SECURITY;

-- Document creators can view their documents
CREATE POLICY "view_own_documents" ON esign_documents
    FOR SELECT
    USING (created_by = auth.uid());

-- Signers can view documents assigned to them
CREATE POLICY "view_assigned_documents" ON esign_documents
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM jsonb_array_elements_text(workflow->'signer_ids') AS signer_id
            WHERE signer_id::uuid = auth.uid()
        )
    );

-- Authorized users can create documents
CREATE POLICY "create_documents" ON esign_documents
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND auth.users.raw_user_meta_data->>'role' IN ('centre', 'state', 'overwatch')
        )
    );

-- Document creators can update their documents
CREATE POLICY "update_own_documents" ON esign_documents
    FOR UPDATE
    USING (created_by = auth.uid());

-- =====================================================
-- E-SIGN SIGNATURES RLS POLICIES
-- =====================================================

ALTER TABLE esign_signatures ENABLE ROW LEVEL SECURITY;

-- Users can view signatures on documents they have access to
CREATE POLICY "view_document_signatures" ON esign_signatures
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM esign_documents
            WHERE esign_documents.id = esign_signatures.document_id
            AND (
                esign_documents.created_by = auth.uid()
                OR EXISTS (
                    SELECT 1
                    FROM jsonb_array_elements_text(esign_documents.workflow->'signer_ids') AS signer_id
                    WHERE signer_id::uuid = auth.uid()
                )
            )
        )
    );

-- Users can create their own signatures
CREATE POLICY "create_own_signatures" ON esign_signatures
    FOR INSERT
    WITH CHECK (signer_id = auth.uid());

-- =====================================================
-- E-SIGN AUDIT TRAIL RLS POLICIES
-- =====================================================

ALTER TABLE esign_audit_trail ENABLE ROW LEVEL SECURITY;

-- Users can view audit trail for documents they have access to
CREATE POLICY "view_document_audit_trail" ON esign_audit_trail
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM esign_documents
            WHERE esign_documents.id = esign_audit_trail.document_id
            AND (
                esign_documents.created_by = auth.uid()
                OR EXISTS (
                    SELECT 1
                    FROM jsonb_array_elements_text(esign_documents.workflow->'signer_ids') AS signer_id
                    WHERE signer_id::uuid = auth.uid()
                )
            )
        )
    );

-- System can insert audit trail entries
CREATE POLICY "insert_audit_trail" ON esign_audit_trail
    FOR INSERT
    WITH CHECK (true);

-- =====================================================
-- FUNCTIONS FOR RLS HELPERS
-- =====================================================

-- Function to check if user is in channel
CREATE OR REPLACE FUNCTION is_channel_participant(channel_id UUID, user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM communication_channels
        WHERE id = channel_id
        AND user_id = ANY(participant_ids)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user can sign document
CREATE OR REPLACE FUNCTION can_sign_document(document_id UUID, user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM esign_documents,
        jsonb_array_elements_text(workflow->'signer_ids') AS signer_id
        WHERE esign_documents.id = document_id
        AND signer_id::uuid = user_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON POLICY "overwatch_view_all_flags" ON project_flags IS 'Overwatch users can view all project flags';
COMMENT ON POLICY "agency_manage_milestones" ON project_milestones IS 'Agencies can manage their own milestones';
COMMENT ON POLICY "view_participant_channels" ON communication_channels IS 'Users can view channels they participate in';
COMMENT ON POLICY "view_channel_messages" ON communication_messages IS 'Users can view messages in their channels';
COMMENT ON POLICY "view_own_documents" ON esign_documents IS 'Document creators can view their documents';
COMMENT ON POLICY "view_document_signatures" ON esign_signatures IS 'Users can view signatures on their documents';