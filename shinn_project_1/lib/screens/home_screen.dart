import 'package:flutter/material.dart';
import '../widgets/app_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('shinn_project_1'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: 'Open Login',
              icon: Icons.login,
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Submit a Report',
              icon: Icons.report,
              onPressed: () => Navigator.pushNamed(context, '/report'),
            ),
          ],
        ),
      ),
    );
  }
}
