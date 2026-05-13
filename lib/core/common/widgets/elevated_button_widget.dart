import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final String buttonLabel;
  final VoidCallback onPressEvent;
  final bool isLoading;
  final bool enabled;
  const ElevatedButtonWidget({
    super.key,
    required this.buttonLabel,
    required this.onPressEvent,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (isLoading || !enabled) ? null : onPressEvent,
      child: Text(
              buttonLabel,
              
            ),
    );
  }
}
