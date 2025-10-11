import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for accessibility features
class AccessibilityUtils {
  AccessibilityUtils._();

  /// Common keyboard shortcuts
  static final LogicalKeySet saveShortcut = LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyS,
  );
  
  static final LogicalKeySet searchShortcut = LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyF,
  );
  
  static final LogicalKeySet escapeShortcut = LogicalKeySet(
    LogicalKeyboardKey.escape,
  );

  /// Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Announce message to screen reader
  static void announce(BuildContext context, String message, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) {
    // Announce to screen reader using Semantics
    // Note: In Flutter, announcements are handled through the Semantics widget tree
    // This is a placeholder for future implementation
    debugPrint('Announcement: $message');
  }

  /// Create semantic label for chart data
  static String createChartLabel(String chartType, Map<String, dynamic> data) {
    final buffer = StringBuffer('$chartType chart. ');
    data.forEach((key, value) {
      buffer.write('$key: $value. ');
    });
    return buffer.toString();
  }

  /// Create semantic label for status
  static String createStatusLabel(String status, String context) {
    return 'Status: $status. Context: $context';
  }
}

/// Keyboard navigation wrapper widget
class KeyboardNavigationWrapper extends StatefulWidget {
  final Widget child;
  final Map<ShortcutActivator, Intent>? shortcuts;
  final bool enableArrowKeyNavigation;

  const KeyboardNavigationWrapper({
    super.key,
    required this.child,
    this.shortcuts,
    this.enableArrowKeyNavigation = true,
  });

  @override
  State<KeyboardNavigationWrapper> createState() => _KeyboardNavigationWrapperState();
}

class _KeyboardNavigationWrapperState extends State<KeyboardNavigationWrapper> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: widget.shortcuts ?? {},
      child: Actions(
        actions: _buildActions(),
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          child: widget.child,
        ),
      ),
    );
  }

  Map<Type, Action<Intent>> _buildActions() {
    return {
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (intent) => null,
      ),
    };
  }
}

/// Accessible button with semantic labels
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? tooltip;
  final bool isEnabled;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.tooltip,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: isEnabled,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          child: child,
        ),
      ),
    );
  }
}

/// Accessible icon button with semantic labels
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? tooltip;
  final double size;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.tooltip,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: IconButton(
          icon: Icon(icon, size: size),
          onPressed: onPressed,
          iconSize: size,
        ),
      ),
    );
  }
}

/// Accessible text field with semantic labels
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String semanticLabel;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;

  const AccessibleTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    required this.semanticLabel,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      textField: true,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
}

/// Accessible card with semantic labels
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String semanticLabel;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const AccessibleCard({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      container: true,
      button: onTap != null,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Accessible list item with semantic labels
class AccessibleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String semanticLabel;

  const AccessibleListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

/// Skip navigation link widget
class SkipNavigationLink extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final FocusNode focusNode;

  const SkipNavigationLink({
    super.key,
    required this.label,
    required this.onPressed,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      left: 0,
      child: Focus(
        focusNode: focusNode,
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            // Show the skip link when focused
          }
        },
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }
}

/// Focus management widget
class FocusManager extends StatefulWidget {
  final Widget child;
  final List<FocusNode> focusNodes;

  const FocusManager({
    super.key,
    required this.child,
    required this.focusNodes,
  });

  @override
  State<FocusManager> createState() => _FocusManagerState();
}

class _FocusManagerState extends State<FocusManager> {
  int _currentFocusIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.focusNodes.isNotEmpty) {
      widget.focusNodes[0].requestFocus();
    }
  }

  void _focusNext() {
    if (_currentFocusIndex < widget.focusNodes.length - 1) {
      _currentFocusIndex++;
      widget.focusNodes[_currentFocusIndex].requestFocus();
    }
  }

  void _focusPrevious() {
    if (_currentFocusIndex > 0) {
      _currentFocusIndex--;
      widget.focusNodes[_currentFocusIndex].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.tab) {
            if (HardwareKeyboard.instance.isShiftPressed) {
              _focusPrevious();
            } else {
              _focusNext();
            }
          }
        }
      },
      child: widget.child,
    );
  }
}

/// Accessible navigation menu
class AccessibleNavigationMenu extends StatefulWidget {
  final List<NavigationItem> items;
  final Function(int) onItemSelected;
  final int currentIndex;

  const AccessibleNavigationMenu({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.currentIndex = 0,
  });

  @override
  State<AccessibleNavigationMenu> createState() => _AccessibleNavigationMenuState();
}

class _AccessibleNavigationMenuState extends State<AccessibleNavigationMenu> {
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(
      widget.items.length,
      (index) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Navigation menu',
      child: Column(
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isSelected = index == widget.currentIndex;
          
          return Semantics(
            label: '${item.label}${isSelected ? ", selected" : ""}',
            button: true,
            selected: isSelected,
            child: Focus(
              focusNode: _focusNodes[index],
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.enter ||
                      event.logicalKey == LogicalKeyboardKey.space) {
                    widget.onItemSelected(index);
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    if (index < widget.items.length - 1) {
                      _focusNodes[index + 1].requestFocus();
                    }
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    if (index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                selected: isSelected,
                onTap: () => widget.onItemSelected(index),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Navigation item model
class NavigationItem {
  final String label;
  final IconData icon;
  final String route;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Accessible data table
class AccessibleDataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final String semanticLabel;

  const AccessibleDataTable({
    super.key,
    required this.headers,
    required this.rows,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      container: true,
      child: DataTable(
        columns: headers.map((header) {
          return DataColumn(
            label: Semantics(
              header: true,
              label: header,
              child: Text(header),
            ),
          );
        }).toList(),
        rows: rows.map((row) {
          return DataRow(
            cells: row.asMap().entries.map((entry) {
              final columnName = headers[entry.key];
              return DataCell(
                Semantics(
                  label: '$columnName: ${entry.value}',
                  child: Text(entry.value),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

/// Live region for dynamic content updates
class LiveRegion extends StatelessWidget {
  final Widget child;
  final String? label;
  final Assertiveness assertiveness;

  const LiveRegion({
    super.key,
    required this.child,
    this.label,
    this.assertiveness = Assertiveness.polite,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: child,
    );
  }
}

/// Assertiveness level for announcements
enum Assertiveness {
  polite,
  assertive,
}