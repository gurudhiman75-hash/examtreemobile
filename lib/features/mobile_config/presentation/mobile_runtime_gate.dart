import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/observability/crash_reporting.dart';
import '../domain/mobile_app_configuration.dart';
import 'mobile_app_configuration_providers.dart';

class MobileRuntimeGate extends ConsumerWidget {
  const MobileRuntimeGate({super.key, required this.child});

  final Widget child;

  Future<void> _open(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConfig = ref.watch(mobileAppConfigurationProvider);
    final config = asyncConfig.value ?? MobileAppConfiguration.fallback;

    if (config.maintenanceMode) {
      return _BlockingRuntimePage(
        icon: Icons.construction_rounded,
        title: 'ExamTree is under maintenance',
        message: config.maintenanceMessage.trim().isEmpty
            ? 'We are completing an update. Please try again shortly.'
            : config.maintenanceMessage.trim(),
        actionLabel:
            config.supportUrl.trim().isEmpty ? null : 'Contact support',
        onAction: config.supportUrl.trim().isEmpty
            ? null
            : () => _open(config.supportUrl),
      );
    }

    final minimum = config.minimumSupportedVersion.trim();
    final mustUpdate = config.forceUpdate &&
        minimum.isNotEmpty &&
        compareSemanticVersions(examtreeCrashAppVersion, minimum) < 0;
    if (mustUpdate) {
      return _BlockingRuntimePage(
        icon: Icons.system_update_alt_rounded,
        title: 'Update ExamTree',
        message:
            'A newer ExamTree version is required to continue using the app.',
        actionLabel:
            config.playStoreUrl.trim().isEmpty ? null : 'Update from Play Store',
        onAction: config.playStoreUrl.trim().isEmpty
            ? null
            : () => _open(config.playStoreUrl),
      );
    }

    return child;
  }
}

class _BlockingRuntimePage extends StatelessWidget {
  const _BlockingRuntimePage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 38,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: onAction,
                      child: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
