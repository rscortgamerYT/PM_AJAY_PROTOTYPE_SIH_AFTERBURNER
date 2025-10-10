# Fund Flow System - Deployment Guide

**Date:** October 10, 2025  
**System:** PM-AJAY Platform - Fund Flow Visualization Module  
**Version:** 1.0.0

---

## Quick Start: Import Demo Data to Supabase

### Prerequisites

- ✅ Supabase project created: `https://zkixtbwolqbafehlouyg.supabase.co`
- ✅ Database migrations 001 & 002 applied
- ✅ PostGIS extension enabled
- ✅ RLS policies active

### Step 1: Apply Demo Data Migration

**Option A: Using Supabase Dashboard**

1. Open Supabase Dashboard: https://supabase.com/dashboard/project/zkixtbwolqbafehlouyg
2. Navigate to **SQL Editor**
3. Copy contents of [`supabase/migrations/003_seed_demo_data.sql`](supabase/migrations/003_seed_demo_data.sql:1)
4. Paste into SQL Editor
5. Click **Run** button
6. Verify success message

**Option B: Using Supabase CLI**

```bash
# Navigate to project directory
cd "c:/Users/royal/Desktop/SIH NEW/PROTOTYPE"

# Run migration
supabase migration up

# Or apply specific migration
supabase db push supabase/migrations/003_seed_demo_data.sql
```

**Option C: Using psql**

```bash
# Connect to Supabase database
psql "postgresql://postgres:[YOUR_PASSWORD]@db.zkixtbwolqbafehlouyg.supabase.co:5432/postgres"

# Run migration file
\i supabase/migrations/003_seed_demo_data.sql
```

### Step 2: Verify Data Import

Run verification queries in SQL Editor:

```sql
-- Check entity counts
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

-- Expected Results:
-- States: 5
-- Districts: 5
-- Users: 8
-- Agencies: 4
-- Projects: 5
-- Fund Flow Transactions: 15
-- Milestones: 5
```

### Step 3: Test Fund Flow Queries

```sql
-- Total fund allocation by state
SELECT 
    s.name as state_name,
    COUNT(ff.id) as transaction_count,
    SUM(ff.amount) as total_amount
FROM states s
LEFT JOIN fund_flow ff ON ff.to_entity_id = s.id AND ff.to_entity_type = 'state'
GROUP BY s.name
ORDER BY total_amount DESC;

-- Fund utilization summary
SELECT 
    status,
    COUNT(*) as count,
    SUM(amount) as total_amount,
    ROUND(SUM(amount) * 100.0 / (SELECT SUM(amount) FROM fund_flow), 2) as percentage
FROM fund_flow
GROUP BY status
ORDER BY total_amount DESC;

-- Agency-wise fund distribution
SELECT 
    a.name as agency_name,
    COUNT(ff.id) as transaction_count,
    SUM(ff.amount) as total_received
FROM agencies a
LEFT JOIN fund_flow ff ON ff.to_entity_id = a.id AND ff.to_entity_type = 'agency'
GROUP BY a.name
ORDER BY total_received DESC;
```

---

## Demo Data Overview

### 5 States with Complete Geographic Data

1. **Delhi** - 2 districts, 1 agency, 2 projects
   - Total Allocation: ₹80 Cr (Adarsh Gram + GIA)
   
2. **Maharashtra** - 2 districts, 2 agencies, 2 projects
   - Total Allocation: ₹120 Cr (Adarsh Gram + Hostel)
   
3. **Karnataka** - 1 district, 1 agency, 1 project
   - Total Allocation: ₹60 Cr (Adarsh Gram)
   
4. **Uttar Pradesh** - Ready for expansion
5. **Tamil Nadu** - Ready for expansion

### 8 Demo Users (Login Ready)

**Centre Level:**
- `admin.centre@pmajay.gov.in` - Centre Admin (Full access)
- `finance.centre@pmajay.gov.in` - Centre Finance Director

**State Level:**
- `officer.delhi@pmajay.gov.in` - Delhi State Officer
- `officer.maharashtra@pmajay.gov.in` - Maharashtra State Officer
- `officer.karnataka@pmajay.gov.in` - Karnataka State Officer

**Agency Level:**
- `dda@delhi.gov.in` - DDA Project Manager
- `mud@maharashtra.gov.in` - Mumbai Urban Dev Manager

**Oversight:**
- `overwatch@pmajay.gov.in` - Chief Monitoring Officer

### 15 Fund Transactions Covering All Stages

**Stage Breakdown:**
- Centre → State: 5 transactions (₹260 Cr total)
- State → Agency: 5 transactions (₹260 Cr total)
- Agency → Project: 5 transactions (₹201 Cr utilized)

**Status Distribution:**
- Completed: 8 transactions
- Transferred: 2 transactions
- Utilized: 4 transactions
- Pending UC: 1 transaction

---

## Frontend Integration

### Step 1: Configure Backend Connection

The frontend is already configured to connect to Supabase:

**Configuration File:** [`lib/core/config/supabase_config.dart`](lib/core/config/supabase_config.dart:1)

```dart
class SupabaseConfig {
  static const String url = 'https://zkixtbwolqbafehlouyg.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
  
  // All table names and channels pre-configured
}
```

### Step 2: Run Demo Page

1. Open Flutter project
2. Run app: `flutter run`
3. Navigate to Fund Flow Demo Page
4. Test all 8 widgets with live data

**Demo Page Location:** [`lib/features/fund_flow/presentation/pages/fund_flow_demo_page.dart`](lib/features/fund_flow/presentation/pages/fund_flow_demo_page.dart:1)

### Step 3: Switch from Mock to Live Data

**Current:** Uses mock data from [`MockFundFlowData`](lib/features/fund_flow/data/mock_fund_flow_data.dart:1)

**To Enable Live Data:** Create a new service class:

```dart
// lib/features/fund_flow/data/fund_flow_repository.dart
class FundFlowRepository {
  final SupabaseClient _client = Supabase.instance.client;
  
  Stream<List<FundTransaction>> getTransactionsStream() {
    return _client
        .from('fund_flow')
        .stream(primaryKey: ['id'])
        .order('transaction_date', ascending: false)
        .map((data) => data.map((json) => 
            FundTransaction.fromJson(json)).toList());
  }
  
  Future<List<StateModel>> getStates() async {
    final response = await _client.from('states').select();
    return response.map((json) => StateModel.fromJson(json)).toList();
  }
  
  Future<List<AgencyModel>> getAgencies() async {
    final response = await _client.from('agencies').select();
    return response.map((json) => AgencyModel.fromJson(json)).toList();
  }
}
```

---

## Testing Checklist

### ✅ Database Level

- [ ] Run migration 003_seed_demo_data.sql
- [ ] Verify entity counts match expectations
- [ ] Test spatial queries (state boundaries, agency locations)
- [ ] Validate RLS policies with different user roles
- [ ] Check foreign key relationships

### ✅ API Level

- [ ] Test fund_flow table queries
- [ ] Test real-time subscriptions
- [ ] Validate RLS filtering by user role
- [ ] Test aggregate queries (sum, count, group by)
- [ ] Check geospatial queries with PostGIS

### ✅ Frontend Level

- [ ] Load demo page successfully
- [ ] All 8 widgets render correctly
- [ ] Interactive features work (clicks, hovers)
- [ ] Animations run smoothly
- [ ] Data calculations accurate
- [ ] Export functions work

---

## Production Deployment

### 1. Database Setup

```sql
-- Create production database
-- Apply migrations in order:
-- 001_initial_schema.sql
-- 002_rls_policies.sql
-- 003_seed_demo_data.sql (or use real data)
```

### 2. Environment Configuration

```dart
// lib/core/config/environment.dart
class Environment {
  static const bool isProduction = true; // Set to true for production
  static const String supabaseUrl = 'YOUR_PRODUCTION_URL';
  static const String supabaseAnonKey = 'YOUR_PRODUCTION_KEY';
}
```

### 3. Security Hardening

- Enable RLS on all tables ✅ (Already done)
- Configure API rate limiting
- Set up monitoring and alerts
- Enable database backups
- Configure CORS for production domains

### 4. Performance Optimization

- Create database indexes ✅ (Already created)
- Enable connection pooling
- Configure CDN for static assets
- Implement caching strategy

---

## Monitoring & Maintenance

### Key Metrics to Monitor

1. **Database Performance**
   - Query execution time
   - Connection pool usage
   - Table sizes and growth

2. **API Performance**
   - Request latency
   - Error rates
   - Rate limit hits

3. **Application Metrics**
   - Widget render times
   - User interaction patterns
   - Export usage

### Recommended Tools

- Supabase Dashboard Analytics
- Sentry for error tracking
- Firebase Performance Monitoring
- Custom logging service

---

## Troubleshooting

### Issue: Migration Fails

**Solution:**
1. Check if previous migrations applied: `SELECT * FROM schema_migrations;`
2. Verify PostGIS extension: `SELECT PostGIS_Version();`
3. Check for data conflicts: Truncate tables if needed

### Issue: RLS Blocks Queries

**Solution:**
1. Verify user authentication
2. Check user role in users table
3. Test with overwatch role for debugging
4. Review RLS policies in migration 002

### Issue: Spatial Queries Fail

**Solution:**
1. Ensure PostGIS extension enabled
2. Verify geometry column types
3. Check SRID (should be 4326)
4. Rebuild spatial indexes if needed

---

## Next Steps

1. ✅ **Import Demo Data** - Run migration 003
2. ✅ **Test Fund Flow Widgets** - Verify all 8 widgets
3. ⚠️ **Configure Authentication** - Set up user login
4. ⚠️ **Enable Real-time Features** - Test subscriptions
5. ⚠️ **Load Testing** - Test with 10,000+ transactions
6. ⚠️ **User Acceptance Testing** - Get feedback from stakeholders

---

## Support & Documentation

**Technical Documentation:**
- Database Schema: [`supabase/migrations/001_initial_schema.sql`](supabase/migrations/001_initial_schema.sql:1)
- RLS Policies: [`supabase/migrations/002_rls_policies.sql`](supabase/migrations/002_rls_policies.sql:1)
- Production Report: [`PRODUCTION_READINESS_REPORT.md`](PRODUCTION_READINESS_REPORT.md:1)

**Demo Resources:**
- Mock Data: [`lib/features/fund_flow/data/mock_fund_flow_data.dart`](lib/features/fund_flow/data/mock_fund_flow_data.dart:1)
- Demo Page: [`lib/features/fund_flow/presentation/pages/fund_flow_demo_page.dart`](lib/features/fund_flow/presentation/pages/fund_flow_demo_page.dart:1)

**Contact:**
- Technical Lead: Lyzo Development Team
- Project: PM-AJAY Agency Mapping Platform

---

**Deployment Status:** Ready for Production Testing  
**Last Updated:** October 10, 2025