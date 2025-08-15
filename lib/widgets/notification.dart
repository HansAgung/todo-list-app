import 'package:flutter/material.dart';

enum NotificationType { warn, accept }

class NotificationBanner extends StatelessWidget {
  final String message;
  final NotificationType type;

  const NotificationBanner({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        type == NotificationType.warn ? Colors.red : Colors.green;
    final IconData icon =
        type == NotificationType.warn ? Icons.warning : Icons.check_circle;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
