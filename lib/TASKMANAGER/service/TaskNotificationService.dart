import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'TaskFirebaseService.dart';

@pragma('vm:entry-point')
void taskNotificationTapBackground(NotificationResponse response) {
  print('[🔔 BG] Notification tapped. Payload: ${response.payload}');
}

class TaskNotificationService {
  static const _channelId = 'task_channel';
  static const _channelName = 'Task Reminders';
  static const _channelDescription = 'Thông báo nhắc công việc đến hạn';

  static final _plugin = FlutterLocalNotificationsPlugin();
  static final _taskService = TaskFirebaseService();

  /// Khởi tạo plugin và quyền thông báo
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    if (!await Permission.notification.isGranted) {
      print('[🔔] Yêu cầu quyền gửi thông báo...');
      await Permission.notification.request();
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleTap,
      onDidReceiveBackgroundNotificationResponse: taskNotificationTapBackground,
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.createNotificationChannel(channel);

    print('[🔔] TaskNotificationService đã khởi tạo.');
  }

  /// Xử lý khi người dùng nhấn vào thông báo
  static Future<void> _handleTap(NotificationResponse response) async {
    print('[🔔] User tapped notification. Payload: ${response.payload}');
    // (Optional: Điều hướng đến màn hình chi tiết task nếu cần)
  }

  /// Lên lịch thông báo + tự động cập nhật task.completed sau hạn
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String taskId,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      print('[❌] Không thể đặt lịch vì thời gian đã qua: $scheduledTime');
      return;
    }

    final tzDate = tz.TZDateTime.from(scheduledTime, tz.local);
    final notifDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      notifDetails,
      payload: taskId,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('[⏰] Đã lên lịch thông báo [$id] lúc $scheduledTime cho task $taskId');

    _scheduleAutoComplete(taskId, scheduledTime);
  }

  /// Sau khi quá hạn vài giây, tự động đánh dấu task là đã hoàn thành
  static void _scheduleAutoComplete(String taskId, DateTime dueTime) {
    final delay = dueTime.difference(DateTime.now()) + const Duration(seconds: 5);
    print('[⏱] Sẽ đánh dấu hoàn thành task sau ${delay.inSeconds}s');

    Timer(delay, () async {
      try {
        final task = await _taskService.getTaskById(taskId);
        if (task != null && !task.completed) {
          await _taskService.updateTask(
            task.copyWith(completed: true, updatedAt: DateTime.now()),
          );
          print('[✅] Task $taskId được đánh dấu hoàn thành sau hạn.');
        } else {
          print('[ℹ️] Task $taskId đã hoàn thành hoặc không tồn tại.');
        }
      } catch (e) {
        print('[❌] Lỗi khi cập nhật task hoàn thành: $e');
      }
    });
  }
}
