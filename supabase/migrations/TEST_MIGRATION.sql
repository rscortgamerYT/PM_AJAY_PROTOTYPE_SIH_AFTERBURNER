-- =====================================================
-- COMPREHENSIVE SQL MIGRATION TEST SCRIPT
-- PM-AJAY Platform Database Testing
-- =====================================================
-- This script tests all aspects of the migration scripts
-- Run this AFTER executing both migration scripts
-- =====================================================

-- Set client encoding
SET client_encoding = 'UTF8';

-- =====================================================
-- TEST 1: PREREQUISITES CHECK
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 1: Checking Prerequisites';
    RAISE NOTICE '====================================================';
END $$;

-- Check PostgreSQL version
DO $$
DECLARE
    pg_version TEXT;
BEGIN
    SELECT version() INTO pg_version;
    RAISE NOTICE 'PostgreSQL Version: %', pg_version;
    
    IF (current_setting('server_version_num')::integer < 120000) THEN
        RAISE WARNING 'PostgreSQL version should be 12.0 or higher';
    ELSE
        RAISE NOTICE '✓ PostgreSQL version check passed';
    END IF;
END $$;

-- Check extensions
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp') THEN
        RAISE EXCEPTION '✗ FAILED: uuid-ossp extension not found';
    ELSE
        RAISE NOTICE '✓ uuid-ossp extension installed';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'postgis') THEN
        RAISE EXCEPTION '✗ FAILED: PostGIS extension not found';
    ELSE
        RAISE NOTICE '✓ PostGIS extension installed';
    END IF;
END $$;

-- =====================================================
-- TEST 2: TABLE STRUCTURE VALIDATION
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 2: Validating Table Structure';
    RAISE NOTICE '====================================================';
END $$;

-- Check all tables exist
DO $$
DECLARE
    expected_tables TEXT[] := ARRAY[
        'states', 'agencies', 'projects', 'fund_allocations',
        'project_flags', 'project_milestones',
        'communication_channels', 'communication_messages',
        'esign_documents', 'esign_signatures', 'esign_audit_trail'
    ];
    tbl_name TEXT;
    table_count INTEGER := 0;
BEGIN
    FOREACH tbl_name IN ARRAY expected_tables
    LOOP
        IF EXISTS (
            SELECT 1 FROM information_schema.tables t
            WHERE t.table_schema = 'public' AND t.table_name = tbl_name
        ) THEN
            table_count := table_count + 1;
            RAISE NOTICE '✓ Table exists: %', tbl_name;
        ELSE
            RAISE EXCEPTION '✗ FAILED: Table % not found', tbl_name;
        END IF;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Summary: % of % tables created', table_count, array_length(expected_tables, 1);
END $$;

-- =====================================================
-- TEST 3: FOREIGN KEY CONSTRAINTS
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 3: Validating Foreign Key Constraints';
    RAISE NOTICE '====================================================';
END $$;

DO $$
DECLARE
    fk_count INTEGER;
    expected_fks INTEGER := 15; -- Minimum expected FKs
BEGIN
    SELECT COUNT(*) INTO fk_count
    FROM information_schema.table_constraints
    WHERE constraint_type = 'FOREIGN KEY'
    AND table_schema = 'public';
    
    IF fk_count < expected_fks THEN
        RAISE WARNING 'Expected at least % foreign keys, found %', expected_fks, fk_count;
    ELSE
        RAISE NOTICE '✓ Foreign key constraints: % found', fk_count;
    END IF;
    
    -- Display all foreign keys
    FOR fk_count IN
        SELECT 1
        FROM information_schema.table_constraints tc
        WHERE tc.constraint_type = 'FOREIGN KEY'
        AND tc.table_schema = 'public'
        LIMIT 5
    LOOP
        NULL;
    END LOOP;
END $$;

-- =====================================================
-- TEST 4: CHECK CONSTRAINTS
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 4: Validating CHECK Constraints';
    RAISE NOTICE '====================================================';
END $$;

DO $$
DECLARE
    check_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO check_count
    FROM pg_constraint
    WHERE contype = 'c';
    
    RAISE NOTICE '✓ CHECK constraints found: %', check_count;
    
    -- Verify specific check constraints
    IF EXISTS (
        SELECT 1 FROM pg_constraint con
        JOIN pg_class rel ON con.conrelid = rel.oid
        WHERE rel.relname = 'project_flags'
        AND con.contype = 'c'
    ) THEN
        RAISE NOTICE '✓ project_flags CHECK constraints exist';
    END IF;
    
    IF EXISTS (
        SELECT 1 FROM pg_constraint con
        JOIN pg_class rel ON con.conrelid = rel.oid
        WHERE rel.relname = 'project_milestones'
        AND con.contype = 'c'
    ) THEN
        RAISE NOTICE '✓ project_milestones CHECK constraints exist';
    END IF;
END $$;

-- =====================================================
-- TEST 5: INDEXES
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 5: Validating Indexes';
    RAISE NOTICE '====================================================';
END $$;

DO $$
DECLARE
    index_count INTEGER;
    expected_indexes INTEGER := 31;
BEGIN
    SELECT COUNT(*) INTO index_count
    FROM pg_indexes
    WHERE schemaname = 'public'
    AND indexname NOT LIKE '%_pkey';
    
    RAISE NOTICE '✓ Non-primary key indexes: %', index_count;
    
    IF index_count < expected_indexes THEN
        RAISE WARNING 'Expected at least % indexes, found %', expected_indexes, index_count;
    END IF;
    
    -- Check for spatial index
    IF EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE schemaname = 'public'
        AND tablename = 'projects'
        AND indexdef LIKE '%GIST%location%'
    ) THEN
        RAISE NOTICE '✓ Spatial index on projects.location exists';
    ELSE
        RAISE WARNING '✗ Spatial index on projects.location not found';
    END IF;
    
    -- Check for GIN indexes
    IF EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE schemaname = 'public'
        AND indexdef LIKE '%GIN%'
    ) THEN
        RAISE NOTICE '✓ GIN indexes for array columns exist';
    END IF;
END $$;

-- =====================================================
-- TEST 6: TRIGGERS
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 6: Validating Triggers';
    RAISE NOTICE '====================================================';
END $$;

DO $$
DECLARE
    trigger_count INTEGER;
    expected_triggers INTEGER := 8;
BEGIN
    SELECT COUNT(*) INTO trigger_count
    FROM information_schema.triggers
    WHERE trigger_schema = 'public';
    
    IF trigger_count >= expected_triggers THEN
        RAISE NOTICE '✓ Triggers created: %', trigger_count;
    ELSE
        RAISE WARNING 'Expected at least % triggers, found %', expected_triggers, trigger_count;
    END IF;
    
    -- Check update_updated_at function
    IF EXISTS (
        SELECT 1 FROM pg_proc
        WHERE proname = 'update_updated_at_column'
    ) THEN
        RAISE NOTICE '✓ update_updated_at_column function exists';
    ELSE
        RAISE EXCEPTION '✗ FAILED: update_updated_at_column function not found';
    END IF;
END $$;

-- =====================================================
-- TEST 7: SAMPLE DATA
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 7: Validating Sample Data';
    RAISE NOTICE '====================================================';
END $$;

DO $$
DECLARE
    state_count INTEGER;
    agency_count INTEGER;
    project_count INTEGER;
    fund_count INTEGER;
BEGIN
    -- Check states
    SELECT COUNT(*) INTO state_count FROM states WHERE code = 'MH';
    IF state_count > 0 THEN
        RAISE NOTICE '✓ Sample state inserted: Maharashtra';
    ELSE
        RAISE WARNING '✗ Sample state not found';
    END IF;
    
    -- Check agencies
    SELECT COUNT(*) INTO agency_count FROM agencies 
    WHERE name = 'Maharashtra Public Works';
    IF agency_count > 0 THEN
        RAISE NOTICE '✓ Sample agency inserted: Maharashtra Public Works';
    ELSE
        RAISE WARNING '✗ Sample agency not found';
    END IF;
    
    -- Check projects
    SELECT COUNT(*) INTO project_count FROM projects 
    WHERE name = 'Highway Construction Project';
    IF project_count > 0 THEN
        RAISE NOTICE '✓ Sample project inserted: Highway Construction Project';
    ELSE
        RAISE WARNING '✗ Sample project not found';
    END IF;
    
    -- Check fund allocations
    SELECT COUNT(*) INTO fund_count FROM fund_allocations;
    IF fund_count > 0 THEN
        RAISE NOTICE '✓ Sample fund allocation inserted';
    ELSE
        RAISE WARNING '✗ Sample fund allocation not found';
    END IF;
    
    -- Check geometry data
    IF EXISTS (
        SELECT 1 FROM projects 
        WHERE location IS NOT NULL 
        AND ST_IsValid(location)
    ) THEN
        RAISE NOTICE '✓ Valid geometry data in projects';
    ELSE
        RAISE WARNING '✗ No valid geometry data found';
    END IF;
END $$;

-- =====================================================
-- TEST 8: ROW LEVEL SECURITY
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 8: Validating Row Level Security';
    RAISE NOTICE '====================================================';
END $$;

DO $$
DECLARE
    rls_tables TEXT[] := ARRAY[
        'project_flags', 'project_milestones',
        'communication_channels', 'communication_messages',
        'esign_documents', 'esign_signatures', 'esign_audit_trail'
    ];
    tbl_name TEXT;
    rls_enabled BOOLEAN;
    enabled_count INTEGER := 0;
BEGIN
    FOREACH tbl_name IN ARRAY rls_tables
    LOOP
        SELECT pg.rowsecurity INTO rls_enabled
        FROM pg_tables pg
        WHERE pg.schemaname = 'public'
        AND pg.tablename = tbl_name;
        
        IF rls_enabled THEN
            enabled_count := enabled_count + 1;
            RAISE NOTICE '✓ RLS enabled on: %', tbl_name;
        ELSE
            RAISE WARNING '✗ RLS not enabled on: %', tbl_name;
        END IF;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Summary: RLS enabled on % of % tables', enabled_count, array_length(rls_tables, 1);
END $$;

-- =====================================================
-- TEST 9: RLS POLICIES
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 9: Validating RLS Policies';
    RAISE NOTICE '====================================================';
END $$;

DO $$
DECLARE
    policy_count INTEGER;
    expected_policies INTEGER := 24;
    table_policy_count INTEGER;
    tbl_name TEXT;
BEGIN
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE schemaname = 'public';
    
    IF policy_count >= expected_policies THEN
        RAISE NOTICE '✓ Total RLS policies: %', policy_count;
    ELSE
        RAISE WARNING 'Expected at least % policies, found %', expected_policies, policy_count;
    END IF;
    
    -- Check policies per table
    FOR tbl_name, table_policy_count IN
        SELECT pg_pol.tablename, COUNT(*)
        FROM pg_policies pg_pol
        WHERE pg_pol.schemaname = 'public'
        GROUP BY pg_pol.tablename
        ORDER BY pg_pol.tablename
    LOOP
        RAISE NOTICE '  - %: % policies', tbl_name, table_policy_count;
    END LOOP;
END $$;

-- =====================================================
-- TEST 10: HELPER FUNCTIONS
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 10: Validating Helper Functions';
    RAISE NOTICE '====================================================';
END $$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'is_channel_participant'
    ) THEN
        RAISE NOTICE '✓ Function exists: is_channel_participant';
    ELSE
        RAISE WARNING '✗ Function not found: is_channel_participant';
    END IF;
    
    IF EXISTS (
        SELECT 1 FROM pg_proc WHERE proname = 'can_sign_document'
    ) THEN
        RAISE NOTICE '✓ Function exists: can_sign_document';
    ELSE
        RAISE WARNING '✗ Function not found: can_sign_document';
    END IF;
END $$;

-- =====================================================
-- TEST 11: DATA INTEGRITY
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 11: Testing Data Integrity';
    RAISE NOTICE '====================================================';
END $$;

-- Test foreign key relationships
DO $$
DECLARE
    orphan_count INTEGER;
BEGIN
    -- Check for orphaned projects (without valid agency)
    SELECT COUNT(*) INTO orphan_count
    FROM projects p
    WHERE NOT EXISTS (SELECT 1 FROM agencies a WHERE a.id = p.agency_id);
    
    IF orphan_count = 0 THEN
        RAISE NOTICE '✓ No orphaned projects';
    ELSE
        RAISE WARNING '✗ Found % orphaned projects', orphan_count;
    END IF;
    
    -- Check for orphaned agencies (without valid state)
    SELECT COUNT(*) INTO orphan_count
    FROM agencies a
    WHERE a.state_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM states s WHERE s.id = a.state_id);
    
    IF orphan_count = 0 THEN
        RAISE NOTICE '✓ No orphaned agencies';
    ELSE
        RAISE WARNING '✗ Found % orphaned agencies', orphan_count;
    END IF;
END $$;

-- =====================================================
-- TEST 12: PERFORMANCE CHECKS
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'TEST 12: Performance Checks';
    RAISE NOTICE '====================================================';
END $$;

-- Analyze table statistics
ANALYZE states;
ANALYZE agencies;
ANALYZE projects;
ANALYZE fund_allocations;
ANALYZE project_flags;
ANALYZE project_milestones;
ANALYZE communication_channels;
ANALYZE communication_messages;
ANALYZE esign_documents;
ANALYZE esign_signatures;
ANALYZE esign_audit_trail;

DO $$
BEGIN
    RAISE NOTICE '✓ Table statistics updated';
END $$;

-- =====================================================
-- FINAL SUMMARY
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
    RAISE NOTICE '           TEST EXECUTION COMPLETED';
    RAISE NOTICE '====================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Review the output above for any warnings or errors.';
    RAISE NOTICE '';
    RAISE NOTICE 'If all tests passed:';
    RAISE NOTICE '  ✓ Database schema is correctly configured';
    RAISE NOTICE '  ✓ RLS policies are properly applied';
    RAISE NOTICE '  ✓ Sample data is inserted';
    RAISE NOTICE '  ✓ Ready for application integration';
    RAISE NOTICE '';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '  1. Configure Supabase credentials in Flutter app';
    RAISE NOTICE '  2. Create test users in Supabase Auth';
    RAISE NOTICE '  3. Add role metadata to user profiles';
    RAISE NOTICE '  4. Test application with different user roles';
    RAISE NOTICE '';
    RAISE NOTICE '====================================================';
END $$;