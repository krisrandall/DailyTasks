import 'package:flutter/material.dart';
import '../models/daily_task.dart';
import '../models/task_enums.dart';
import '../services/platform_service.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as date_utils;
import 'task_checkbox_widget.dart';

class TaskItemWidget extends StatelessWidget {
  final DailyTask task;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final PlatformType platformType;
  final bool isFocused;
  final int? mediaFileCount;

  const TaskItemWidget({
    Key? key,
    required this.task,
    required this.onTap,
    this.onLongPress,
    this.platformType = PlatformType.mobile,
    this.isFocused = false,
    this.mediaFileCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacing = PlatformService.getSpacing(platformType);
    final fontSizes = PlatformService.getFontSizes(platformType);
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: spacing['small']! / 2,
        horizontal: spacing['small']!,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(8.0),
        border: isFocused
            ? Border.all(color: AppConstants.primaryColor, width: 2.0)
            : null,
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: EdgeInsets.all(spacing['medium']!),
            child: Row(
              children: [
                // Checkbox/Circle icon
                AnimatedTaskCheckbox(
                  isCompleted: task.isCompletedToday,
                  requiredType: task.required,
                  size: _getIconSize(),
                ),
                
                SizedBox(width: spacing['medium']!),
                
                // Task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task name
                      Text(
                        task.name,
                        style: TextStyle(
                          fontSize: fontSizes['title']!,
                          fontWeight: FontWeight.w600,
                          color: _getTextColor(context),
                          decoration: task.isCompletedToday
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      
                      // Task details
                      if (platformType != PlatformType.widget) ...[
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            // Task type indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: _getTaskTypeColor().withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                task.taskType == TaskType.sequence
                                    ? AppStrings.sequence
                                    : AppStrings.choose,
                                style: TextStyle(
                                  fontSize: fontSizes['caption']!,
                                  color: _getTaskTypeColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8.0),
                            
                            // Media count
                            if (mediaFileCount != null)
                              Text(
                                '$mediaFileCount files',
                                style: TextStyle(
                                  fontSize: fontSizes['caption']!,
                                  color: Colors.grey[600],
                                ),
                              ),
                            
                            const Spacer(),
                            
                            // Last completed info
                            if (task.lastCompletedDate != null)
                              Text(
                                date_utils.DateUtils.getLastCompletedString(
                                  task.lastCompletedDate,
                                ),
                                style: TextStyle(
                                  fontSize: fontSizes['caption']!,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Arrow indicator
                if (platformType != PlatformType.widget)
                  Icon(
                    Icons.play_arrow,
                    size: _getIconSize(),
                    color: task.isCompletedToday
                        ? AppConstants.completedColor
                        : AppConstants.primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (task.isCompletedToday) {
      return AppConstants.completedColor.withOpacity(0.1);
    }
    
    if (task.required == RequiredType.optional) {
      return AppConstants.optionalColor.withOpacity(0.05);
    }
    
    return Theme.of(context).cardColor;
  }

  Color _getTextColor(BuildContext context) {
    if (task.isCompletedToday) {
      return Colors.grey[600]!;
    }
    
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }

  Color _getTaskTypeColor() {
    return task.taskType == TaskType.sequence
        ? Colors.blue
        : Colors.purple;
  }

  double _getIconSize() {
    switch (platformType) {
      case PlatformType.tv:
        return AppConstants.tvIconSize;
      case PlatformType.widget:
        return AppConstants.widgetIconSize;
      case PlatformType.mobile:
      case PlatformType.desktop:
      default:
        return AppConstants.iconSize;
    }
  }
}

class CompactTaskItemWidget extends StatelessWidget {
  final DailyTask task;
  final VoidCallback onTap;
  final bool showDetails;

  const CompactTaskItemWidget({
    Key? key,
    required this.task,
    required this.onTap,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(
              children: [
                TaskCheckboxWidget(
                  isCompleted: task.isCompletedToday,
                  requiredType: task.required,
                  size: AppConstants.widgetIconSize,
                ),
                
                const SizedBox(width: 12.0),
                
                Expanded(
                  child: Text(
                    task.name,
                    style: TextStyle(
                      fontSize: AppConstants.widgetFontSize,
                      decoration: task.isCompletedToday
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompletedToday
                          ? Colors.grey[600]
                          : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                if (showDetails && !task.isCompletedToday)
                  Icon(
                    Icons.play_arrow,
                    size: AppConstants.widgetIconSize,
                    color: AppConstants.primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}