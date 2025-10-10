-- Enable Row Level Security on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE states ENABLE ROW LEVEL SECURITY;
ALTER TABLE districts ENABLE ROW LEVEL SECURITY;
ALTER TABLE agencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE fund_flow ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_trail ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE meetings ENABLE ROW LEVEL SECURITY;

-- Helper function to get user role
CREATE OR REPLACE FUNCTION auth.user_role()
RETURNS text AS $$
  SELECT role::text FROM users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Helper function to get user state
CREATE OR REPLACE FUNCTION auth.user_state()
RETURNS uuid AS $$
  SELECT state_id FROM users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Helper function to get user agency
CREATE OR REPLACE FUNCTION auth.user_agency()
RETURNS uuid AS $$
  SELECT agency_id FROM users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Users table policies
CREATE POLICY "Users can view their own profile"
  ON users FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Centre admins can view all users"
  ON users FOR SELECT
  USING (auth.user_role() = 'centre_admin');

CREATE POLICY "State officers can view users in their state"
  ON users FOR SELECT
  USING (
    auth.user_role() = 'state_officer' AND 
    state_id = auth.user_state()
  );

CREATE POLICY "Overwatch can view all users"
  ON users FOR SELECT
  USING (auth.user_role() = 'overwatch');

CREATE POLICY "Users can update their own profile"
  ON users FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- States table policies
CREATE POLICY "Everyone can view states"
  ON states FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Centre admins can manage states"
  ON states FOR ALL
  USING (auth.user_role() = 'centre_admin')
  WITH CHECK (auth.user_role() = 'centre_admin');

-- Districts table policies
CREATE POLICY "Everyone can view districts"
  ON districts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Centre admins can manage districts"
  ON districts FOR ALL
  USING (auth.user_role() = 'centre_admin')
  WITH CHECK (auth.user_role() = 'centre_admin');

CREATE POLICY "State officers can manage their state's districts"
  ON districts FOR ALL
  USING (
    auth.user_role() = 'state_officer' AND 
    state_id = auth.user_state()
  )
  WITH CHECK (
    auth.user_role() = 'state_officer' AND 
    state_id = auth.user_state()
  );

-- Agencies table policies
CREATE POLICY "Centre admins can view all agencies"
  ON agencies FOR SELECT
  USING (auth.user_role() = 'centre_admin');

CREATE POLICY "State officers can view agencies in their state"
  ON agencies FOR SELECT
  USING (
    auth.user_role() = 'state_officer' AND 
    state_id = auth.user_state()
  );

CREATE POLICY "Agency users can view their own agency"
  ON agencies FOR SELECT
  USING (
    auth.user_role() = 'agency_user' AND 
    id = auth.user_agency()
  );

CREATE POLICY "Overwatch can view all agencies"
  ON agencies FOR SELECT
  USING (auth.user_role() = 'overwatch');

CREATE POLICY "Public can view active agencies"
  ON agencies FOR SELECT
  USING (
    auth.user_role() = 'public' AND 
    is_active = true
  );

CREATE POLICY "Centre admins can manage agencies"
  ON agencies FOR ALL
  USING (auth.user_role() = 'centre_admin')
  WITH CHECK (auth.user_role() = 'centre_admin');

CREATE POLICY "State officers can manage agencies in their state"
  ON agencies FOR ALL
  USING (
    auth.user_role() = 'state_officer' AND 
    state_id = auth.user_state()
  )
  WITH CHECK (
    auth.user_role() = 'state_officer' AND 
    state_id = auth.user_state()
  );

-- Projects table policies
CREATE POLICY "Centre admins can view all projects"
  ON projects FOR SELECT
  USING (auth.user_role() = 'centre_admin');

CREATE POLICY "State officers can view projects in their state"
  ON projects FOR SELECT
  USING (
    auth.user_role() = 'state_officer' AND 
    state_id = auth.user_state()
  );

CREATE POLICY "Agency users can view their agency's projects"
  ON projects FOR SELECT
  USING (
    auth.user_role() = 'agency_user' AND 
    agency_id = auth.user_agency()
  );

CREATE POLICY "Overwatch can view all projects"
  ON projects FOR SELECT
  USING (auth.user_role() = 'overwatch');

CREATE POLICY "Public can view completed projects"
  ON projects FOR SELECT
  USING (
    auth.user_role() = 'public' AND 
    status = 'completed'
  );

CREATE POLICY "Centre admins can manage all projects"
  ON projects FOR ALL
  USING (auth.user_role() = 'centre_admin')
  WITH CHECK (auth.user_role() = 'centre_admin');

CREATE POLICY "State officers can manage projects in their state"
  ON projects FOR ALL
  USING (
    auth.user_role() = 'state_officer' AND 
    state_id = auth.user_state()
  )
  WITH CHECK (
    auth.user_role() = 'state_officer' AND 
    state_id = auth.user_state()
  );

CREATE POLICY "Agency users can manage their agency's projects"
  ON projects FOR ALL
  USING (
    auth.user_role() = 'agency_user' AND 
    agency_id = auth.user_agency()
  )
  WITH CHECK (
    auth.user_role() = 'agency_user' AND 
    agency_id = auth.user_agency()
  );

-- Milestones table policies
CREATE POLICY "Centre admins can view all milestones"
  ON milestones FOR SELECT
  USING (auth.user_role() = 'centre_admin');

CREATE POLICY "State officers can view milestones in their state"
  ON milestones FOR SELECT
  USING (
    auth.user_role() = 'state_officer' AND 
    EXISTS (
      SELECT 1 FROM projects p 
      WHERE p.id = milestones.project_id 
      AND p.state_id = auth.user_state()
    )
  );

CREATE POLICY "Agency users can view their project milestones"
  ON milestones FOR SELECT
  USING (
    auth.user_role() = 'agency_user' AND 
    EXISTS (
      SELECT 1 FROM projects p 
      WHERE p.id = milestones.project_id 
      AND p.agency_id = auth.user_agency()
    )
  );

CREATE POLICY "Overwatch can view all milestones"
  ON milestones FOR SELECT
  USING (auth.user_role() = 'overwatch');

CREATE POLICY "Agency users can manage their project milestones"
  ON milestones FOR ALL
  USING (
    auth.user_role() = 'agency_user' AND 
    EXISTS (
      SELECT 1 FROM projects p 
      WHERE p.id = milestones.project_id 
      AND p.agency_id = auth.user_agency()
    )
  )
  WITH CHECK (
    auth.user_role() = 'agency_user' AND 
    EXISTS (
      SELECT 1 FROM projects p 
      WHERE p.id = milestones.project_id 
      AND p.agency_id = auth.user_agency()
    )
  );

-- Fund Flow table policies
CREATE POLICY "Centre admins can view all fund flows"
  ON fund_flow FOR SELECT
  USING (auth.user_role() = 'centre_admin');

CREATE POLICY "State officers can view fund flows for their state"
  ON fund_flow FOR SELECT
  USING (
    auth.user_role() = 'state_officer' AND 
    (
      to_entity_type = 'state' OR
      EXISTS (
        SELECT 1 FROM projects p 
        WHERE p.id = fund_flow.project_id 
        AND p.state_id = auth.user_state()
      )
    )
  );

CREATE POLICY "Agency users can view their fund flows"
  ON fund_flow FOR SELECT
  USING (
    auth.user_role() = 'agency_user' AND 
    (
      to_entity_id = auth.user_agency() OR
      EXISTS (
        SELECT 1 FROM projects p 
        WHERE p.id = fund_flow.project_id 
        AND p.agency_id = auth.user_agency()
      )
    )
  );

CREATE POLICY "Overwatch can view all fund flows"
  ON fund_flow FOR SELECT
  USING (auth.user_role() = 'overwatch');

CREATE POLICY "Centre admins can manage fund flows"
  ON fund_flow FOR ALL
  USING (auth.user_role() = 'centre_admin')
  WITH CHECK (auth.user_role() = 'centre_admin');

-- Audit Trail policies
CREATE POLICY "Overwatch can view all audit trails"
  ON audit_trail FOR SELECT
  USING (auth.user_role() = 'overwatch');

CREATE POLICY "Centre admins can view all audit trails"
  ON audit_trail FOR SELECT
  USING (auth.user_role() = 'centre_admin');

CREATE POLICY "Users can view their own audit trail"
  ON audit_trail FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "System can insert audit records"
  ON audit_trail FOR INSERT
  WITH CHECK (true);

-- Chat Channels policies
CREATE POLICY "Users can view channels they participate in"
  ON chat_channels FOR SELECT
  USING (auth.uid() = ANY(participants));

CREATE POLICY "Users can create channels"
  ON chat_channels FOR INSERT
  WITH CHECK (created_by = auth.uid());

-- Chat Messages policies
CREATE POLICY "Users can view messages in their channels"
  ON chat_messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM chat_channels 
      WHERE id = chat_messages.channel_id 
      AND auth.uid() = ANY(participants)
    )
  );

CREATE POLICY "Users can send messages to their channels"
  ON chat_messages FOR INSERT
  WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM chat_channels 
      WHERE id = chat_messages.channel_id 
      AND auth.uid() = ANY(participants)
    )
  );

CREATE POLICY "Users can update their own messages"
  ON chat_messages FOR UPDATE
  USING (sender_id = auth.uid())
  WITH CHECK (sender_id = auth.uid());

-- Tickets policies
CREATE POLICY "Users can view tickets they created"
  ON tickets FOR SELECT
  USING (created_by = auth.uid());

CREATE POLICY "Users can view tickets assigned to them"
  ON tickets FOR SELECT
  USING (assigned_to = auth.uid());

CREATE POLICY "Centre admins can view all tickets"
  ON tickets FOR SELECT
  USING (auth.user_role() = 'centre_admin');

CREATE POLICY "Overwatch can view all tickets"
  ON tickets FOR SELECT
  USING (auth.user_role() = 'overwatch');

CREATE POLICY "Users can create tickets"
  ON tickets FOR INSERT
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "Assigned users can update tickets"
  ON tickets FOR UPDATE
  USING (assigned_to = auth.uid() OR created_by = auth.uid())
  WITH CHECK (assigned_to = auth.uid() OR created_by = auth.uid());

-- Documents policies
CREATE POLICY "Users can view public documents"
  ON documents FOR SELECT
  USING (is_public = true);

CREATE POLICY "Users can view documents they uploaded"
  ON documents FOR SELECT
  USING (uploaded_by = auth.uid());

CREATE POLICY "Centre admins can view all documents"
  ON documents FOR SELECT
  USING (auth.user_role() = 'centre_admin');

CREATE POLICY "Users can upload documents"
  ON documents FOR INSERT
  WITH CHECK (uploaded_by = auth.uid());

-- Meetings policies
CREATE POLICY "Users can view meetings they organize"
  ON meetings FOR SELECT
  USING (organizer_id = auth.uid());

CREATE POLICY "Users can view meetings they're invited to"
  ON meetings FOR SELECT
  USING (auth.uid() = ANY(participants));

CREATE POLICY "Users can create meetings"
  ON meetings FOR INSERT
  WITH CHECK (organizer_id = auth.uid());

CREATE POLICY "Organizers can update their meetings"
  ON meetings FOR UPDATE
  USING (organizer_id = auth.uid())
  WITH CHECK (organizer_id = auth.uid());