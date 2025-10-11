import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_design_system.dart';

/// Theme mode enum
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Theme manager for handling dark/light mode switching
class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  AppThemeMode _themeMode = AppThemeMode.system;
  SharedPreferences? _prefs;

  AppThemeMode get themeMode => _themeMode;

  /// Initialize theme manager and load saved preference
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs?.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => AppThemeMode.system,
      );
      notifyListeners();
    }
  }

  /// Set theme mode and save preference
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _prefs?.setString(_themeKey, mode.name);
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = _themeMode == AppThemeMode.light 
        ? AppThemeMode.dark 
        : AppThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Get current theme data based on brightness
  ThemeData getThemeData(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppDesignSystem.deepIndigo,
      scaffoldBackgroundColor: AppDesignSystem.neutral50,
      colorScheme: const ColorScheme.light(
        primary: AppDesignSystem.deepIndigo,
        secondary: AppDesignSystem.vibrantTeal,
        tertiary: AppDesignSystem.amber,
        error: AppDesignSystem.error,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: AppDesignSystem.neutral900,
      ),
      textTheme: _buildTextTheme(false),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppDesignSystem.neutral900,
        iconTheme: IconThemeData(color: AppDesignSystem.neutral700),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDesignSystem.deepIndigo,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space20,
            vertical: AppDesignSystem.space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDesignSystem.neutral100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppDesignSystem.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppDesignSystem.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppDesignSystem.deepIndigo, width: 2),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppDesignSystem.neutral700,
        size: AppDesignSystem.iconMedium,
      ),
      dividerTheme: const DividerThemeData(
        color: AppDesignSystem.neutral200,
        thickness: 1,
        space: AppDesignSystem.space16,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppDesignSystem.deepIndigoLight,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: AppDesignSystem.deepIndigoLight,
        secondary: AppDesignSystem.vibrantTealLight,
        tertiary: AppDesignSystem.amberLight,
        error: AppDesignSystem.error,
        surface: Color(0xFF1E1E1E),
        onPrimary: AppDesignSystem.neutral900,
        onSecondary: AppDesignSystem.neutral900,
        onError: AppDesignSystem.neutral900,
        onSurface: AppDesignSystem.neutral100,
      ),
      textTheme: _buildTextTheme(true),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: AppDesignSystem.neutral100,
        iconTheme: IconThemeData(color: AppDesignSystem.neutral300),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF1E1E1E),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDesignSystem.deepIndigoLight,
          foregroundColor: AppDesignSystem.neutral900,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignSystem.space20,
            vertical: AppDesignSystem.space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppDesignSystem.neutral700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppDesignSystem.neutral700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppDesignSystem.deepIndigoLight, width: 2),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppDesignSystem.neutral300,
        size: AppDesignSystem.iconMedium,
      ),
      dividerTheme: const DividerThemeData(
        color: AppDesignSystem.neutral700,
        thickness: 1,
        space: AppDesignSystem.space16,
      ),
    );
  }

  /// Build text theme for light or dark mode
  static TextTheme _buildTextTheme(bool isDark) {
    final baseColor = isDark ? AppDesignSystem.neutral100 : AppDesignSystem.neutral900;
    
    return TextTheme(
      displayLarge: AppDesignSystem.displayLarge.copyWith(color: baseColor),
      displayMedium: AppDesignSystem.displayMedium.copyWith(color: baseColor),
      displaySmall: AppDesignSystem.displaySmall.copyWith(color: baseColor),
      headlineMedium: AppDesignSystem.headlineMedium.copyWith(color: baseColor),
      headlineSmall: AppDesignSystem.headlineSmall.copyWith(color: baseColor),
      titleLarge: AppDesignSystem.titleLarge.copyWith(color: baseColor),
      titleMedium: AppDesignSystem.titleMedium.copyWith(color: baseColor),
      titleSmall: AppDesignSystem.titleSmall.copyWith(color: baseColor),
      bodyLarge: AppDesignSystem.bodyLarge.copyWith(color: baseColor),
      bodyMedium: AppDesignSystem.bodyMedium.copyWith(color: baseColor),
      bodySmall: AppDesignSystem.bodySmall.copyWith(
        color: isDark ? AppDesignSystem.neutral400 : AppDesignSystem.neutral600,
      ),
      labelLarge: AppDesignSystem.labelLarge.copyWith(color: baseColor),
      labelSmall: AppDesignSystem.labelSmall.copyWith(
        color: isDark ? AppDesignSystem.neutral400 : AppDesignSystem.neutral600,
      ),
    );
  }
}

/// Theme toggle widget with smooth animation
class ThemeToggleButton extends StatelessWidget {
  final ThemeManager themeManager;
  final bool showLabel;

  const ThemeToggleButton({
    super.key,
    required this.themeManager,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, child) {
        final isDark = themeManager.themeMode == AppThemeMode.dark;
        
        return AnimatedContainer(
          duration: AppDesignSystem.durationNormal,
          curve: AppDesignSystem.curveStandard,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => themeManager.toggleTheme(),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.space12,
                  vertical: AppDesignSystem.space8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: AppDesignSystem.durationNormal,
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        key: ValueKey(isDark),
                        color: isDark
                            ? AppDesignSystem.deepIndigoLight
                            : AppDesignSystem.warning,
                        size: AppDesignSystem.iconSmall,
                      ),
                    ),
                    if (showLabel) ...[
                      const SizedBox(width: AppDesignSystem.space8),
                      Text(
                        isDark ? 'Dark' : 'Light',
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Theme mode selector with system option
class ThemeModeSelector extends StatelessWidget {
  final ThemeManager themeManager;

  const ThemeModeSelector({
    super.key,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDesignSystem.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Theme Mode',
                  style: AppDesignSystem.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDesignSystem.space12),
                _buildThemeOption(
                  context,
                  AppThemeMode.light,
                  Icons.light_mode,
                  'Light',
                  'Always use light theme',
                ),
                const SizedBox(height: AppDesignSystem.space8),
                _buildThemeOption(
                  context,
                  AppThemeMode.dark,
                  Icons.dark_mode,
                  'Dark',
                  'Always use dark theme',
                ),
                const SizedBox(height: AppDesignSystem.space8),
                _buildThemeOption(
                  context,
                  AppThemeMode.system,
                  Icons.settings_suggest,
                  'System',
                  'Follow system theme',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    AppThemeMode mode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = themeManager.themeMode == mode;
    
    return AnimatedContainer(
      duration: AppDesignSystem.durationNormal,
      curve: AppDesignSystem.curveStandard,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => themeManager.setThemeMode(mode),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(AppDesignSystem.space12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).iconTheme.color,
                  size: AppDesignSystem.iconMedium,
                ),
                const SizedBox(width: AppDesignSystem.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppDesignSystem.bodyLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: AppDesignSystem.space4),
                      Text(
                        subtitle,
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: AppDesignSystem.iconSmall,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}