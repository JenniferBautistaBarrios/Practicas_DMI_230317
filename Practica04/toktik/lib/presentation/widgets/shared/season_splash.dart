import 'package:flutter/material.dart';

/// Small branded loading state; seasonal artwork stays in the settings picker.
class SeasonSplash extends StatelessWidget {
  const SeasonSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 176,
              height: 176,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: .18),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .15),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/Kittytoktik.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'KittyTokTik',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
