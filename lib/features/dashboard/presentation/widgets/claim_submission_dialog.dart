import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_design_system.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class ClaimSubmissionDialog extends ConsumerStatefulWidget {
  final String? milestoneId;
  final String? projectId;

  const ClaimSubmissionDialog({
    super.key,
    this.milestoneId,
    this.projectId,
  });

  @override
  ConsumerState<ClaimSubmissionDialog> createState() => _ClaimSubmissionDialogState();
}

class _ClaimSubmissionDialogState extends ConsumerState<ClaimSubmissionDialog> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _projectFormKey = GlobalKey<FormState>();

  // Project selection
  String? _selectedProjectId;
  String? _selectedProjectName;
  String? _selectedMilestoneId;
  String? _selectedMilestoneName;
  
  // Mock project data - will be replaced with Supabase data
  final List<Map<String, dynamic>> _projects = [
    {'id': 'PRJ001', 'name': 'Adarsh Gram Development - Village A'},
    {'id': 'PRJ002', 'name': 'Hostel Construction Project'},
    {'id': 'PRJ003', 'name': 'Village Infrastructure GIA'},
    {'id': 'PRJ004', 'name': 'Rural Road Development'},
    {'id': 'PRJ005', 'name': 'School Building Construction'},
  ];
  
  final Map<String, List<Map<String, dynamic>>> _milestones = {
    'PRJ001': [
      {'id': 'MS001', 'name': 'Village Infrastructure Phase 1'},
      {'id': 'MS002', 'name': 'Village Infrastructure Phase 2'},
    ],
    'PRJ002': [
      {'id': 'MS003', 'name': 'Student Hostel Construction'},
      {'id': 'MS004', 'name': 'Hostel Furniture & Fittings'},
    ],
    'PRJ003': [
      {'id': 'MS005', 'name': 'Road Infrastructure GIA'},
      {'id': 'MS006', 'name': 'Water Supply Infrastructure'},
    ],
    'PRJ004': [
      {'id': 'MS007', 'name': 'Road Construction Phase 1'},
      {'id': 'MS008', 'name': 'Road Construction Phase 2'},
    ],
    'PRJ005': [
      {'id': 'MS009', 'name': 'School Building Foundation'},
      {'id': 'MS010', 'name': 'School Building Superstructure'},
    ],
  };

  // Form controllers
  final _claimAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _remarksController = TextEditingController();

  // Geo-location data
  double? _latitude;
  double? _longitude;
  String? _locationAddress;
  bool _isCapturingLocation = false;

  // File uploads
  final List<PlatformFile> _financialDocuments = [];
  final List<Map<String, dynamic>> _geoTaggedImages = []; // {file, lat, lon, timestamp}
  final List<Map<String, dynamic>> _geoTaggedVideos = []; // {file, lat, lon, timestamp}
  
  final ImagePicker _picker = ImagePicker();

  // Form validation
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _claimAmountController.dispose();
    _descriptionController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services')),
          );
        }
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission permanently denied')),
          );
        }
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isCapturingLocation = true;
    });

    final position = await _getCurrentLocation();
    
    setState(() {
      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationAddress = "Lat: ${position.latitude.toStringAsFixed(6)}, Lon: ${position.longitude.toStringAsFixed(6)}";
      }
      _isCapturingLocation = false;
    });
  }

  Future<void> _pickFinancialDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xlsx', 'xls', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _financialDocuments.addAll(result.files);
      });
    }
  }

  Future<void> _captureGeoTaggedPhoto() async {
    // Get current location first
    final position = await _getCurrentLocation();
    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot capture photo without location access'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Capture photo
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (photo != null && mounted) {
      setState(() {
        _geoTaggedImages.add({
          'file': photo,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': DateTime.now(),
          'name': 'Photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
          'size': 0,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Photo captured with location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _captureGeoTaggedVideo() async {
    // Get current location first
    final position = await _getCurrentLocation();
    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot record video without location access'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Record video
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );

    if (video != null && mounted) {
      setState(() {
        _geoTaggedVideos.add({
          'file': video,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': DateTime.now(),
          'name': 'Video_${DateTime.now().millisecondsSinceEpoch}.mp4',
          'size': 0,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Video recorded with location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _removeFile(List<PlatformFile> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  void _removeGeoTaggedImage(int index) {
    setState(() {
      _geoTaggedImages.removeAt(index);
    });
  }

  void _removeGeoTaggedVideo(int index) {
    setState(() {
      _geoTaggedVideos.removeAt(index);
    });
  }

  Widget _buildProjectSelectionStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _projectFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Project & Milestone',
                style: AppDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the project and milestone for which you want to submit a claim',
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: AppDesignSystem.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Project Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppDesignSystem.neutral100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppDesignSystem.neutral300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_open,
                          color: AppDesignSystem.deepIndigo, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Project Selection',
                          style: AppDesignSystem.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Project',
                        prefixIcon: const Icon(Icons.account_tree),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      initialValue: _selectedProjectId,
                      items: _projects.map((project) {
                        return DropdownMenuItem<String>(
                          value: project['id'],
                          child: Text(
                            project['name'],
                            style: AppDesignSystem.bodyMedium,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectId = value;
                          _selectedProjectName = _projects
                              .firstWhere((p) => p['id'] == value)['name'];
                          _selectedMilestoneId = null;
                          _selectedMilestoneName = null;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a project';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Milestone Selection
              if (_selectedProjectId != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppDesignSystem.neutral100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppDesignSystem.neutral300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag,
                            color: AppDesignSystem.vibrantTeal, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Milestone Selection',
                            style: AppDesignSystem.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Milestone',
                          prefixIcon: const Icon(Icons.flag_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        initialValue: _selectedMilestoneId,
                        items: (_milestones[_selectedProjectId] ?? []).map((milestone) {
                          return DropdownMenuItem<String>(
                            value: milestone['id'],
                            child: Text(
                              milestone['name'],
                              style: AppDesignSystem.bodyMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMilestoneId = value;
                            _selectedMilestoneName = (_milestones[_selectedProjectId] ?? [])
                                .firstWhere((m) => m['id'] == value)['name'];
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a milestone';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Selection Summary
              if (_selectedProjectId != null && _selectedMilestoneId != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppDesignSystem.deepIndigo.withOpacity(0.1),
                        AppDesignSystem.vibrantTeal.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppDesignSystem.deepIndigo.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                            color: AppDesignSystem.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Selection Summary',
                            style: AppDesignSystem.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppDesignSystem.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Project', _selectedProjectName ?? ''),
                      const SizedBox(height: 8),
                      _buildInfoRow('Milestone', _selectedMilestoneName ?? ''),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Claim Information',
                style: AppDesignSystem.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Provide the essential details about your fund utilization claim',
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: AppDesignSystem.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Project/Milestone Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppDesignSystem.neutral100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppDesignSystem.neutral300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, 
                          color: AppDesignSystem.deepIndigo, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Claim Reference',
                          style: AppDesignSystem.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Project ID', _selectedProjectId ?? 'Not Selected'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Milestone ID', _selectedMilestoneId ?? 'Not Selected'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Project', _selectedProjectName ?? 'Not Selected'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Milestone', _selectedMilestoneName ?? 'Not Selected'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Claim Amount
              TextFormField(
                controller: _claimAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Claim Amount (₹)',
                  hintText: 'Enter the amount to be claimed',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Enter the total amount for this claim',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter claim amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Work Description',
                  hintText: 'Describe the work completed and fund utilization',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Provide detailed description of completed work',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide work description';
                  }
                  if (value.length < 50) {
                    return 'Description must be at least 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Additional Remarks
              TextFormField(
                controller: _remarksController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Remarks (Optional)',
                  hintText: 'Any additional information or context',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeoTaggingStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Geo-Location Verification',
              style: AppDesignSystem.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture the exact location where the work was completed',
              style: AppDesignSystem.bodyMedium.copyWith(
                color: AppDesignSystem.neutral600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Location Capture Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppDesignSystem.deepIndigo.withOpacity(0.1),
                    AppDesignSystem.vibrantTeal.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppDesignSystem.deepIndigo.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    _latitude != null ? Icons.location_on : Icons.location_off,
                    size: 64,
                    color: _latitude != null 
                        ? AppDesignSystem.success 
                        : AppDesignSystem.neutral400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _latitude != null 
                        ? 'Location Captured Successfully' 
                        : 'No Location Data',
                    style: AppDesignSystem.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_latitude != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Latitude', _latitude!.toStringAsFixed(6)),
                          const SizedBox(height: 8),
                          _buildInfoRow('Longitude', _longitude!.toStringAsFixed(6)),
                          const SizedBox(height: 8),
                          _buildInfoRow('Address', _locationAddress ?? 'N/A'),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCapturingLocation ? null : _captureLocation,
                      icon: _isCapturingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(_isCapturingLocation 
                          ? 'Capturing Location...' 
                          : 'Capture Current Location'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppDesignSystem.deepIndigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Important Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppDesignSystem.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppDesignSystem.warning.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber, color: AppDesignSystem.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important',
                          style: AppDesignSystem.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppDesignSystem.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ensure you are at the project site when capturing location. '
                          'Location data is mandatory for claim verification.',
                          style: AppDesignSystem.bodySmall,
                        ),
                      ],
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

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evidence Documentation',
              style: AppDesignSystem.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture geo-tagged photos/videos and upload financial documents',
              style: AppDesignSystem.bodyMedium.copyWith(
                color: AppDesignSystem.neutral600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Financial Documents Section
            _buildUploadSection(
              title: 'Financial Documents',
              icon: Icons.description,
              color: AppDesignSystem.deepIndigo,
              acceptedFormats: 'PDF, Excel (.xlsx, .xls), Word (.doc, .docx)',
              files: _financialDocuments,
              onUpload: _pickFinancialDocuments,
              onRemove: (index) => _removeFile(_financialDocuments, index),
              instructions: [
                'Bank statements showing fund transfers',
                'Invoices and receipts from vendors',
                'Expense breakdown sheets',
                'Payment vouchers and proof of payments',
              ],
            ),
            const SizedBox(height: 24),
            
            // Geo-Tagged Images Section
            _buildGeoTaggedMediaSection(
              title: 'Geo-Tagged Site Photos',
              icon: Icons.add_a_photo,
              color: AppDesignSystem.vibrantTeal,
              mediaList: _geoTaggedImages,
              onCapture: _captureGeoTaggedPhoto,
              onRemove: _removeGeoTaggedImage,
              instructions: [
                'Photos are automatically geo-tagged with current location',
                'Capture before and after images of the work site',
                'Take images showing work in progress',
                'Include close-up shots of completed work',
                'Add wide-angle shots showing project scope',
              ],
              captureButtonText: 'Capture Geo-Tagged Photo',
            ),
            const SizedBox(height: 24),
            
            // Geo-Tagged Videos Section
            _buildGeoTaggedMediaSection(
              title: 'Geo-Tagged Site Videos',
              icon: Icons.videocam,
              color: AppDesignSystem.coral,
              mediaList: _geoTaggedVideos,
              onCapture: _captureGeoTaggedVideo,
              onRemove: _removeGeoTaggedVideo,
              instructions: [
                'Videos are automatically geo-tagged with current location',
                'Record walkthrough video of completed work',
                'Capture time-lapse of work progress (if available)',
                'Record video interviews with beneficiaries',
                'Show project functionality in action',
                'Maximum duration: 5 minutes per video',
              ],
              captureButtonText: 'Record Geo-Tagged Video',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review & Submit',
              style: AppDesignSystem.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Review all information before final submission',
              style: AppDesignSystem.bodyMedium.copyWith(
                color: AppDesignSystem.neutral600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Basic Info Review
            _buildReviewSection(
              title: 'Claim Information',
              icon: Icons.info,
              children: [
                _buildReviewItem('Claim Amount', '₹${_claimAmountController.text}'),
                _buildReviewItem('Description', _descriptionController.text),
                if (_remarksController.text.isNotEmpty)
                  _buildReviewItem('Remarks', _remarksController.text),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location Review
            _buildReviewSection(
              title: 'Primary Geo-Location',
              icon: Icons.location_on,
              children: [
                if (_latitude != null) ...[
                  _buildReviewItem('Coordinates', 
                    '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'),
                  _buildReviewItem('Address', _locationAddress ?? 'N/A'),
                ] else
                  _buildReviewItem('Status', 'No location captured', 
                    isError: true),
              ],
            ),
            const SizedBox(height: 16),
            
            // Documents Review
            _buildReviewSection(
              title: 'Uploaded Documents',
              icon: Icons.folder,
              children: [
                _buildReviewItem('Financial Documents', 
                  '${_financialDocuments.length} file(s)'),
                _buildReviewItem('Geo-Tagged Photos', 
                  '${_geoTaggedImages.length} photo(s) with GPS data'),
                _buildReviewItem('Geo-Tagged Videos', 
                  '${_geoTaggedVideos.length} video(s) with GPS data'),
              ],
            ),
            const SizedBox(height: 24),
            
            // Terms and Conditions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppDesignSystem.neutral100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppDesignSystem.neutral300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                    title: Text(
                      'I hereby declare that all information provided is true and accurate',
                      style: AppDesignSystem.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'I understand that providing false information may result in '
                        'claim rejection and legal consequences.',
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: AppDesignSystem.neutral600,
                        ),
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Validation Messages
            if (!_agreedToTerms)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppDesignSystem.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, 
                      color: AppDesignSystem.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please accept the declaration to proceed',
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: AppDesignSystem.error,
                        ),
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

  Widget _buildGeoTaggedMediaSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> mediaList,
    required VoidCallback onCapture,
    required Function(int) onRemove,
    required List<String> instructions,
    required String captureButtonText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppDesignSystem.neutral300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppDesignSystem.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Automatically captures GPS coordinates',
                      style: AppDesignSystem.bodySmall.copyWith(
                        color: AppDesignSystem.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppDesignSystem.neutral100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions:',
                  style: AppDesignSystem.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...instructions.map((instruction) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: AppDesignSystem.bodySmall),
                      Expanded(
                        child: Text(
                          instruction,
                          style: AppDesignSystem.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Capture Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCapture,
              icon: Icon(icon),
              label: Text(captureButtonText),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          
          // Media List with Geo-Tags
          if (mediaList.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...mediaList.asMap().entries.map((entry) {
              final index = entry.key;
              final media = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: color, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                media['name'],
                                style: AppDesignSystem.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Captured: ${_formatTimestamp(media['timestamp'])}',
                                style: AppDesignSystem.bodySmall.copyWith(
                                  color: AppDesignSystem.neutral600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => onRemove(index),
                          icon: const Icon(Icons.close),
                          color: AppDesignSystem.error,
                          iconSize: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppDesignSystem.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, 
                            color: AppDesignSystem.success, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'GPS: ${media['latitude'].toStringAsFixed(6)}, ${media['longitude'].toStringAsFixed(6)}',
                              style: AppDesignSystem.bodySmall.copyWith(
                                color: AppDesignSystem.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadSection({
    required String title,
    required IconData icon,
    required Color color,
    required String acceptedFormats,
    required List<PlatformFile> files,
    required VoidCallback onUpload,
    required Function(int) onRemove,
    required List<String> instructions,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppDesignSystem.neutral300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppDesignSystem.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Accepted: $acceptedFormats',
                      style: AppDesignSystem.bodySmall.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppDesignSystem.neutral100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Required Documents:',
                  style: AppDesignSystem.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...instructions.map((instruction) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: AppDesignSystem.bodySmall),
                      Expanded(
                        child: Text(
                          instruction,
                          style: AppDesignSystem.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Upload Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.cloud_upload),
              label: Text('Upload $title'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: BorderSide(color: color),
                foregroundColor: color,
              ),
            ),
          ),
          
          // File List
          if (files.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...files.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file, color: color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: AppDesignSystem.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${(file.size / 1024).toStringAsFixed(1)} KB',
                            style: AppDesignSystem.bodySmall.copyWith(
                              color: AppDesignSystem.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemove(index),
                      icon: const Icon(Icons.close),
                      color: AppDesignSystem.error,
                      iconSize: 20,
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppDesignSystem.neutral300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppDesignSystem.deepIndigo, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppDesignSystem.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppDesignSystem.bodySmall.copyWith(
                color: AppDesignSystem.neutral600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppDesignSystem.bodySmall.copyWith(
                color: isError ? AppDesignSystem.error : AppDesignSystem.neutral900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppDesignSystem.bodySmall.copyWith(
            color: AppDesignSystem.neutral600,
          ),
        ),
        Text(
          value,
          style: AppDesignSystem.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _projectFormKey.currentState?.validate() ?? false;
      case 1:
        return _formKey.currentState?.validate() ?? false;
      case 2:
        return _latitude != null && _longitude != null;
      case 3:
        return _financialDocuments.isNotEmpty ||
               _geoTaggedImages.isNotEmpty ||
               _geoTaggedVideos.isNotEmpty;
      case 4:
        return _agreedToTerms;
      default:
        return false;
    }
  }

  void _handleSubmit() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the declaration to submit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implement actual submission logic
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Claim submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black54,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppDesignSystem.deepIndigo,
                    AppDesignSystem.vibrantTeal,
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit Fund Utilization Claim',
                          style: AppDesignSystem.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Step ${_currentStep + 1} of 5',
                          style: AppDesignSystem.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Stepper
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _buildStepIndicator(0, 'Project', Icons.folder_open),
                  _buildStepConnector(0),
                  _buildStepIndicator(1, 'Basic Info', Icons.info),
                  _buildStepConnector(1),
                  _buildStepIndicator(2, 'Geo-Tag', Icons.location_on),
                  _buildStepConnector(2),
                  _buildStepIndicator(3, 'Evidence', Icons.camera_alt),
                  _buildStepConnector(3),
                  _buildStepIndicator(4, 'Review', Icons.check_circle),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Content
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildProjectSelectionStep(),
                  _buildBasicInfoStep(),
                  _buildGeoTaggingStep(),
                  _buildDocumentsStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _canProceedToNextStep()
                          ? () {
                              if (_currentStep < 4) {
                                setState(() {
                                  _currentStep++;
                                });
                              } else {
                                _handleSubmit();
                              }
                            }
                          : null,
                      icon: Icon(_currentStep < 4 ? Icons.arrow_forward : Icons.send),
                      label: Text(_currentStep < 4 ? 'Next' : 'Submit Claim'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppDesignSystem.deepIndigo,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? AppDesignSystem.success 
                  : isActive 
                      ? AppDesignSystem.deepIndigo 
                      : AppDesignSystem.neutral200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isActive || isCompleted ? Colors.white : AppDesignSystem.neutral600,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppDesignSystem.labelSmall.copyWith(
              color: isActive ? AppDesignSystem.deepIndigo : AppDesignSystem.neutral600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = step < _currentStep;
    
    return Container(
      height: 2,
      width: 20,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted ? AppDesignSystem.success : AppDesignSystem.neutral200,
    );
  }
}