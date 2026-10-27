import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/widgets/app_error_widget.dart';
import '../../../../core/common/widgets/app_loading.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../router/route_names.dart';
import '../../domain/entities/user_settings.dart';
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _currencies = ['NPR', 'INR', 'USD', 'EUR', 'GBP'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.read(settingsProvider.notifier).load(),
        ),
        data: (value) => ListView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: [
            _ProfileCard(settings: value),
            const SizedBox(height: AppDimensions.sectionSpacing),
            const _SectionLabel('Organisation'),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.category_outlined,
              title: 'Categories',
              subtitle: 'Customise income and expense categories',
              onTap: () => context.push(RouteNames.categories),
            ),
            const SizedBox(height: AppDimensions.sectionSpacing),
            const _SectionLabel('Preferences'),
            const SizedBox(height: 10),
            _CurrencyTile(
              value: value.currencyCode,
              currencies: _currencies,
              onChanged: (code) => ref
                  .read(settingsProvider.notifier)
                  .update(value.copyWith(currencyCode: code)),
            ),
            const SizedBox(height: AppDimensions.sectionSpacing),
            const _SectionLabel('About'),
            const SizedBox(height: 10),
            const _InfoTile(
              icon: Icons.info_outline_rounded,
              title: 'Version',
              subtitle: AppConstants.appVersion,
            ),
            const _InfoTile(
              icon: Icons.cloud_off_outlined,
              title: 'Cloud sync',
              subtitle: 'Local only — cloud sync ships in a later update',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: const Icon(Icons.person_outline, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${settings.currencyCode} · local profile',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editName(context, ref, settings),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
  ) async {
    final controller = TextEditingController(text: settings.displayName);
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Display name'),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Enter a name' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true) {
      await ref
          .read(settingsProvider.notifier)
          .update(settings.copyWith(displayName: controller.text.trim()));
    }
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.value,
    required this.currencies,
    required this.onChanged,
  });

  final String value;
  final List<String> currencies;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.attach_money_rounded),
        title: const Text('Currency'),
        trailing: DropdownButton<String>(
          value: currencies.contains(value) ? value : currencies.first,
          underline: const SizedBox.shrink(),
          items: [
            for (final code in currencies)
              DropdownMenuItem(value: code, child: Text(code)),
          ],
          onChanged: (code) {
            if (code != null) {
              onChanged(code);
            }
          },
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}
