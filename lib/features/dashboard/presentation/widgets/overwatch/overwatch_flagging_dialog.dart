import 'package:flutter/material.dart';
import '../../../models/overwatch_project_model.dart';
import '../../../../../core/theme/app_design_system.dart';

/// Dialog for flagging projects with issues
class OverwatchFlaggingDialog extends StatefulWidget {
  final OverwatchProject project;
  final Function(String reason, FlagPriority priority) onFlag;

  const OverwatchFlaggingDialog({
    super.key,
    required this.project,
    required this.onFlag,
  });

  @override
  State<OverwatchFlaggingDialog> createState() => _OverwatchFlaggingDialogState();
}

class _OverwatchFlaggingDialogState extends State<OverwatchFlaggingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  FlagPriority _selectedPriority = FlagPriority.medium;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppDesignSystem.radiusLarge,
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flag,
                    color: AppDesignSystem.error,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Flag Project Issue',
                      style: AppDesignSystem.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppDesignSystem.neutral100,
                  borderRadius: AppDesignSystem.radiusMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Details',
                      style: AppDesignSystem.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.project.name,
                      style: AppDesignSystem.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${widget.project.id}',
                      style: AppDesignSystem.bodySmall.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Priority Level',
                style: AppDesignSystem.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: FlagPriority.values.map((priority) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildPriorityOption(priority),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Issue Description',
                style: AppDesignSystem.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue or concern in detail...',
                  border: OutlineInputBorder(
                    borderRadius: AppDesignSystem.radiusMedium,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a description of the issue';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignSystem.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Submit Flag'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption(FlagPriority priority) {
    final isSelected = _selectedPriority == priority;
    
    return InkWell(
      onTap: () => setState(() => _selectedPriority = priority),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? priority.color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? priority.color : AppDesignSystem.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: AppDesignSystem.radiusMedium,
        ),
        child: Column(
          children: [
            Icon(
              priority.icon,
              color: priority.color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              priority.label,
              style: AppDesignSystem.labelSmall.copyWith(
                color: isSelected ? priority.color : AppDesignSystem.neutral700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onFlag(_reasonController.text.trim(), _selectedPriority);
      Navigator.of(context).pop();
    }
  }
}

/// Priority levels for flagged issues
enum FlagPriority {
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case FlagPriority.low:
        return 'Low';
      case FlagPriority.medium:
        return 'Medium';
      case FlagPriority.high:
        return 'High';
      case FlagPriority.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case FlagPriority.low:
        return AppDesignSystem.skyBlue;
      case FlagPriority.medium:
        return AppDesignSystem.sunsetOrange;
      case FlagPriority.high:
        return AppDesignSystem.error;
      case FlagPriority.critical:
        return AppDesignSystem.deepIndigo;
    }
  }

  IconData get icon {
    switch (this) {
      case FlagPriority.low:
        return Icons.info_outline;
      case FlagPriority.medium:
        return Icons.warning_amber;
      case FlagPriority.high:
        return Icons.error_outline;
      case FlagPriority.critical:
        return Icons.report_problem;
    }
  }
}