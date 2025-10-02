import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/app_text_styles.dart';

class GuestModeBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onLoginTap;

  const GuestModeBanner({
    super.key,
    this.message = 'Data stored locally. Login to sync to cloud.',
    this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primaryContainer.withOpacity(0.3),
        border: Border(
          left: BorderSide(color: Get.theme.colorScheme.primary, width: 4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Get.theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                fontSize: 13,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (onLoginTap != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onLoginTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
