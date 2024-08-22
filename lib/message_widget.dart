import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
  });

  final String text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(
              text,
              style: TextStyle(
                color: isFromUser ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
