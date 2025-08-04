import 'package:flutter/material.dart';
import '../../screens/task_list_screen.dart';
import '../../services/platform_service.dart';
import '../../utils/constants.dart';

class DesktopWidget extends StatelessWidget {
  const DesktopWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.0,
      height: 400.0,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          children: [
            // Widget header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.task_alt,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    AppStrings.appTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Quick actions
                  IconButton(
                    onPressed: () => _openFullApp(context),
                    icon: const Icon(
                      Icons.open_in_full,
                      color: Colors.white,
                      size: 18.0,
                    ),
                    tooltip: 'Open Full App',
                  ),
                ],
              ),
            ),
            
            // Task list
            const Expanded(
              child: TaskListScreen(
                platformType: PlatformType.widget,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullApp(BuildContext context) {
    // TODO: Launch the full mobile app
    // This would typically use platform channels to launch the main app
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Full App'),
        content: const Text('This would launch the full Daily Tasks app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}