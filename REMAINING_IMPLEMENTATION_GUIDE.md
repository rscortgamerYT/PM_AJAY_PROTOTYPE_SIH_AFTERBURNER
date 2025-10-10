# PM-AJAY Platform - Remaining Implementation Guide

## Current Status Summary

### ✅ Completed Components (86%)
- Core data models (RequestModel with 40+ fields)
- E-Sign Integration Modal (612 lines, fully functional)
- Production deployment configuration (Vercel ready)
- Agency Review Panel Widget (partial fixes applied)
- Request workflow system with approval/rejection
- Real-time data refresh services
- Drill-down navigation system
- Supabase backend integration
- Performance optimizations

### 🔧 Critical Fixes Required (14%)

#### 1. Review Panel Widget Compilation Errors

**Files Affected:**
- `lib/features/review_approval/presentation/widgets/centre_review_panel_widget.dart`
- `lib/features/review_approval/presentation/widgets/state_review_panel_widget.dart`

**Issues:**
1. Using undefined types: `StateParticipationRequest`, `AgencyOnboardingRequest`
2. Missing enum values: `ProjectComponent.adarshaGram` (should be `adarshGram`)
3. Using `.value` instead of `.displayName` for enums
4. Missing properties in RequestModel: `stateName`, `proposedFundAllocation`, `proposedProjects`, `targetDistricts`, `proposedStartDate`, `proposedEndDate`, `kpis`, `submittedBy`, `supportingDocuments`
5. Missing switch cases: `RequestStatus.moreInfoRequired`, `RequestStatus.cancelled`

**Solution Approach:**
- Replace all custom request types with `RequestModel`
- Add missing fields to `RequestModel` or use metadata field
- Fix enum references to use correct names
- Complete all switch statements
- Add null-safety operators throughout

#### 2. Enum Value Mismatches

**ProjectComponent Enum** (lib/core/models/request_model.dart):
```dart
enum ProjectComponent {
  all,
  adarshGram,  // NOT adarshaGram
  gia,
  hostel;
}
```

**Fix Required in:**
- centre_review_panel_widget.dart: `adarshaGram` → `adarshGram`
- state_review_panel_widget.dart: Similar fixes needed

#### 3. RequestStatus Switch Statements

**Missing cases in multiple files:**
```dart
case RequestStatus.moreInfoRequired:
  color = Colors.amber;
  text = 'MORE INFO REQUIRED';
  break;
case RequestStatus.cancelled:
  color = Colors.grey;
  text = 'CANCELLED';
  break;
```

### 📋 Remaining Feature Implementation

#### Task 25: Interactive Onboarding Tours

**Files to Create:**
1. `lib/features/onboarding/presentation/onboarding_tour_widget.dart`
2. `lib/features/onboarding/models/tour_step_model.dart`
3. `lib/features/onboarding/services/onboarding_service.dart`

**Implementation Details:**
```dart
// Tour Step Model
class TourStep {
  final String id;
  final String title;
  final String description;
  final GlobalKey targetKey;
  final Alignment spotlightAlignment;
  final Size spotlightSize;
  final List<String> actions;
}

// Onboarding Widget Features:
- Spotlight overlay with adjustable focus
- Step-by-step navigation (Previous/Next/Skip)
- Progress indicator
- Contextual tooltips
- Auto-advance on user action
- Completion tracking in local storage
- Per-dashboard tour customization
```

**Tour Definitions by Dashboard:**

1. **Centre Dashboard Tour (8 steps)**
   - Welcome & Overview
   - State Participation Requests
   - Fund Allocation Controls
   - Approval Workflow
   - E-Sign Integration
   - Performance Metrics
   - Drill-down Navigation
   - Export & Reporting

2. **State Dashboard Tour (7 steps)**
   - Dashboard Overview
   - Agency Onboarding
   - Task Assignment Panel
   - Project Monitoring
   - Communication Hub
   - Document Management
   - Analytics & Reports

3. **Agency Dashboard Tour (6 steps)**
   - Task Assignment Review
   - Project Execution
   - Milestone Submission
   - PFMS Integration
   - Team Management
   - Compliance Reporting

#### Task 26: Ticket & Chat Integration

**Files to Create:**
1. `lib/features/support/presentation/ticket_system_widget.dart`
2. `lib/features/support/presentation/chat_widget.dart`
3. `lib/features/support/models/ticket_model.dart`
4. `lib/features/support/services/ticket_service.dart`
5. `lib/features/support/services/chat_service.dart`

**Ticket System Features:**
```dart
// Ticket Model
class Ticket {
  final String id;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final String createdBy;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<TicketComment> comments;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
}

enum TicketCategory {
  technical,
  financial,
  administrative,
  compliance,
  other
}

enum TicketPriority {
  low,
  medium,
  high,
  critical
}

enum TicketStatus {
  open,
  inProgress,
  waitingResponse,
  resolved,
  closed
}
```

**Chat Integration Features:**
- Real-time messaging using Supabase Realtime
- User presence indicators
- Typing indicators
- Read receipts
- File sharing
- Message threading
- @mentions with notifications
- Message search
- Channel-based conversations
- Direct messaging
- Group chats per project
- Chat history persistence

**Supabase Tables Required:**
```sql
-- Tickets table
CREATE TABLE tickets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  priority TEXT NOT NULL,
  status TEXT NOT NULL,
  created_by UUID REFERENCES auth.users(id),
  assigned_to UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB
);

-- Ticket comments table
CREATE TABLE ticket_comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id UUID REFERENCES tickets(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id),
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat messages table
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  channel_id TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id),
  content TEXT NOT NULL,
  attachments JSONB,
  reply_to UUID REFERENCES chat_messages(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat channels table
CREATE TABLE chat_channels (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL, -- 'direct', 'group', 'project'
  members UUID[] NOT NULL,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 🚀 Quick Fix Priority Order

1. **CRITICAL (30 minutes):**
   - Fix RequestModel to include all required fields
   - Update centre_review_panel_widget.dart mock data
   - Update state_review_panel_widget.dart mock data
   - Fix enum value references
   - Complete all switch statements

2. **HIGH (1 hour):**
   - Implement Interactive Onboarding Tours
   - Basic structure with 3 dashboard tours
   - Local storage for completion tracking

3. **MEDIUM (2 hours):**
   - Implement Ticket System
   - Basic CRUD operations
   - Integration with existing dashboards

4. **FINAL (2 hours):**
   - Implement Chat Integration
   - Supabase Realtime setup
   - Channel management
   - Message persistence

### 📝 Implementation Commands

```bash
# Fix compilation errors
flutter analyze

# Run tests after fixes
flutter test

# Build for production
flutter build web --release

# Deploy to Vercel
vercel --prod
```

### 🎯 Success Criteria

- [ ] Zero compilation errors in all Dart files
- [ ] All review panel widgets functional with RequestModel
- [ ] Onboarding tours working on all dashboards
- [ ] Ticket system operational with CRUD operations
- [ ] Chat integration with real-time messaging
- [ ] Production build successful
- [ ] Vercel deployment successful
- [ ] All 26 TODO items marked as complete

### 📊 Estimated Completion Time

- Critical Fixes: 30 minutes
- Onboarding Tours: 1 hour
- Ticket System: 2 hours
- Chat Integration: 2 hours
- Testing & Deployment: 30 minutes
- **Total: ~6 hours**

### 🔑 Key Technical Decisions

1. **Use RequestModel for all request types** - Simplifies data model, uses metadata for type-specific fields
2. **Supabase Realtime for chat** - Already integrated, no additional setup needed
3. **Local storage for onboarding** - Simple, no backend required
4. **Ticket system uses existing tables** - Can extend requests table
5. **Progressive enhancement** - Core features first, advanced features as time permits

### 📚 Reference Documentation

- Flutter Documentation: https://docs.flutter.dev
- Supabase Documentation: https://supabase.com/docs
- Vercel Deployment: https://vercel.com/docs
- Request Model: `lib/core/models/request_model.dart`
- E-Sign Integration: `lib/features/review_approval/presentation/widgets/esign_integration_modal.dart`

---

**Status:** Ready for implementation
**Last Updated:** 2025-10-11 00:36 IST
**Completion:** 86% → Target: 100%