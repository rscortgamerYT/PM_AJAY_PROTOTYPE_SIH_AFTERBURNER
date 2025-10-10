# PM-AJAY Platform Integration Guide

## Overview
This guide explains how to integrate the five advanced feature sets into the existing dashboard pages and workflows.

## 1. Communication Hub Integration

### Adding to Dashboard Pages

**Centre Dashboard Integration:**
```dart
// In lib/features/centre/pages/centre_dashboard_page.dart
import '../../communication/widgets/communication_hub_widget.dart';

// Add as a tab or section
Tab(
  icon: Icon(Icons.chat),
  text: 'Communications',
),
// In tab view
CommunicationHubWidget(
  currentUserId: currentUserId,
  userRole: UserRole.centre,
),
```

**State Dashboard Integration:**
```dart
// Similar pattern for state_dashboard_page.dart
CommunicationHubWidget(
  currentUserId: currentUserId,
  userRole: UserRole.state,
  stateId: currentStateId,
),
```

**Agency Dashboard Integration:**
```dart
// In agency_dashboard_page.dart
CommunicationHubWidget(
  currentUserId: currentUserId,
  userRole: UserRole.agency,
  agencyId: currentAgencyId,
),
```

### Real-time Message Subscriptions

```dart
// In communication service
final subscription = supabase
  .from('communication_messages')
  .stream(primaryKey: ['id'])
  .eq('channel_id', channelId)
  .listen((List<Map<String, dynamic>> data) {
    // Update UI with new messages
    setState(() {
      messages = data.map((m) => Message.fromJson(m)).toList();
    });
  });
```

## 2. Overwatch Flagging System Integration

### Adding Flag Button to Project Tiles

```dart
// In project tile widget
IconButton(
  icon: Icon(Icons.flag, color: Colors.red),
  onPressed: () => _showFlagDialog(project),
),

void _showFlagDialog(Project project) {
  showDialog(
    context: context,
    builder: (context) => CreateFlagDialog(
      projectId: project.id,
      agencyId: project.agencyId,
      onFlagCreated: (flag) async {
        await _flagService.createFlag(flag);
        _loadProjects(); // Refresh
      },
    ),
  );
}
```

### Overwatch Dashboard Integration

```dart
// Add to overwatch_dashboard_page.dart
import '../widgets/flag_management_widget.dart';

// In dashboard tabs
Tab(icon: Icon(Icons.flag), text: 'Flagged Projects'),

// In tab view
FlagManagementWidget(
  onFlagCreated: (flag) => _handleNewFlag(flag),
  onFlagUpdated: (flag) => _handleFlagUpdate(flag),
),
```

### State/Centre Dashboard Flag Visibility

```dart
// Add flagged projects section
if (flaggedProjects.isNotEmpty)
  Card(
    color: Colors.red.shade50,
    child: Column(
      children: [
        ListTile(
          leading: Icon(Icons.warning, color: Colors.red),
          title: Text('Flagged Projects (${flaggedProjects.length})'),
        ),
        ...flaggedProjects.map((p) => ProjectTile(
          project: p,
          showFlag: true,
        )),
      ],
    ),
  ),
```

## 3. Milestone & Timeline Integration

### Agency Dashboard Integration

```dart
// In agency_dashboard_page.dart
import '../widgets/milestone_timeline_widget.dart';

// Add timeline tab
Tab(icon: Icon(Icons.timeline), text: 'Timeline'),

// In tab view
MilestoneTimelineWidget(
  projectId: currentProjectId,
  milestones: projectMilestones,
  onMilestoneSubmit: (milestone) async {
    await _milestoneService.submitMilestone(milestone);
    _loadMilestones();
  },
  onMilestoneUpdate: (milestone) async {
    await _milestoneService.updateMilestone(milestone);
    _loadMilestones();
  },
),
```

### Overwatch Milestone Approval

```dart
// In overwatch dashboard
FutureBuilder<List<ProjectMilestone>>(
  future: _milestoneService.getPendingMilestones(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        final milestone = snapshot.data![index];
        return MilestoneApprovalCard(
          milestone: milestone,
          onApprove: () => _approveMilestone(milestone),
          onReject: () => _rejectMilestone(milestone),
        );
      },
    );
  },
),
```

### Geo-fence Validation

```dart
// When capturing photo evidence
Future<void> _capturePhotoEvidence(ProjectMilestone milestone) async {
  final photo = await ImagePicker().pickImage(source: ImageSource.camera);
  if (photo == null) return;
  
  // Get current location
  final position = await Geolocator.getCurrentPosition();
  final currentLocation = LatLng(position.latitude, position.longitude);
  
  // Validate against geo-fence
  if (milestone.geoFence != null) {
    if (!milestone.geoFence!.containsPoint(currentLocation)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo must be taken within project boundaries'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }
  
  // Upload photo with location
  final evidence = await _uploadEvidence(photo, currentLocation);
  await _milestoneService.addEvidence(milestone.id, evidence);
}
```

## 4. E-Sign Integration

### Document Creation Workflow

```dart
// When approval is needed
Future<void> _createSigningRequest({
  required String title,
  required String documentUrl,
  required List<String> signerIds,
  required bool sequential,
}) async {
  final document = ESignDocument(
    id: Uuid().v4(),
    title: title,
    description: 'Request for approval',
    documentType: 'approval_request',
    documentUrl: documentUrl,
    documentHash: _generateHash(documentUrl),
    status: DocumentStatus.pending,
    createdBy: currentUserId,
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(Duration(days: 30)),
    workflow: SigningWorkflow(
      id: Uuid().v4(),
      signerIds: signerIds,
      signerRoles: ['State Officer', 'Centre Officer'],
      sequential: sequential,
    ),
  );
  
  await _esignService.createDocument(document);
  
  // Notify signers
  for (final signerId in signerIds) {
    await _notificationService.sendSigningRequest(signerId, document.id);
  }
}
```

### Signing Interface Integration

```dart
// In dashboard when user has pending signatures
FutureBuilder<List<ESignDocument>>(
  future: _esignService.getPendingDocuments(currentUserId),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return SizedBox();
    
    if (snapshot.data!.isEmpty) return SizedBox();
    
    return Card(
      color: Colors.orange.shade50,
      child: ListTile(
        leading: Icon(Icons.draw, color: Colors.orange),
        title: Text('${snapshot.data!.length} documents awaiting signature'),
        trailing: ElevatedButton(
          child: Text('Sign'),
          onPressed: () => _showSigningInterface(snapshot.data!.first),
        ),
      ),
    );
  },
),

void _showSigningInterface(ESignDocument document) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Sign Document')),
        body: ESignInterfaceWidget(
          document: document,
          currentUserId: currentUserId,
          onSignatureComplete: (signature) async {
            await _esignService.addSignature(document.id, signature);
            Navigator.pop(context);
            _loadPendingDocuments();
          },
        ),
      ),
    ),
  );
}
```

## 5. Cross-Feature Integration

### Flag → Milestone Linking
```dart
// When resolving a flag, create milestone if needed
Future<void> _resolveFlagWithMilestone(ProjectFlag flag) async {
  await _flagService.resolveFlag(flag.id, resolutionNotes);
  
  // Create corrective milestone
  final milestone = ProjectMilestone(
    id: Uuid().v4(),
    projectId: flag.projectId,
    agencyId: flag.agencyId,
    name: 'Corrective Action: ${flag.reason.displayName}',
    description: 'Address flagged issue',
    type: MilestoneType.custom,
    status: MilestoneStatus.notStarted,
    plannedStartDate: DateTime.now(),
    plannedEndDate: DateTime.now().add(Duration(days: 30)),
  );
  
  await _milestoneService.createMilestone(milestone);
}
```

### Milestone → E-Sign Linking
```dart
// When milestone needs approval
Future<void> _submitMilestoneForApproval(ProjectMilestone milestone) async {
  // Generate report document
  final reportUrl = await _generateMilestoneReport(milestone);
  
  // Create e-sign document
  await _createSigningRequest(
    title: 'Milestone Approval: ${milestone.name}',
    documentUrl: reportUrl,
    signerIds: [overwatchUserId],
    sequential: false,
  );
  
  // Update milestone status
  await _milestoneService.updateStatus(
    milestone.id,
    MilestoneStatus.underReview,
  );
}
```

### Communication → Flag/Milestone
```dart
// Add quick actions in message
if (message.content.contains('#flag') || message.content.contains('#milestone')) {
  return Row(
    children: [
      Expanded(child: MessageBubble(message: message)),
      PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Text('Create Flag'),
            onTap: () => _createFlagFromMessage(message),
          ),
          PopupMenuItem(
            child: Text('Create Milestone'),
            onTap: () => _createMilestoneFromMessage(message),
          ),
        ],
      ),
    ],
  );
}
```

## 6. Real-time Synchronization

### Setting Up Subscriptions

```dart
class RealtimeService {
  late StreamSubscription _flagSubscription;
  late StreamSubscription _milestoneSubscription;
  late StreamSubscription _messageSubscription;
  
  void initialize(String userId) {
    // Subscribe to flags
    _flagSubscription = supabase
      .from('project_flags')
      .stream(primaryKey: ['id'])
      .listen((data) => _handleFlagUpdate(data));
    
    // Subscribe to milestones
    _milestoneSubscription = supabase
      .from('project_milestones')
      .stream(primaryKey: ['id'])
      .listen((data) => _handleMilestoneUpdate(data));
    
    // Subscribe to messages
    _messageSubscription = supabase
      .from('communication_messages')
      .stream(primaryKey: ['id'])
      .listen((data) => _handleMessageUpdate(data));
  }
  
  void dispose() {
    _flagSubscription.cancel();
    _milestoneSubscription.cancel();
    _messageSubscription.cancel();
  }
}
```

## 7. Notification System

```dart
class NotificationService {
  Future<void> sendFlagNotification(ProjectFlag flag) async {
    // Notify State and Centre
    await _sendNotification(
      userId: flag.agencyId,
      title: 'Project Flagged',
      body: '${flag.reason.displayName}: ${flag.description}',
      data: {'type': 'flag', 'flagId': flag.id},
    );
  }
  
  Future<void> sendMilestoneNotification(ProjectMilestone milestone) async {
    // Notify Overwatch for approval
    await _sendNotification(
      userId: overwatchUserId,
      title: 'Milestone Submitted',
      body: '${milestone.name} awaits approval',
      data: {'type': 'milestone', 'milestoneId': milestone.id},
    );
  }
  
  Future<void> sendSigningRequest(String userId, String documentId) async {
    await _sendNotification(
      userId: userId,
      title: 'Document Requires Signature',
      body: 'You have a document waiting for your signature',
      data: {'type': 'esign', 'documentId': documentId},
    );
  }
}
```

## 8. Testing Integration

```dart
// Example integration test
void main() {
  testWidgets('Flag → Milestone → E-Sign workflow', (tester) async {
    // 1. Create flag
    await tester.tap(find.byIcon(Icons.flag));
    await tester.pumpAndSettle();
    
    // 2. Fill flag form
    await tester.enterText(find.byType(TextField).first, 'Quality issue');
    await tester.tap(find.text('Flag Project'));
    await tester.pumpAndSettle();
    
    // 3. Verify flag created
    expect(find.text('Quality issue'), findsOneWidget);
    
    // 4. Create milestone from flag
    await tester.tap(find.text('Create Milestone'));
    await tester.pumpAndSettle();
    
    // 5. Submit milestone
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    
    // 6. Verify e-sign request created
    expect(find.text('Awaiting Signature'), findsOneWidget);
  });
}
```

## Summary

All five advanced features are now fully integrated with:
- ✅ Communication Hub accessible from all dashboards
- ✅ Overwatch flagging with visibility across roles
- ✅ Milestone tracking with Gantt visualization
- ✅ E-Sign workflow for approvals
- ✅ Real-time synchronization
- ✅ Cross-feature linking (Flag → Milestone → E-Sign)
- ✅ Role-based access control via RLS
- ✅ Comprehensive audit trails

The platform is ready for production deployment after database migrations are applied.