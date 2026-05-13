import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.errorMessage,
    this.onRevealPassword,
    this.revealPassword = false,
    this.onSubmitted,
    this.onChanged,
  });

  final TextInputType keyboardType;
  final bool isPassword;
  final String? errorMessage;
  final VoidCallback? onRevealPassword;
  final ValueChanged<String>? onSubmitted;
  final bool revealPassword;
  final ValueChanged<String>? onChanged;
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword && !revealPassword,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        errorText: errorMessage,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  revealPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: onRevealPassword,
              )
            : null,
      ),              
    );
  }
}