# Supabase Setup Guide for PM-AJAY Platform

## Prerequisites
- Supabase account (https://supabase.com)
- Supabase CLI installed (optional, but recommended)

## Step 1: Create Supabase Project

1. Go to https://supabase.com and sign in
2. Click "New Project"
3. Fill in project details:
   - **Name**: PM-AJAY-Platform
   - **Database Password**: Choose a strong password (save it!)
   - **Region**: Choose closest to your users
4. Click "Create new project"
5. Wait for project to be provisioned (2-3 minutes)

## Step 2: Get Project Credentials

1. In Supabase dashboard, go to **Settings** > **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)
   - **service_role key** (starts with `eyJ...`) - Keep this SECRET!

## Step 3: Configure Flutter App

1. Open `lib/core/config/supabase_config.dart`
2. Update the configuration:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
}
```

3. **IMPORTANT**: Never commit the service_role key to version control!

## Step 4: Enable PostGIS Extension

1. In Supabase dashboard, go to **Database** > **Extensions**
2. Search for "postgis"
3. Click the toggle to enable PostGIS
4. Wait for activation (30 seconds)

## Step 5: Run Database Migrations

### Option A: Using Supabase Dashboard (Easiest)

1. Go to **SQL Editor** in Supabase dashboard
2. Click "New Query"
3. Copy contents of `supabase/migrations/001_initial_schema.sql`
4. Paste and click "Run"
5. Repeat for:
   - `002_rls_policies.sql`
   - `003_spatial_functions.sql`
   - `20241010_add_advanced_features.sql`
   - `20241010_add_advanced_features_rls.sql`

### Option B: Using Supabase CLI

1. Install Supabase CLI:
```bash
npm install -g supabase
```

2. Login to Supabase:
```bash
supabase login
```

3. Link your project:
```bash
supabase link --project-ref YOUR_PROJECT_REF
```

4. Push migrations:
```bash
supabase db push
```

## Step 6: Set Up Storage Buckets

1. Go to **Storage** in Supabase dashboard
2. Create the following buckets:

### Bucket: project-documents
- Click "New bucket"
- Name: `project-documents`
- Public: **No** (private)
- Click "Create bucket"

### Bucket: milestone-evidence
- Click "New bucket"
- Name: `milestone-evidence`
- Public: **No** (private)
- Click "Create bucket"

### Bucket: esign-documents
- Click "New bucket"
- Name: `esign-documents`
- Public: **No** (private)
- Click "Create bucket"

### Bucket: communication-attachments
- Click "New bucket"
- Name: `communication-attachments`
- Public: **No** (private)
- Click "Create bucket"

3. Set up Storage Policies for each bucket:

Go to each bucket > Policies > New Policy:

**Read Policy** (for authenticated users):
```sql
(auth.uid() IS NOT NULL)
```

**Upload Policy** (for authenticated users):
```sql
(auth.uid() IS NOT NULL)
```

**Update Policy** (owner only):
```sql
(auth.uid()::text = (storage.foldername(name))[1])
```

**Delete Policy** (owner only):
```sql
(auth.uid()::text = (storage.foldername(name))[1])
```

## Step 7: Enable Realtime

1. Go to **Database** > **Replication**
2. Enable replication for these tables:
   - `communication_messages`
   - `communication_channels`
   - `project_flags`
   - `project_milestones`
   - `esign_documents`
   - `esign_signatures`

## Step 8: Create Test Users

1. Go to **Authentication** > **Users**
2. Create test users for each role:

### Centre User
- Email: `centre@test.com`
- Password: `Test123!`
- User Metadata:
```json
{
  "role": "centre",
  "name": "Centre Officer"
}
```

### State User
- Email: `state@test.com`
- Password: `Test123!`
- User Metadata:
```json
{
  "role": "state",
  "state_id": "state-001",
  "name": "State Officer"
}
```

### Agency User
- Email: `agency@test.com`
- Password: `Test123!`
- User Metadata:
```json
{
  "role": "agency",
  "agency_id": "agency-001",
  "name": "Agency Officer"
}
```

### Overwatch User
- Email: `overwatch@test.com`
- Password: `Test123!`
- User Metadata:
```json
{
  "role": "overwatch",
  "name": "Overwatch Officer"
}
```

## Step 9: Insert Sample Data (Optional)

Run the following SQL in **SQL Editor**:

```sql
-- Insert sample state
INSERT INTO states (id, name, code) VALUES
('state-001', 'Maharashtra', 'MH');

-- Insert sample agency
INSERT INTO agencies (id, name, state_id, type) VALUES
('agency-001', 'Maharashtra Public Works', 'state-001', 'state');

-- Insert sample project
INSERT INTO projects (
  id, name, description, agency_id, state_id, 
  location, status, budget_allocated
) VALUES (
  'project-001',
  'Highway Construction Project',
  'Construction of 50km highway',
  'agency-001',
  'state-001',
  ST_SetSRID(ST_MakePoint(72.8777, 19.0760), 4326),
  'in_progress',
  50000000
);

-- Insert sample fund allocation
INSERT INTO fund_allocations (
  id, project_id, amount, allocated_at, status
) VALUES (
  gen_random_uuid(),
  'project-001',
  25000000,
  NOW(),
  'approved'
);
```

## Step 10: Verify Setup

1. Open your Flutter app at http://localhost:8080
2. Try logging in with test credentials
3. Verify you can:
   - See the appropriate dashboard for your role
   - View projects on the map
   - Access communication channels
   - Create flags (as Overwatch)
   - Submit milestones (as Agency)

## Troubleshooting

### Problem: "Failed to connect to Supabase"
**Solution**: Check that your Project URL and Anon Key are correctly configured in `supabase_config.dart`

### Problem: "RLS policy violation"
**Solution**: Ensure all RLS policies are properly applied by running the RLS migration scripts

### Problem: "PostGIS functions not found"
**Solution**: Enable PostGIS extension in Database > Extensions

### Problem: "Storage bucket not found"
**Solution**: Create all required storage buckets as described in Step 6

### Problem: "Realtime not working"
**Solution**: Enable replication for tables in Database > Replication

## Security Checklist

- [ ] PostGIS extension enabled
- [ ] All migrations applied successfully
- [ ] RLS enabled on all tables
- [ ] Storage policies configured
- [ ] Test users created with proper roles
- [ ] Supabase credentials added to Flutter config
- [ ] Service role key kept secret (not in code)
- [ ] Realtime replication enabled

## Next Steps

After completing this setup:
1. Test all features with different user roles
2. Configure production Supabase project
3. Set up environment variables for different environments
4. Configure CI/CD pipeline for automatic migrations
5. Set up monitoring and logging

## Support

For issues:
- Supabase Documentation: https://supabase.com/docs
- Supabase Discord: https://discord.supabase.com
- Project Issues: Create an issue in your repository

Your PM-AJAY platform should now be fully operational with Supabase! 🎉