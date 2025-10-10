# Database Migration Order Guide

## Important: Run Migrations in This Exact Order

The migrations must be run in a specific order because of table dependencies. Follow these steps carefully:

## Step 1: Enable Required Extensions

Run this FIRST before any other migrations:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;
```

## Step 2: Create Base Schema (if not already done)

If you haven't run the initial schema migration, run this:

```sql
-- Create states table
CREATE TABLE IF NOT EXISTS states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(10) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create agencies table
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

-- Create projects table
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

-- Create fund allocations table
CREATE TABLE IF NOT EXISTS fund_allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    amount DECIMAL(15,2) NOT NULL,
    allocated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Step 3: Run Advanced Features Migration

Now run the file: `supabase/migrations/20241010_add_advanced_features.sql`

This creates:
- project_flags
- project_milestones
- communication_channels
- communication_messages
- esign_documents
- esign_signatures
- esign_audit_trail

## Step 4: Run RLS Policies

Run the file: `supabase/migrations/20241010_add_advanced_features_rls.sql`

This sets up Row Level Security policies for all tables.

## Alternative: Run All-in-One Script

If you want to run everything at once, use this combined script in SQL Editor:

```sql
-- =====================================================
-- STEP 1: EXTENSIONS
-- =====================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- =====================================================
-- STEP 2: BASE TABLES
-- =====================================================
CREATE TABLE IF NOT EXISTS states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(10) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

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

CREATE TABLE IF NOT EXISTS fund_allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    amount DECIMAL(15,2) NOT NULL,
    allocated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- STEP 3: THEN RUN 20241010_add_advanced_features.sql
-- STEP 4: THEN RUN 20241010_add_advanced_features_rls.sql
-- =====================================================
```

## Troubleshooting

### Error: "relation 'users' does not exist"
**Solution**: Supabase's auth.users table exists by default. If you see this error, make sure you're using `auth.users` (with schema prefix) not just `users`.

### Error: "relation 'projects' does not exist"
**Solution**: Run Step 2 first to create base tables before advanced features.

### Error: "extension 'uuid-ossp' does not exist"
**Solution**: Run Step 1 to enable extensions.

### Error: "extension 'postgis' does not exist"
**Solution**: Enable PostGIS in Database > Extensions in Supabase dashboard, or run Step 1.

## Verification

After running all migrations, verify with:

```sql
-- Check all tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Should see:
-- agencies
-- communication_channels
-- communication_messages
-- esign_audit_trail
-- esign_documents
-- esign_signatures
-- fund_allocations
-- project_flags
-- project_milestones
-- projects
-- states
```

## Quick Start Script (Copy-Paste Ready)

For a fresh Supabase project, copy and paste this entire script into SQL Editor:

```sql
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- Base tables (if not exist)
-- [Include all base table creation from Step 2 above]

-- Then separately run:
-- 1. Content of 20241010_add_advanced_features.sql
-- 2. Content of 20241010_add_advanced_features_rls.sql
```

The complete ready-to-run script is in the next section of this guide.