# SQL Migration Execution Guide

## Overview
This guide provides step-by-step instructions for executing and validating the PM-AJAY platform database migrations.

---

## Prerequisites

### 1. Supabase Project Setup
- ✅ Active Supabase project
- ✅ Access to SQL Editor in Supabase Dashboard
- ✅ PostgreSQL 12+ (included in Supabase)
- ✅ PostGIS extension available (included in Supabase)

### 2. Required Permissions
- Database owner or superuser role
- Ability to create extensions
- Ability to enable RLS

---

## Execution Steps

### Step 1: Backup (If Existing Database)

If you have existing data, create a backup first:

```sql
-- In Supabase SQL Editor, export your data first
-- Go to Database > Backups in Supabase Dashboard
```

### Step 2: Execute Base Setup Script

1. Open Supabase Dashboard → SQL Editor
2. Create new query
3. Copy **entire contents** of [`00_complete_setup.sql`](00_complete_setup.sql)
4. Paste into SQL Editor
5. Click **Run** (or press Ctrl+Enter)

**Expected Output:**
```
NOTICE: ====================================================
NOTICE: Database setup completed successfully!
NOTICE: Next step: Run the RLS policies script
NOTICE: ====================================================
```

**Execution Time:** ~2-5 seconds

### Step 3: Verify Base Setup

Run this quick verification:

```sql
-- Check table count
SELECT COUNT(*) as table_count
FROM information_schema.tables 
WHERE table_schema = 'public';
-- Expected: 11 tables

-- Check sample data
SELECT 
    (SELECT COUNT(*) FROM states) as states,
    (SELECT COUNT(*) FROM agencies) as agencies,
    (SELECT COUNT(*) FROM projects) as projects;
-- Expected: 1, 1, 1
```

### Step 4: Execute RLS Policies Script

1. In SQL Editor, create new query
2. Copy **entire contents** of [`20241010_add_advanced_features_rls.sql`](20241010_add_advanced_features_rls.sql)
3. Paste into SQL Editor
4. Click **Run**

**Expected Output:**
```
-- Multiple statements executed successfully
-- No error messages
```

**Execution Time:** ~1-3 seconds

### Step 5: Verify RLS Setup

```sql
-- Check RLS enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND rowsecurity = true;
-- Expected: 7 tables

-- Check policy count
SELECT COUNT(*) as policy_count
FROM pg_policies
WHERE schemaname = 'public';
-- Expected: 24+ policies
```

### Step 6: Run Comprehensive Tests

1. Create new query in SQL Editor
2. Copy **entire contents** of [`TEST_MIGRATION.sql`](TEST_MIGRATION.sql)
3. Paste and click **Run**

**Expected Output:**
```
====================================================
TEST 1: Checking Prerequisites
====================================================
✓ PostgreSQL version check passed
✓ uuid-ossp extension installed
✓ PostGIS extension installed

====================================================
TEST 2: Validating Table Structure
====================================================
✓ Table exists: states
✓ Table exists: agencies
...
Summary: 11 of 11 tables created

[... more test results ...]

====================================================
           TEST EXECUTION COMPLETED
====================================================
```

---

## Troubleshooting

### Issue 1: Extension Already Exists

**Error:**
```
ERROR: extension "uuid-ossp" already exists
```

**Solution:** This is harmless. The script uses `IF NOT EXISTS` clause. Continue execution.

### Issue 2: Table Already Exists

**Error:**
```
ERROR: relation "states" already exists
```

**Solution:** 
- If intentional (re-running): Drop tables first (see Reset section)
- If unintentional: Check if you're in correct database

### Issue 3: Permission Denied

**Error:**
```
ERROR: permission denied to create extension
```

**Solution:** Ensure you're using service_role key or database owner account.

### Issue 4: RLS Policy Conflicts

**Error:**
```
ERROR: policy "policy_name" already exists
```

**Solution:**
```sql
-- Drop existing policy
DROP POLICY IF EXISTS policy_name ON table_name;

-- Then re-run the RLS script
```

### Issue 5: Foreign Key Violation

**Error:**
```
ERROR: insert or update on table violates foreign key constraint
```

**Solution:** Ensure base setup script completed successfully before RLS script.

---

## Reset Database (If Needed)

⚠️ **WARNING:** This will delete ALL data!

```sql
-- Drop all tables (cascading will handle foreign keys)
DROP TABLE IF EXISTS esign_audit_trail CASCADE;
DROP TABLE IF EXISTS esign_signatures CASCADE;
DROP TABLE IF EXISTS esign_documents CASCADE;
DROP TABLE IF EXISTS communication_messages CASCADE;
DROP TABLE IF EXISTS communication_channels CASCADE;
DROP TABLE IF EXISTS project_milestones CASCADE;
DROP TABLE IF EXISTS project_flags CASCADE;
DROP TABLE IF EXISTS fund_allocations CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS agencies CASCADE;
DROP TABLE IF EXISTS states CASCADE;

-- Drop functions
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS is_channel_participant(UUID, UUID);
DROP FUNCTION IF EXISTS can_sign_document(UUID, UUID);

-- Now re-run migration scripts
```

---

## Validation Checklist

After completing all steps, verify:

- [ ] All 11 tables created
- [ ] Sample data inserted (1 state, 1 agency, 1 project)
- [ ] All foreign key constraints present
- [ ] All indexes created (31+ indexes)
- [ ] All triggers working (8 triggers)
- [ ] RLS enabled on 7 tables
- [ ] 24+ RLS policies created
- [ ] 2 helper functions created
- [ ] No error messages in execution
- [ ] Test script runs successfully

---

## Post-Migration Setup

### 1. Configure Supabase in Flutter App

Update [`lib/core/config/supabase_config.dart`](../../lib/core/config/supabase_config.dart):

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 2. Create Test Users

In Supabase Dashboard → Authentication → Users:

#### Centre User
```json
{
  "email": "centre@pmajay.gov.in",
  "password": "Test@123",
  "user_metadata": {
    "role": "centre"
  }
}
```

#### State User
```json
{
  "email": "state@maharashtra.gov.in",
  "password": "Test@123",
  "user_metadata": {
    "role": "state",
    "state_id": "<maharashtra_state_uuid>"
  }
}
```

#### Agency User
```json
{
  "email": "agency@mpw.gov.in",
  "password": "Test@123",
  "user_metadata": {
    "role": "agency"
  }
}
```

**Note:** For agency users, the user ID must match the agency ID in the database for RLS policies to work correctly.

#### Overwatch User
```json
{
  "email": "overwatch@pmajay.gov.in",
  "password": "Test@123",
  "user_metadata": {
    "role": "overwatch"
  }
}
```

### 3. Get State ID for Test Data

```sql
-- In SQL Editor
SELECT id, name, code FROM states WHERE code = 'MH';
-- Copy the UUID for state_id in user metadata
```

### 4. Verify RLS Policies Work

Test with different user roles:

```sql
-- Set session to simulate centre user
SET request.jwt.claims = '{"sub": "centre-user-uuid", "user_metadata": {"role": "centre"}}';

-- Try to query projects
SELECT COUNT(*) FROM projects;
-- Should return all projects

-- Set session to simulate state user
SET request.jwt.claims = '{"sub": "state-user-uuid", "user_metadata": {"role": "state", "state_id": "state-uuid"}}';

-- Try to query projects
SELECT COUNT(*) FROM projects;
-- Should return only state's projects
```

---

## Performance Optimization

After migration, run:

```sql
-- Update table statistics
ANALYZE;

-- Vacuum tables
VACUUM ANALYZE;
```

---

## Monitoring

### Check Database Size
```sql
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Check Active Connections
```sql
SELECT 
    datname,
    COUNT(*) as connections
FROM pg_stat_activity
GROUP BY datname;
```

### Monitor Query Performance
Enable slow query logging in Supabase Dashboard → Database → Settings

---

## Next Steps

1. ✅ Execute migration scripts
2. ✅ Run validation tests
3. ✅ Configure Flutter app
4. ✅ Create test users
5. 🔄 Test authentication flow
6. 🔄 Test role-based access
7. 🔄 Verify map functionality
8. 🔄 Test all dashboards
9. 🔄 Verify real-time features
10. 🔄 Test advanced features

---

## Support

### Common Commands Reference

```sql
-- List all tables
\dt

-- Describe table structure
\d table_name

-- List all functions
\df

-- List all policies
\dp

-- Check RLS status
SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';

-- View policy definitions
SELECT * FROM pg_policies WHERE schemaname = 'public';
```

### Getting Help

1. Check error messages carefully
2. Review [`SQL_TEST_RESULTS.md`](SQL_TEST_RESULTS.md) for detailed analysis
3. Consult Supabase documentation: https://supabase.com/docs
4. Check PostGIS documentation: https://postgis.net/docs/

---

## Success Criteria

Migration is successful when:

✅ All scripts execute without errors  
✅ Test script shows all tests passed  
✅ Sample data is queryable  
✅ RLS policies enforce access control  
✅ Flutter app connects successfully  
✅ Different user roles see appropriate data  
✅ Real-time subscriptions work  
✅ Map displays project locations correctly

---

## Important Notes

1. **Always test in development first** - Never run migrations directly in production without testing
2. **Backup before migration** - Always have a backup of production data
3. **Monitor performance** - Watch for slow queries after enabling RLS
4. **User metadata is critical** - Ensure all users have proper role and state_id metadata
5. **Agency user IDs** - Agency users must have IDs matching agency table entries

---

## Timeline

| Task | Estimated Time |
|------|----------------|
| Execute base setup | 2-5 seconds |
| Execute RLS policies | 1-3 seconds |
| Run tests | 5-10 seconds |
| Create test users | 2-3 minutes |
| Configure Flutter app | 1-2 minutes |
| **Total** | **~5-10 minutes** |

---

## Completion Checklist

- [ ] Base setup script executed successfully
- [ ] RLS policies script executed successfully
- [ ] Test script shows all tests passed
- [ ] Sample data verified
- [ ] Test users created with proper metadata
- [ ] Supabase credentials configured in Flutter app
- [ ] Flutter app connects to database
- [ ] Authentication works for all roles
- [ ] Map displays correctly
- [ ] All dashboards accessible by appropriate roles

---

**🎉 Once all items are checked, your database is ready for production use!**