import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Submit Complaint Widget
/// 
/// Geo-tagged complaint submission system with automatic routing to Overwatch
/// based on complaint category and severity.
class SubmitComplaintWidget extends StatefulWidget {
  final String userId;
  
  const SubmitComplaintWidget({
    super.key,
    required this.userId,
  });

  @override
  State<SubmitComplaintWidget> createState() => _SubmitComplaintWidgetState();
}

class _SubmitComplaintWidgetState extends State<SubmitComplaintWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _complaintController = TextEditingController();
  
  ComplaintCategory? _selectedCategory;
  ComplaintSeverity _selectedSeverity = ComplaintSeverity.medium;
  String? _selectedDistrict;
  String? _selectedProject;
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  
  final List<String> _mockDistricts = [
    'North District',
    'South District',
    'East District',
    'West District',
    'Central District',
  ];
  
  final List<String> _mockProjects = [
    'Water Supply - Phase 1',
    'Toilet Construction - Sector A',
    'Rural Sanitation Program',
    'Urban Water Distribution',
    'Community Sanitation Center',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  Color _getSeverityColor(ComplaintSeverity severity) {
    switch (severity) {
      case ComplaintSeverity.low:
        return Colors.blue;
      case ComplaintSeverity.medium:
        return AppTheme.warningOrange;
      case ComplaintSeverity.high:
        return Colors.deepOrange;
      case ComplaintSeverity.critical:
        return AppTheme.errorRed;
    }
  }

  IconData _getCategoryIcon(ComplaintCategory category) {
    switch (category) {
      case ComplaintCategory.qualityIssue:
        return Icons.build_circle;
      case ComplaintCategory.delayInWork:
        return Icons.schedule;
      case ComplaintCategory.corruptionBribery:
        return Icons.gavel;
      case ComplaintCategory.safetyViolation:
        return Icons.health_and_safety;
      case ComplaintCategory.poorService:
        return Icons.sentiment_dissatisfied;
      case ComplaintCategory.other:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildAnonymousToggle(),
                  const SizedBox(height: 24),
                  if (!_isAnonymous) ...[
                    _buildPersonalDetails(),
                    const SizedBox(height: 24),
                  ],
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  _buildComplaintDetails(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.publicColor, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.report_problem, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit a Complaint',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Report issues directly to Overwatch',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your complaint will be automatically routed to the relevant authority based on category and location. You\'ll receive updates via SMS/Email.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousToggle() {
    return Card(
      child: SwitchListTile(
        value: _isAnonymous,
        onChanged: (value) => setState(() => _isAnonymous = value),
        title: const Text('Submit Anonymously'),
        subtitle: const Text('Your identity will not be disclosed'),
        secondary: Icon(
          _isAnonymous ? Icons.visibility_off : Icons.visibility,
          color: AppTheme.publicColor,
        ),
      ),
    );
  }

  Widget _buildPersonalDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (!_isAnonymous && (value == null || value.isEmpty)) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                hintText: '+91 XXXXX XXXXX',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (!_isAnonymous && (value == null || value.isEmpty)) {
                  return 'Phone number is required';
                }
                if (!_isAnonymous && value!.length < 10) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.publicColor),
                SizedBox(width: 8),
                Text(
                  'Location Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedDistrict,
              decoration: const InputDecoration(
                labelText: 'District *',
                border: OutlineInputBorder(),
              ),
              items: _mockDistricts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedDistrict = value),
              validator: (value) {
                if (value == null) {
                  return 'Please select a district';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedProject,
              decoration: const InputDecoration(
                labelText: 'Related Project (Optional)',
                border: OutlineInputBorder(),
              ),
              items: _mockProjects.map((project) {
                return DropdownMenuItem(
                  value: project,
                  child: Text(project),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedProject = value),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _captureGeoLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Capture Current Location'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description, color: AppTheme.publicColor),
                SizedBox(width: 8),
                Text(
                  'Complaint Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ComplaintCategory>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Complaint Category *',
                border: OutlineInputBorder(),
              ),
              items: ComplaintCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category), size: 20),
                      const SizedBox(width: 8),
                      Text(_getCategoryLabel(category)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Severity Level',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ComplaintSeverity>(
              segments: ComplaintSeverity.values.map((severity) {
                return ButtonSegment(
                  value: severity,
                  label: Text(severity.name.toUpperCase()),
                  icon: Icon(
                    Icons.circle,
                    color: _getSeverityColor(severity),
                    size: 12,
                  ),
                );
              }).toList(),
              selected: {_selectedSeverity},
              onSelectionChanged: (Set<ComplaintSeverity> newSelection) {
                setState(() => _selectedSeverity = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _complaintController,
              decoration: const InputDecoration(
                labelText: 'Describe the Issue *',
                hintText: 'Provide detailed information about the complaint...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe the issue';
                }
                if (value.length < 20) {
                  return 'Please provide more details (minimum 20 characters)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _attachPhotos,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Attach Photos (Optional)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitComplaint,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send),
        label: Text(_isSubmitting ? 'Submitting...' : 'Submit Complaint'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.publicColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _captureGeoLocation() {
    // Mock geo-location capture
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Captured'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: 28.6139° N'),
            Text('Longitude: 77.2090° E'),
            SizedBox(height: 8),
            Text('Location will be attached to your complaint.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _attachPhotos() {
    // Mock photo attachment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attach Photos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Photo attachment feature will open camera/gallery.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
          ),
        ],
      ),
    );
  }

  void _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate submission delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    // Generate complaint ID
    final complaintId = 'CMP${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successGreen, size: 32),
            SizedBox(width: 12),
            Text('Complaint Submitted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your complaint has been registered successfully.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complaint ID',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        complaintId,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Complaint ID copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please save this ID for tracking your complaint. You will receive updates via ${_isAnonymous ? "the system" : "SMS/Email"}.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('Submit Another'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.publicColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _complaintController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedSeverity = ComplaintSeverity.medium;
      _selectedDistrict = null;
      _selectedProject = null;
      _isAnonymous = false;
    });
  }

  String _getCategoryLabel(ComplaintCategory category) {
    switch (category) {
      case ComplaintCategory.qualityIssue:
        return 'Quality Issue';
      case ComplaintCategory.delayInWork:
        return 'Delay in Work';
      case ComplaintCategory.corruptionBribery:
        return 'Corruption/Bribery';
      case ComplaintCategory.safetyViolation:
        return 'Safety Violation';
      case ComplaintCategory.poorService:
        return 'Poor Service';
      case ComplaintCategory.other:
        return 'Other';
    }
  }
}

enum ComplaintCategory {
  qualityIssue,
  delayInWork,
  corruptionBribery,
  safetyViolation,
  poorService,
  other,
}

enum ComplaintSeverity {
  low,
  medium,
  high,
  critical,
}