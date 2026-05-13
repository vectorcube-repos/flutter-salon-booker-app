import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({
    super.key,
    this.error,
    this.location,
  });

  final Object? error;
  final String? location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page not found'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We couldn’t find that page.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (location != null)
              Text(
                'Path: $location',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go home'),
                ),
                OutlinedButton(
                  onPressed: () => context.go('/signin'),
                  child: const Text('Sign in'),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 24),
              Text(
                'Error: $error',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

