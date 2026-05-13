import 'package:flutter/material.dart';
import 'package:salon_booker_app/core/theme/theme_extensions.dart';

class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Text(
          'Profile',
          style: context.typography.pageTitle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
