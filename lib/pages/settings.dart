import 'package:flutter/material.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/theme/app_colors.dart';

/// Minimal settings page hosting the appearance (theme) selector.
class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalController controller = GlobalControllerScope.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.spaceLg),
        children: <Widget>[
          Text(
            "Appearance",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Card(
            child: Column(
              children: AppThemeMode.values.map((AppThemeMode mode) {
                final bool selected = controller.themeMode == mode;
                return ListTile(
                  title: Text(mode.label),
                  trailing: selected
                      ? Icon(Icons.check, color: scheme.primary)
                      : null,
                  onTap: () => controller.setThemeMode(mode),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
