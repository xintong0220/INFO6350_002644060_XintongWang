import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription? subscription;
  RemoteConfigUpdate? update;
  Timer? _notificationTimer;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


  Future<void> _startPeriodicNotification(int intervalSeconds) async {
    _notificationTimer?.cancel(); // Cancel previous timer if any

    if (intervalSeconds > 0) {
      _notificationTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
        _showNotification('Reminder', 'This is your periodic notification.');
      });
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'periodic_channel',
      'Periodic Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Config Example'),
      ),
      body: Column(
        children: [
          _ButtonAndText(
            defaultText: 'Not initialized',
            buttonText: 'Initialize',
            onPressed: () async {
              final FirebaseRemoteConfig remoteConfig =
                  FirebaseRemoteConfig.instance;
              await remoteConfig.setConfigSettings(
                RemoteConfigSettings(
                  fetchTimeout: const Duration(seconds: 10),
                  minimumFetchInterval: const Duration(hours: 1),
                ),
              );
              await remoteConfig.setDefaults(<String, dynamic>{
                'welcome': 'default welcome',
                'periodic_local_notification': 15,
              });
              return 'Initialized';
            },
          ),
          _ButtonAndText(
            defaultText: 'No data',
            buttonText: 'Fetch Activate',
            onPressed: () async {
              try {
                final FirebaseRemoteConfig remoteConfig =
                    FirebaseRemoteConfig.instance;
                await remoteConfig.setConfigSettings(
                  RemoteConfigSettings(
                    fetchTimeout: const Duration(seconds: 10),
                    minimumFetchInterval: Duration.zero,
                  ),
                );
                await remoteConfig.fetchAndActivate();

                final interval =
                    remoteConfig.getInt('periodic_local_notification');
                await _startPeriodicNotification(interval);

                return 'Fetched. Interval: $interval seconds';
              } on PlatformException catch (e) {
                print(e);
                return 'Exception: $e';
              } catch (e) {
                print(e);
                return 'Unable to fetch config.';
              }
            },
          ),
          _ButtonAndText(
            defaultText: update != null
                ? 'Updated keys: ${update?.updatedKeys}'
                : 'No data',
            buttonText: subscription != null ? 'Cancel' : 'Listen',
            onPressed: () async {
              try {
                final FirebaseRemoteConfig remoteConfig =
                    FirebaseRemoteConfig.instance;
                if (subscription != null) {
                  await subscription!.cancel();
                  setState(() {
                    subscription = null;
                  });
                  return 'Listening cancelled';
                }
                setState(() {
                  subscription = remoteConfig.onConfigUpdated.listen((event) async {
                    await remoteConfig.activate();
                    final interval = remoteConfig.getInt('periodic_local_notification');
                    await _startPeriodicNotification(interval);
                    setState(() {
                      update = event;
                    });
                  });
                });

                return 'Listening for updates...';
              } on PlatformException catch (e) {
                print(e);
                return 'Exception: $e';
              } catch (e) {
                print(e);
                return 'Failed to listen to updates.';
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ButtonAndText extends StatefulWidget {
  const _ButtonAndText({
    Key? key,
    required this.defaultText,
    required this.buttonText,
    required this.onPressed,
  }) : super(key: key);

  final String defaultText;
  final String buttonText;
  final Future<String> Function() onPressed;

  @override
  State<_ButtonAndText> createState() => _ButtonAndTextState();
}

class _ButtonAndTextState extends State<_ButtonAndText> {
  String? _text;

  @override
  void didUpdateWidget(covariant _ButtonAndText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultText != oldWidget.defaultText) {
      setState(() {
        _text = widget.defaultText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(child: Text(_text ?? widget.defaultText)),
          ElevatedButton(
            onPressed: () async {
              final result = await widget.onPressed();
              setState(() {
                _text = result;
              });
            },
            child: Text(widget.buttonText),
          ),
        ],
      ),
    );
  }
}
