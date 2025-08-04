import 'package:flutter/material.dart';
import '../../screens/task_list_screen.dart';
import '../../services/platform_service.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TaskListScreen(
      platformType: PlatformType.mobile,
    );
  }
}