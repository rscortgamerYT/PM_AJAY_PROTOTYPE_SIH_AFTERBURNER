/// Supabase Backend Connection Guide
/// 
/// This file provides comprehensive instructions for connecting all widgets
/// to the live Supabase backend, replacing mock data with real-time streams.

/*
=============================================================================
SUPABASE BACKEND CONNECTION CHECKLIST
=============================================================================

Phase 1: Database Verification
-------------------------------
□ Verify all tables exist in Supabase
□ Confirm RLS policies are enabled
□ Test spatial functions (PostGIS)
□ Validate indexes are created
□ Check storage buckets configuration

Phase 2: Authentication Setup
------------------------------
□ Configure Supabase Auth in app
□ Test user login/signup flows
□ Verify role assignment works
□ Test JWT token refresh
□ Validate session management

Phase 3: Data Migration
-----------------------
□ Populate states table with real data
□ Import district boundaries
□ Add agency information
□ Load project data
□ Import fund flow transactions
□ Upload initial documents

Phase 4: Widget Connection (Priority Order)
--------------------------------------------

HIGH PRIORITY - Core Data Flows:
□ 1. DashboardAnalyticsService - Replace mock with real streams
□ 2. National Heatmap - Connect to state_performance_view
□ 3. Fund Flow Widgets - Link to fund_flow table
□ 4. District Performance Map - Use spatial queries
□ 5. Agency Dashboard - Connect project streams

MEDIUM PRIORITY - Interactive Features:
□ 6. Communication Hub - Enable real-time messaging
□ 7. Milestone Claims - Connect submission workflow
□ 8. Request Review Panel - Link approval system
□ 9. Audit Trail - Enable blockchain logging
□ 10. Compliance Scoreboard - Real-time scoring

LOW PRIORITY - Analytics:
□ 11. Predictive Analytics - Connect ML models
□ 12. Collaboration Network - Real partnership data
□ 13. Performance Analytics - Live KPI tracking
□ 14. Risk Assessment - Real-time risk scoring
□ 15. Open Data Explorer - Public data queries

=============================================================================
DETAILED CONNECTION INSTRUCTIONS
=============================================================================

1. DASHBOARD ANALYTICS SERVICE CONNECTION
------------------------------------------

File: lib/core/services/dashboard_analytics_service.dart

CURRENT STATE: Uses mock data and placeholder RPC calls
TARGET STATE: Connect to live Supabase tables and views

Steps:
a) Update getStateMetrics() to use real state_performance_view:
   ```dart
   Future<List<StateMetrics>> getStateMetrics() async {
     final response = await _client
         .from('state_performance_view')  // Real view
         .select()
         .order('performance_score', ascending: false);
     
     return (response as List)
         .map((json) => StateMetrics.fromJson(json))
         .toList();
   }
   ```

b) Enable real-time streams for state metrics:
   ```dart
   Stream<List<StateMetrics>> getStateMetricsStream() {
     return _client
         .from('state_performance_view')
         .stream(primaryKey: ['state_id'])
         .order('performance_score', ascending: false)
         .map((data) => data
             .map((json) => StateMetrics.fromJson(json))
             .toList());
   }
   ```

c) Connect fund flow data to actual fund_flow table:
   ```dart
   Future<FundFlowData> getFundFlowData() async {
     final response = await _client
         .rpc('get_fund_flow_summary')  // Create this function
         .single();
     
     return FundFlowData.fromJson(response);
   }
   ```

2. NATIONAL HEATMAP CONNECTION
-------------------------------

File: lib/features/dashboard/presentation/widgets/national_heatmap_widget.dart

CURRENT STATE: Uses DemoDataGenerator mock states
TARGET STATE: Stream from Supabase state_performance_view

Steps:
a) Replace mock data with real stream:
   ```dart
   @override
   void initState() {
     super.initState();
     _stateMetricsSubscription = ref
         .read(dashboardAnalyticsServiceProvider)
         .getStateMetricsStream()
         .listen((states) {
           setState(() {
             _states = states;
           });
         });
   }
   ```

b) Update state click handler to use drill-down navigation:
   ```dart
   void _onStateTap(String stateId, String stateName, LatLng location) {
     ref.read(drillDownNavigationServiceProvider)
         .drillToState(
           stateId: stateId,
           stateName: stateName,
           centerLocation: location,
         );
     // Navigate to state dashboard with filter
   }
   ```

3. FUND FLOW WATERFALL CONNECTION
----------------------------------

File: lib/features/fund_flow/presentation/widgets/fund_flow_waterfall_chart.dart

CURRENT STATE: Uses mock_fund_flow_data.dart
TARGET STATE: Real-time fund_flow table streaming

Steps:
a) Create Supabase RPC function for waterfall data:
   ```sql
   CREATE OR REPLACE FUNCTION get_fund_flow_waterfall_data()
   RETURNS JSON AS $$
   BEGIN
     RETURN (
       SELECT json_build_object(
         'centre_allocation', SUM(CASE WHEN stage = 'centre_allocation' THEN amount ELSE 0 END),
         'state_received', SUM(CASE WHEN stage = 'state_received' THEN amount ELSE 0 END),
         'agency_disbursed', SUM(CASE WHEN stage = 'agency_disbursed' THEN amount ELSE 0 END),
         'project_utilized', SUM(CASE WHEN stage = 'project_utilized' THEN amount ELSE 0 END)
       )
       FROM fund_flow
     );
   END;
   $$ LANGUAGE plpgsql SECURITY DEFINER;
   ```

b) Update widget to use real data:
   ```dart
   Future<void> _loadFundFlowData() async {
     final response = await Supabase.instance.client
         .rpc('get_fund_flow_waterfall_data')
         .single();
     
     setState(() {
       _fundFlowData = FundFlowData.fromJson(response);
     });
   }
   ```

4. DISTRICT PERFORMANCE MAP CONNECTION
---------------------------------------

File: lib/features/dashboard/presentation/widgets/district_performance_map_widget.dart

CURRENT STATE: Mock district data
TARGET STATE: Real spatial queries with PostGIS

Steps:
a) Create spatial query function:
   ```sql
   CREATE OR REPLACE FUNCTION get_district_performance(state_uuid UUID)
   RETURNS TABLE (
     district_id UUID,
     district_name TEXT,
     boundary GEOMETRY,
     performance_score FLOAT,
     fund_utilization FLOAT
   ) AS $$
   BEGIN
     RETURN QUERY
     SELECT 
       d.id,
       d.name,
       d.boundary,
       AVG(p.completion_percentage) as performance_score,
       SUM(f.utilized_amount) / NULLIF(SUM(f.allocated_amount), 0) as fund_utilization
     FROM districts d
     LEFT JOIN projects p ON p.district_id = d.id
     LEFT JOIN fund_flow f ON f.project_id = p.id
     WHERE d.state_id = state_uuid
     GROUP BY d.id, d.name, d.boundary;
   END;
   $$ LANGUAGE plpgsql SECURITY DEFINER;
   ```

b) Update widget to query real data:
   ```dart
   Future<void> _loadDistrictData() async {
     final response = await Supabase.instance.client
         .rpc('get_district_performance', params: {
           'state_uuid': widget.stateId
         });
     
     setState(() {
       _districts = (response as List)
           .map((json) => DistrictPerformance.fromJson(json))
           .toList();
     });
   }
   ```

5. AGENCY DASHBOARD PROJECT STREAM
-----------------------------------

File: lib/features/dashboard/presentation/pages/agency_dashboard_page.dart

CURRENT STATE: Mock projects list
TARGET STATE: Real-time project streaming

Steps:
a) Replace _loadMockData with real stream subscription:
   ```dart
   @override
   void initState() {
     super.initState();
     _projectsSubscription = Supabase.instance.client
         .from('projects')
         .stream(primaryKey: ['id'])
         .eq('agency_id', currentUser.agencyId)
         .order('updated_at', ascending: false)
         .listen((data) {
           setState(() {
             _projects = data
                 .map((json) => ProjectModel.fromJson(json))
                 .toList();
           });
         });
   }
   ```

b) Update dispose to cancel subscription:
   ```dart
   @override
   void dispose() {
     _projectsSubscription?.cancel();
     super.dispose();
   }
   ```

6. COMMUNICATION HUB CONNECTION
-------------------------------

File: lib/features/communication/presentation/pages/communication_hub_page.dart

CURRENT STATE: Uses mock_communication_service_demo.dart
TARGET STATE: Real-time Supabase channels

Steps:
a) Switch to real communication service:
   ```dart
   final communicationService = ref.watch(communicationServiceProvider);
   // Instead of: communicationServiceDemoProvider
   ```

b) Enable real-time message streaming:
   ```dart
   final channel = Supabase.instance.client
       .channel('chat:${channelId}')
       .onPostgresChanges(
         event: PostgresChangeEvent.insert,
         schema: 'public',
         table: 'chat_messages',
         filter: PostgresChangeFilter(
           type: PostgresChangeFilterType.eq,
           column: 'channel_id',
           value: channelId,
         ),
         callback: (payload) {
           final message = ChatMessage.fromJson(payload.newRecord);
           // Add to message list
         },
       )
       .subscribe();
   ```

7. MILESTONE CLAIMS CONNECTION
-------------------------------

File: lib/features/dashboard/presentation/widgets/smart_milestone_claims_widget.dart

CURRENT STATE: Mock milestone data
TARGET STATE: Real database with photo uploads

Steps:
a) Connect to milestones table:
   ```dart
   Stream<List<Milestone>> _getMilestonesStream() {
     return Supabase.instance.client
         .from('milestones')
         .stream(primaryKey: ['id'])
         .eq('project_id', widget.projectId)
         .order('sequence', ascending: true)
         .map((data) => data
             .map((json) => Milestone.fromJson(json))
             .toList());
   }
   ```

b) Enable photo uploads to storage:
   ```dart
   Future<String> _uploadEvidence(File imageFile) async {
     final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
     final path = 'milestone_evidence/${widget.projectId}/$fileName';
     
     await Supabase.instance.client.storage
         .from('evidence')
         .upload(path, imageFile);
     
     return Supabase.instance.client.storage
         .from('evidence')
         .getPublicUrl(path);
   }
   ```

8. AUDIT TRAIL CONNECTION
--------------------------

File: lib/features/dashboard/presentation/widgets/audit_trail_explorer_widget.dart

CURRENT STATE: Mock audit logs
TARGET STATE: Immutable blockchain-inspired logging

Steps:
a) Enable automatic audit trail insertion:
   ```dart
   // Use database trigger for automatic logging
   CREATE OR REPLACE FUNCTION log_audit_trail()
   RETURNS TRIGGER AS $$
   BEGIN
     INSERT INTO audit_chain (
       entity_type,
       entity_id,
       action,
       user_id,
       previous_hash,
       data_snapshot
     ) VALUES (
       TG_TABLE_NAME,
       NEW.id,
       TG_OP,
       auth.uid(),
       (SELECT current_hash FROM audit_chain ORDER BY created_at DESC LIMIT 1),
       row_to_json(NEW)
     );
     RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;
   ```

b) Query audit trail with hash verification:
   ```dart
   Future<List<AuditRecord>> _fetchAuditTrail() async {
     final response = await Supabase.instance.client
         .from('audit_chain')
         .select()
         .order('created_at', ascending: false)
         .limit(100);
     
     return (response as List)
         .map((json) => AuditRecord.fromJson(json))
         .toList();
   }
   ```

=============================================================================
TESTING CHECKLIST AFTER CONNECTION
=============================================================================

□ Test user authentication flows
□ Verify role-based data access (RLS)
□ Confirm real-time subscriptions work
□ Test file uploads/downloads
□ Validate spatial queries return correct data
□ Check performance under load
□ Test offline capability
□ Verify error handling
□ Confirm data consistency
□ Test concurrent user scenarios

=============================================================================
PERFORMANCE OPTIMIZATION TIPS
=============================================================================

1. Use pagination for large datasets:
   ```dart
   .range(offset, offset + limit)
   ```

2. Implement lazy loading for infinite scroll:
   ```dart
   ScrollController with hasClients check
   ```

3. Cache frequently accessed data:
   ```dart
   Use Riverpod with keepAlive: true
   ```

4. Use database indexes for common queries:
   ```sql
   CREATE INDEX idx_projects_agency_id ON projects(agency_id);
   ```

5. Optimize real-time subscriptions:
   ```dart
   Limit to necessary tables only
   Use filters to reduce payload
   Implement debouncing
   ```

=============================================================================
TROUBLESHOOTING COMMON ISSUES
=============================================================================

Issue: "RLS policy prevents read access"
Solution: Verify user role and RLS policies match

Issue: "Real-time subscription not working"
Solution: Enable real-time in Supabase dashboard for table

Issue: "File upload fails"
Solution: Check storage bucket permissions and size limits

Issue: "Spatial query returns empty"
Solution: Verify PostGIS extension enabled and data has geometry

Issue: "Performance degradation"
Solution: Add indexes, use pagination, optimize queries

=============================================================================
*/

// This file serves as documentation only
// No code implementation needed here