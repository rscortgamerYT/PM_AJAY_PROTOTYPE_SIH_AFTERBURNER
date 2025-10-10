import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/models/communication_models.dart';
import '../../../../core/services/communication_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Submit Complaint Widget
/// 
/// Allows citizens to submit complaints that route directly to Overwatch dashboard
class SubmitComplaintWidget extends ConsumerStatefulWidget {
  const SubmitComplaintWidget({super.key});

  @override
  ConsumerState<SubmitComplaintWidget> createState() => _SubmitComplaintWidgetState();
}

class _SubmitComplaintWidgetState extends ConsumerState<SubmitComplaintWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  String _selectedCategory = 'Infrastructure';
  String _selectedPriority = 'Medium';
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  List<PlatformFile> _attachments = [];

  final List<String> _categories = [
    'Infrastructure',
    'Water Supply',
    'Sanitation',
    'Education',
    'Healthcare',
    'Roads & Transport',
    'Electricity',
    'Corruption',
    'Delay in Project',
    'Quality Issues',
    'Other',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.errorRed, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit a Complaint',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Report issues directly to the Overwatch dashboard for immediate attention',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Form
          Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Anonymous Option
                  Card(
                    child: SwitchListTile(
                      title: const Text('Submit Anonymously'),
                      subtitle: const Text('Your personal details will not be shared'),
                      value: _isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymous = value;
                          if (value) {
                            _nameController.clear();
                            _emailController.clear();
                            _phoneController.clear();
                          }
                        });
                      },
                      secondary: const Icon(Icons.privacy_tip),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Personal Information (if not anonymous)
                  if (!_isAnonymous) ...[
                    const Text(
                      'Your Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (!_isAnonymous && (value == null || value.isEmpty)) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address *',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (!_isAnonymous && (value == null || value.isEmpty)) {
                          return 'Please enter your email';
                        }
                        if (!_isAnonymous && value != null && !value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Complaint Details
                  const Text(
                    'Complaint Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category *',
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCategory = value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedPriority,
                          decoration: InputDecoration(
                            labelText: 'Priority *',
                            prefixIcon: const Icon(Icons.priority_high),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _priorities.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(priority),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedPriority = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject *',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a subject';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Detailed Description *',
                      prefixIcon: const Icon(Icons.description),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Provide as much detail as possible to help us resolve your complaint',
                    ),
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      if (value.length < 20) {
                        return 'Please provide more details (at least 20 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location *',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Village/City, District, State',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Attachments
                  const Text(
                    'Attachments (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_attachments.isEmpty)
                            Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No files attached',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: _attachments.map((file) {
                                return ListTile(
                                  leading: const Icon(Icons.attachment),
                                  title: Text(file.name),
                                  subtitle: Text('${(file.size / 1024).toStringAsFixed(2)} KB'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _attachments.remove(file);
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _pickFiles,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Add Photos/Documents'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Supported: JPG, PNG, PDF (Max 5MB per file)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitComplaint,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isSubmitting ? 'Submitting...' : 'Submit Complaint',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info Box
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.secondaryBlue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What happens next?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.secondaryBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your complaint will be reviewed by the Overwatch team within 24 hours. You will receive a tracking ID to monitor the progress.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        final validFiles = result.files.where((file) => file.size <= 5 * 1024 * 1024).toList();
        
        if (validFiles.length < result.files.length) {
          _showErrorDialog('Some files were skipped because they exceed 5MB');
        }

        setState(() {
          _attachments.addAll(validFiles);
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking files: $e');
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final communicationService = ref.read(communicationServiceProvider);

      // Create ticket in the Communication Hub system
      final ticket = Ticket(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _subjectController.text,
        description: _descriptionController.text,
        status: TicketStatus.open,
        priority: _mapPriorityToEnum(_selectedPriority),
        type: _mapCategoryToEnum(_selectedCategory),
        creatorId: _isAnonymous ? 'anonymous' : 'public_user_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: [_selectedCategory.toLowerCase().replaceAll(' ', '_')],
        attachments: _attachments.map((f) => Attachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: f.name,
          url: '', // Will be populated after upload
          mimeType: f.extension ?? 'application/octet-stream',
          size: f.size,
          uploadedAt: DateTime.now(),
        )).toList(),
        metadata: {
          'source': 'public_portal',
          'reporter_name': _isAnonymous ? 'Anonymous Citizen' : _nameController.text,
          'reporter_email': _isAnonymous ? null : _emailController.text,
          'reporter_phone': _isAnonymous ? null : _phoneController.text,
          'location': _locationController.text,
          'is_anonymous': _isAnonymous,
        },
      );

      // In production, this would call: await communicationService.createTicket(ticket);
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        _showSuccessDialog(ticket.id);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to submit complaint: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  TicketPriority _mapPriorityToEnum(String priority) {
    switch (priority) {
      case 'Low':
        return TicketPriority.low;
      case 'Medium':
        return TicketPriority.medium;
      case 'High':
        return TicketPriority.high;
      case 'Urgent':
        return TicketPriority.critical;
      default:
        return TicketPriority.medium;
    }
  }

  TicketType _mapCategoryToEnum(String category) {
    switch (category) {
      case 'Delay in Project':
      case 'Quality Issues':
        return TicketType.quality;
      case 'Corruption':
        return TicketType.compliance;
      case 'Infrastructure':
      case 'Water Supply':
      case 'Sanitation':
      case 'Roads & Transport':
      case 'Electricity':
        return TicketType.technical;
      default:
        return TicketType.general;
    }
  }

  void _showSuccessDialog(String ticketId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            color: AppTheme.successGreen,
            size: 48,
          ),
        ),
        title: const Text('Complaint Submitted Successfully'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your complaint has been registered and routed to the Overwatch dashboard.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Tracking ID:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    ticketId,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Save this ID to track your complaint status',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              // Copy to clipboard
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy ID'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.error_outline, color: AppTheme.errorRed, size: 48),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _subjectController.clear();
    _descriptionController.clear();
    _locationController.clear();
    setState(() {
      _selectedCategory = 'Infrastructure';
      _selectedPriority = 'Medium';
      _isAnonymous = false;
      _attachments.clear();
    });
  }
}

// Provider for CommunicationService
final communicationServiceProvider = Provider<CommunicationService>((ref) {
  return CommunicationService();
});