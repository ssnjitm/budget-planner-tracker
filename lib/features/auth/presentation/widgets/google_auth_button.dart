import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.smallRadius),
        ),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF475569)
              : AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Continue with Google'),
        ],
      ),
    );
  }
}
