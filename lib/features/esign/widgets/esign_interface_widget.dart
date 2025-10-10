import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/esign_model.dart';

class ESignInterfaceWidget extends StatefulWidget {
  final ESignDocument document;
  final String currentUserId;
  final Function(SignatureData)? onSignatureComplete;

  const ESignInterfaceWidget({
    Key? key,
    required this.document,
    required this.currentUserId,
    this.onSignatureComplete,
  }) : super(key: key);

  @override
  State<ESignInterfaceWidget> createState() => _ESignInterfaceWidgetState();
}

class _ESignInterfaceWidgetState extends State<ESignInterfaceWidget> {
  SignatureType _selectedType = SignatureType.digital;
  final List<Offset?> _signaturePoints = [];
  bool _hasSignature = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildDocumentPreview()),
                const VerticalDivider(width: 1),
                Expanded(child: _buildSigningPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.document.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.document.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(widget.document.status),
            ],
          ),
          const SizedBox(height: 16),
          _buildSigningProgress(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(DocumentStatus status) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case DocumentStatus.draft:
        color = Colors.grey;
        label = 'DRAFT';
        icon = Icons.edit;
        break;
      case DocumentStatus.pending:
        color = Colors.orange;
        label = 'PENDING';
        icon = Icons.pending;
        break;
      case DocumentStatus.signed:
        color = Colors.green;
        label = 'SIGNED';
        icon = Icons.check_circle;
        break;
      case DocumentStatus.rejected:
        color = Colors.red;
        label = 'REJECTED';
        icon = Icons.cancel;
        break;
      case DocumentStatus.expired:
        color = Colors.red;
        label = 'EXPIRED';
        icon = Icons.timer_off;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSigningProgress() {
    final workflow = widget.document.workflow;
    final signedCount = widget.document.signatures.length;
    final totalSigners = workflow.signerIds.length;
    final progress = totalSigners > 0 ? signedCount / totalSigners : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 8,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '$signedCount / $totalSigners Signed',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(workflow.signerIds.length, (index) {
            final signerId = workflow.signerIds[index];
            final isSigned = workflow.completedSigners[signerId] ?? false;
            final isCurrent = workflow.sequential && workflow.currentStep == index;
            return _buildSignerChip(
              workflow.signerRoles[index],
              isSigned,
              isCurrent,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSignerChip(String role, bool isSigned, bool isCurrent) {
    Color color;
    IconData icon;
    if (isSigned) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (isCurrent) {
      color = Colors.orange;
      icon = Icons.pending;
    } else {
      color = Colors.grey;
      icon = Icons.radio_button_unchecked;
    }

    return Chip(
      avatar: Icon(icon, color: color, size: 16),
      label: Text(role),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  Widget _buildDocumentPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Preview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.description, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      widget.document.documentType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _viewDocument,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('View Full Document'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDocumentInfo(),
        ],
      ),
    );
  }

  Widget _buildDocumentInfo() {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Created By', widget.document.createdBy),
            _buildInfoRow(
              'Created At',
              DateFormat('MMM dd, yyyy HH:mm').format(widget.document.createdAt),
            ),
            if (widget.document.expiresAt != null)
              _buildInfoRow(
                'Expires At',
                DateFormat('MMM dd, yyyy HH:mm').format(widget.document.expiresAt!),
                color: widget.document.isExpired ? Colors.red : null,
              ),
            _buildInfoRow('Document Hash', widget.document.documentHash.substring(0, 16) + '...'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSigningPanel() {
    final canSign = widget.document.canUserSign(widget.currentUserId);

    if (!canSign) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Waiting for other signers',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _viewAuditTrail,
              icon: const Icon(Icons.history),
              label: const Text('View Audit Trail'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign Document',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSignatureTypeSelector(),
          const SizedBox(height: 24),
          _buildSignatureInput(),
          const SizedBox(height: 24),
          _buildSignButton(),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildExistingSignatures(),
        ],
      ),
    );
  }

  Widget _buildSignatureTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Signature Type',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<SignatureType>(
          segments: const [
            ButtonSegment(
              value: SignatureType.digital,
              label: Text('Digital'),
              icon: Icon(Icons.draw),
            ),
            ButtonSegment(
              value: SignatureType.otp,
              label: Text('OTP'),
              icon: Icon(Icons.phone),
            ),
            ButtonSegment(
              value: SignatureType.biometric,
              label: Text('Biometric'),
              icon: Icon(Icons.fingerprint),
            ),
          ],
          selected: {_selectedType},
          onSelectionChanged: (Set<SignatureType> newSelection) {
            setState(() {
              _selectedType = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSignatureInput() {
    switch (_selectedType) {
      case SignatureType.digital:
        return _buildDigitalSignaturePad();
      case SignatureType.otp:
        return _buildOTPInput();
      case SignatureType.biometric:
        return _buildBiometricPrompt();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDigitalSignaturePad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Draw Your Signature',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _signaturePoints.add(details.localPosition);
                _hasSignature = true;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _signaturePoints.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              setState(() {
                _signaturePoints.add(null);
              });
            },
            child: CustomPaint(
              painter: _SignaturePainter(_signaturePoints),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _signaturePoints.clear();
                  _hasSignature = false;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOTPInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OTP Verification',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Enter OTP',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.sms),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _sendOTP,
          icon: const Icon(Icons.send),
          label: const Text('Send OTP'),
        ),
      ],
    );
  }

  Widget _buildBiometricPrompt() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.fingerprint, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Biometric Authentication',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use your device biometrics to sign',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _authenticateBiometric,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Authenticate'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignButton() {
    return ElevatedButton.icon(
      onPressed: _signDocument,
      icon: const Icon(Icons.draw),
      label: const Text('Sign Document'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildExistingSignatures() {
    if (widget.document.signatures.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Signatures',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...widget.document.signatures.map((signature) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: _buildSignatureTypeIcon(signature.type),
              title: Text(signature.signerName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(signature.signerRole),
                  Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(signature.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              trailing: const Icon(Icons.verified, color: Colors.green),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSignatureTypeIcon(SignatureType type) {
    IconData icon;
    Color color;
    switch (type) {
      case SignatureType.digital:
        icon = Icons.draw;
        color = Colors.blue;
        break;
      case SignatureType.otp:
        icon = Icons.phone;
        color = Colors.orange;
        break;
      case SignatureType.biometric:
        icon = Icons.fingerprint;
        color = Colors.purple;
        break;
      case SignatureType.aadhaar:
        icon = Icons.badge;
        color = Colors.green;
        break;
    }
    return Icon(icon, color: color);
  }

  void _viewDocument() {
    // TODO: Open document viewer
  }

  void _sendOTP() {
    // TODO: Send OTP to user's phone
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to your registered mobile number')),
    );
  }

  Future<void> _authenticateBiometric() async {
    // TODO: Implement biometric authentication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biometric authentication successful')),
    );
  }

  Future<void> _signDocument() async {
    // Validate signature based on type
    bool isValid = false;
    switch (_selectedType) {
      case SignatureType.digital:
        isValid = _hasSignature;
        break;
      case SignatureType.otp:
        // TODO: Validate OTP
        isValid = true;
        break;
      case SignatureType.biometric:
        // TODO: Validate biometric
        isValid = true;
        break;
      default:
        isValid = false;
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the signature')),
      );
      return;
    }

    // Create signature data
    final signature = SignatureData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      signerId: widget.currentUserId,
      signerName: 'Current User', // TODO: Get from auth
      signerRole: 'Signer', // TODO: Get from workflow
      type: _selectedType,
      signatureHash: 'hash_placeholder', // TODO: Generate actual hash
      timestamp: DateTime.now(),
      ipAddress: '0.0.0.0', // TODO: Get actual IP
      deviceInfo: 'Device Info', // TODO: Get actual device info
    );

    widget.onSignatureComplete?.call(signature);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document signed successfully')),
    );
  }

  void _viewAuditTrail() {
    showDialog(
      context: context,
      builder: (context) => _AuditTrailDialog(
        auditTrail: widget.document.auditTrail,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _AuditTrailDialog extends StatelessWidget {
  final List<AuditEntry> auditTrail;

  const _AuditTrailDialog({required this.auditTrail});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Audit Trail'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: auditTrail.length,
          itemBuilder: (context, index) {
            final entry = auditTrail[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(_getActionIcon(entry.action)),
                title: Text(entry.action.toUpperCase().replaceAll('_', ' ')),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('By: ${entry.userId}'),
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm:ss').format(entry.timestamp),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'document_created':
        return Icons.create;
      case 'signature_added':
        return Icons.draw;
      case 'document_viewed':
        return Icons.visibility;
      case 'document_rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}