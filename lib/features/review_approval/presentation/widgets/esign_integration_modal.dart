import 'package:flutter/material.dart';
import '../../../../core/models/request_model.dart';

/// E-Sign Integration Modal for digital signature workflow
class ESignIntegrationModal extends StatefulWidget {
  final RequestModel request;
  final Function(String signatureId) onSignatureComplete;
  final VoidCallback onCancel;

  const ESignIntegrationModal({
    Key? key,
    required this.request,
    required this.onSignatureComplete,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<ESignIntegrationModal> createState() => _ESignIntegrationModalState();
}

class _ESignIntegrationModalState extends State<ESignIntegrationModal> {
  ESignStatus _signatureStatus = ESignStatus.pending;
  String? _signatureId;
  String? _errorMessage;
  bool _isProcessing = false;
  
  // Mock OTP for demonstration
  final TextEditingController _otpController = TextEditingController();
  bool _showOtpInput = false;
  
  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequestSummary(),
                    const SizedBox(height: 24),
                    _buildSignatureSection(),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorMessage(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.verified_user,
            color: Colors.blue.shade700,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Digital Signature Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign this request using your e-Sign credentials',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ],
    );
  }

  Widget _buildRequestSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Request ID', widget.request.id),
          _buildSummaryRow('Agency', widget.request.agencyName),
          _buildSummaryRow('Type', widget.request.type.displayName),
          _buildSummaryRow('Priority', widget.request.priority.displayName),
          _buildSummaryRow(
            'Submitted',
            _formatDate(widget.request.createdAt),
          ),
          if (widget.request.projectName != null)
            _buildSummaryRow('Project', widget.request.projectName!),
          if (widget.request.budgetAmount != null)
            _buildSummaryRow(
              'Budget',
              '₹${_formatCurrency(widget.request.budgetAmount!)}',
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _getStatusText(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSignatureContent(),
        ],
      ),
    );
  }

  Widget _buildSignatureContent() {
    switch (_signatureStatus) {
      case ESignStatus.pending:
        return _buildPendingSignature();
      case ESignStatus.inProgress:
        return _buildInProgressSignature();
      case ESignStatus.completed:
        return _buildCompletedSignature();
      case ESignStatus.failed:
        return _buildFailedSignature();
    }
  }

  Widget _buildPendingSignature() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ready to sign this request digitally',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You will receive an OTP on your registered mobile number',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showOtpInput) ...[
          const SizedBox(height: 16),
          _buildOtpInput(),
        ],
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: 'Enter 6-digit OTP',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.lock_outline),
            counterText: '',
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _isProcessing ? null : _handleResendOtp,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Resend OTP'),
        ),
      ],
    );
  }

  Widget _buildInProgressSignature() {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Processing digital signature...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedSignature() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signature Applied Successfully',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                    if (_signatureId != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Signature ID: $_signatureId',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFailedSignature() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Signature failed. Please try again.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.red.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isProcessing ? null : widget.onCancel,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        if (_signatureStatus == ESignStatus.pending && !_showOtpInput)
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _handleInitiateSignature,
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Send OTP'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (_showOtpInput && _signatureStatus == ESignStatus.pending)
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _handleVerifyAndSign,
            icon: const Icon(Icons.verified_user, size: 18),
            label: const Text('Verify & Sign'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (_signatureStatus == ESignStatus.completed)
          ElevatedButton.icon(
            onPressed: () {
              if (_signatureId != null) {
                widget.onSignatureComplete(_signatureId!);
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Done'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (_signatureStatus == ESignStatus.failed)
          ElevatedButton.icon(
            onPressed: _handleRetrySignature,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (_signatureStatus) {
      case ESignStatus.pending:
        return Icons.pending_outlined;
      case ESignStatus.inProgress:
        return Icons.hourglass_empty;
      case ESignStatus.completed:
        return Icons.check_circle;
      case ESignStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor() {
    switch (_signatureStatus) {
      case ESignStatus.pending:
        return Colors.amber.shade700;
      case ESignStatus.inProgress:
        return Colors.blue.shade700;
      case ESignStatus.completed:
        return Colors.green.shade700;
      case ESignStatus.failed:
        return Colors.red.shade700;
    }
  }

  String _getStatusText() {
    switch (_signatureStatus) {
      case ESignStatus.pending:
        return 'Signature Pending';
      case ESignStatus.inProgress:
        return 'Processing...';
      case ESignStatus.completed:
        return 'Signed Successfully';
      case ESignStatus.failed:
        return 'Signature Failed';
    }
  }

  void _handleInitiateSignature() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    // Simulate API call to initiate e-sign process
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isProcessing = false;
      _showOtpInput = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to your registered mobile number'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleVerifyAndSign() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _signatureStatus = ESignStatus.inProgress;
      _errorMessage = null;
    });

    // Simulate API call to verify OTP and complete signature
    await Future.delayed(const Duration(seconds: 2));

    // Simulate success (90% success rate)
    final isSuccess = DateTime.now().millisecond % 10 != 0;

    if (isSuccess) {
      setState(() {
        _signatureStatus = ESignStatus.completed;
        _signatureId = 'ESIGN-${DateTime.now().millisecondsSinceEpoch}';
        _isProcessing = false;
      });
    } else {
      setState(() {
        _signatureStatus = ESignStatus.failed;
        _errorMessage = 'Invalid OTP. Please try again.';
        _isProcessing = false;
      });
    }
  }

  void _handleResendOtp() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isProcessing = false;
      _otpController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleRetrySignature() {
    setState(() {
      _signatureStatus = ESignStatus.pending;
      _showOtpInput = false;
      _otpController.clear();
      _errorMessage = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}