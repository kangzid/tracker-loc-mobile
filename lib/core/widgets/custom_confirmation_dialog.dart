import 'package:flutter/material.dart';

class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color confirmColor;
  final Color cancelColor;

  const CustomConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'YA',
    this.cancelText = 'TIDAK',
    required this.onConfirm,
    this.onCancel,
    this.confirmColor = const Color(0xFFE53935), // Default Red
    this.cancelColor = const Color(0xFF1E88E5), // Default Blue
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color:
              const Color(0xFFEEEEEE), // Light grey background like iOS/Image
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1, color: Colors.grey),
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        onConfirm();
                        Navigator.of(context).pop(); // Close dialog on confirm
                      },
                      borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(16),
                        bottomRight: onCancel == null
                            ? const Radius.circular(16)
                            : Radius.zero,
                      ),
                      child: Center(
                        child: Text(
                          confirmText,
                          style: TextStyle(
                            color: confirmColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (onCancel != null) ...[
                    const VerticalDivider(
                        width: 1, thickness: 1, color: Colors.grey),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          onCancel!();
                          Navigator.of(context).pop(); // Close dialog on cancel
                        },
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            cancelText,
                            style: TextStyle(
                              color: cancelColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
