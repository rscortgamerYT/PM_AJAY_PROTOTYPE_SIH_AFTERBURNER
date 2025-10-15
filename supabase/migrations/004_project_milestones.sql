-- Create project_milestones table
CREATE TABLE IF NOT EXISTS public.project_milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    milestone_number TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    target_amount DECIMAL(15, 2) NOT NULL DEFAULT 0,
    claimed_amount DECIMAL(15, 2) NOT NULL DEFAULT 0,
    approved_amount DECIMAL(15, 2) NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'notStarted',
    claim_status TEXT NOT NULL DEFAULT 'notClaimed',
    start_date TIMESTAMPTZ,
    target_date TIMESTAMPTZ,
    completion_date TIMESTAMPTZ,
    claim_submitted_date TIMESTAMPTZ,
    sequence_order INTEGER NOT NULL,
    dependencies TEXT[] DEFAULT '{}',
    deliverables JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_project_milestone UNIQUE (project_id, milestone_number),
    CONSTRAINT valid_status CHECK (status IN ('notStarted', 'inProgress', 'completed', 'delayed', 'blocked')),
    CONSTRAINT valid_claim_status CHECK (claim_status IN ('notClaimed', 'claimed', 'underReview', 'approved', 'rejected'))
);

-- Create index for efficient querying
CREATE INDEX IF NOT EXISTS idx_project_milestones_project_id ON public.project_milestones(project_id);
CREATE INDEX IF NOT EXISTS idx_project_milestones_status ON public.project_milestones(status);
CREATE INDEX IF NOT EXISTS idx_project_milestones_claim_status ON public.project_milestones(claim_status);
CREATE INDEX IF NOT EXISTS idx_project_milestones_sequence ON public.project_milestones(project_id, sequence_order);

-- Enable RLS
ALTER TABLE public.project_milestones ENABLE ROW LEVEL SECURITY;

-- RLS Policies for project_milestones

-- Public read access for completed milestones
CREATE POLICY "Public users can view completed milestones"
    ON public.project_milestones
    FOR SELECT
    USING (status = 'completed');

-- Authenticated users can view all milestones
CREATE POLICY "Authenticated users can view all milestones"
    ON public.project_milestones
    FOR SELECT
    TO authenticated
    USING (true);

-- Agency users can create and update their project milestones
CREATE POLICY "Agency users can manage their project milestones"
    ON public.project_milestones
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.projects p
            WHERE p.id = project_milestones.project_id
            AND p.agency_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.projects p
            WHERE p.id = project_milestones.project_id
            AND p.agency_id = auth.uid()
        )
    );

-- State and Centre users can view and update milestones
CREATE POLICY "State users can view and approve milestones"
    ON public.project_milestones
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role IN ('state', 'centre')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users u
            WHERE u.id = auth.uid()
            AND u.role IN ('state', 'centre')
        )
    );

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_project_milestones_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER update_project_milestones_updated_at
    BEFORE UPDATE ON public.project_milestones
    FOR EACH ROW
    EXECUTE FUNCTION update_project_milestones_updated_at();

-- Insert demo data for existing projects
INSERT INTO public.project_milestones (project_id, milestone_number, name, description, target_amount, claimed_amount, approved_amount, status, claim_status, sequence_order, start_date, target_date, completion_date, claim_submitted_date)
SELECT 
    p.id,
    'M-' || gs.seq,
    'Milestone ' || gs.seq,
    CASE gs.seq
        WHEN 1 THEN 'Project initiation and planning'
        WHEN 2 THEN 'Site preparation and foundation work'
        WHEN 3 THEN 'Main construction phase'
        WHEN 4 THEN 'Infrastructure installation'
        WHEN 5 THEN 'Final inspection and handover'
        ELSE 'Additional milestone'
    END,
    (p.total_budget / 5.0)::DECIMAL(15, 2),
    CASE 
        WHEN gs.seq <= 2 THEN (p.total_budget / 5.0)::DECIMAL(15, 2)
        ELSE 0
    END,
    CASE 
        WHEN gs.seq <= 2 THEN (p.total_budget / 5.0)::DECIMAL(15, 2)
        ELSE 0
    END,
    CASE 
        WHEN gs.seq <= 2 THEN 'completed'
        WHEN gs.seq = 3 THEN 'inProgress'
        ELSE 'notStarted'
    END,
    CASE 
        WHEN gs.seq <= 2 THEN 'approved'
        WHEN gs.seq = 3 THEN 'claimed'
        ELSE 'notClaimed'
    END,
    gs.seq,
    p.start_date + (INTERVAL '30 days' * (gs.seq - 1)),
    p.start_date + (INTERVAL '30 days' * gs.seq),
    CASE 
        WHEN gs.seq <= 2 THEN p.start_date + (INTERVAL '30 days' * gs.seq)
        ELSE NULL
    END,
    CASE 
        WHEN gs.seq <= 3 THEN p.start_date + (INTERVAL '30 days' * gs.seq) + INTERVAL '2 days'
        ELSE NULL
    END
FROM public.projects p
CROSS JOIN generate_series(1, 5) AS gs(seq)
WHERE p.total_budget IS NOT NULL
ON CONFLICT (project_id, milestone_number) DO NOTHING;

-- Grant permissions
GRANT SELECT ON public.project_milestones TO anon;
GRANT ALL ON public.project_milestones TO authenticated;
GRANT ALL ON public.project_milestones TO service_role;