import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/chat_module_widget.dart';
import '../widgets/ticketing_module_widget.dart';
import '../widgets/tagging_module_widget.dart';
import '../widgets/notifications_center_widget.dart';

/// Communication Hub Page
/// 
/// Centralized communication platform integrating chat, ticketing, and tagging
class CommunicationHubPage extends ConsumerStatefulWidget {
  const CommunicationHubPage({super.key});

  @override
  ConsumerState<CommunicationHubPage> createState() => _CommunicationHubPageState();
}

class _CommunicationHubPageState extends ConsumerState<CommunicationHubPage> {
  int _selectedIndex = 0;
  bool _showNotifications = false;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.chat_bubble_outline,
      label: 'Chat',
      selectedIcon: Icons.chat_bubble,
    ),
    _NavItem(
      icon: Icons.confirmation_number_outlined,
      label: 'Tickets',
      selectedIcon: Icons.confirmation_number,
    ),
    _NavItem(
      icon: Icons.label_outline,
      label: 'Tags',
      selectedIcon: Icons.label,
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      label: 'Settings',
      selectedIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.hub, color: AppTheme.primaryIndigo),
            const SizedBox(width: 12),
            const Text('Communication Hub'),
          ],
        ),
        actions: [
          // Search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
            tooltip: 'Search',
          ),
          
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  setState(() => _showNotifications = !_showNotifications);
                },
                tooltip: 'Notifications',
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.errorRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '5',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
                _showNotifications = false;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppTheme.backgroundLight,
            selectedIconTheme: const IconThemeData(
              color: AppTheme.primaryIndigo,
              size: 28,
            ),
            unselectedIconTheme: IconThemeData(
              color: AppTheme.neutralGray,
              size: 24,
            ),
            selectedLabelTextStyle: const TextStyle(
              color: AppTheme.primaryIndigo,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: AppTheme.neutralGray,
            ),
            destinations: _navItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              );
            }).toList(),
          ),
          
          const VerticalDivider(thickness: 1, width: 1),
          
          // Main Content Area
          Expanded(
            child: _showNotifications
                ? const NotificationsCenterWidget()
                : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return const ChatModuleWidget();
      case 1:
        return const TicketingModuleWidget();
      case 2:
        return const TaggingModuleWidget();
      case 3:
        return _buildSettingsView();
      default:
        return const ChatModuleWidget();
    }
  }

  Widget _buildSettingsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 64,
            color: AppTheme.neutralGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Communication Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Configure your communication preferences',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutralGray,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.tune),
            label: const Text('Notification Settings'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.security),
            label: const Text('Privacy & Security'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Communication Hub'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search messages, tickets, or tags...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (query) {
                Navigator.pop(context);
                _performSearch(query);
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Messages'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Tickets'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                FilterChip(
                  label: const Text('Tags'),
                  selected: true,
                  onSelected: (selected) {},
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    // Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for: $query')),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}