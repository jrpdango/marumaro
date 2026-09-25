import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';

/// Minimal settings page hosting the appearance (theme) selector.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          const SizedBox(height: AppTokens.spaceLg),
          Text(
            "Navigation",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Card(
            child: SwitchListTile(
              title: const Text("Swipe from edge to open menu"),
              value: controller.edgeSwipeOpensDrawer,
              onChanged: controller.setEdgeSwipeOpensDrawer,
            ),
          ),
        ],
      ),
    );
  }
}
