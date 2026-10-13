import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  const SizedBox(height: 14),
                  Text('$title is coming soon'),
                  const SizedBox(height: 6),
                  const Text(
                    'This section is ready for its feature implementation.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
