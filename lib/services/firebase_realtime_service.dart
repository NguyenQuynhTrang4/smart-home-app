
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/device_model.dart';

class FirebaseRealtimeService {
  final DatabaseReference database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
      'https://smart-home-app-990a9-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  final List<DeviceModel> defaultDevices = [
    DeviceModel(
      id: 'living_light',
      name: 'Đèn',
      roomName: 'Phòng khách',
      isOn: false,
    ),
    DeviceModel(
      id: 'living_fan',
      name: 'Quạt',
      roomName: 'Phòng khách',
      isOn: false,
    ),
    DeviceModel(
      id: 'bed_light',
      name: 'Đèn',
      roomName: 'Phòng ngủ',
      isOn: false,
    ),
    DeviceModel(
      id: 'bed_fan',
      name: 'Quạt',
      roomName: 'Phòng ngủ',
      isOn: false,
    ),
    DeviceModel(
      id: 'kitchen_light',
      name: 'Đèn',
      roomName: 'Nhà bếp',
      isOn: false,
    ),
    DeviceModel(
      id: 'kitchen_fan',
      name: 'Quạt',
      roomName: 'Nhà bếp',
      isOn: false,
    ),
  ];

  Future<void> seedDefaultDevices() async {
    final snapshot = await database.child('devices').get();

    if (snapshot.exists) {
      return;
    }

    for (final device in defaultDevices) {
      await database.child('devices/${device.id}').set({
        'name': device.name,
        'roomName': device.roomName,
        'isOn': device.isOn,
      });
    }
  }

  Future<List<DeviceModel>> getAllDevices() async {
    await seedDefaultDevices();

    final snapshot = await database.child('devices').get();

    if (!snapshot.exists) {
      return [];
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    return data.entries.map((entry) {
      final value = Map<String, dynamic>.from(entry.value);

      return DeviceModel(
        id: entry.key,
        name: value['name'] ?? '',
        roomName: value['roomName'] ?? '',
        isOn: value['isOn'] ?? false,
      );
    }).toList();
  }

  Future<List<DeviceModel>> getDevicesByRoom(String roomName) async {
    final allDevices = await getAllDevices();

    return allDevices.where((device) {
      return device.roomName == roomName;
    }).toList();
  }

  Future<void> updateDeviceStatus(String deviceId, bool newStatus) async {
    await database.child('devices/$deviceId').update({
      'isOn': newStatus,
    });
  }

  Future<void> resetAll() async {
    final allDevices = await getAllDevices();

    for (final device in allDevices) {
      await database.child('devices/${device.id}').update({
        'isOn': false,
      });
    }
  }

  Future<void> resetDevicesByRoom(String roomName) async {
    final roomDevices = await getDevicesByRoom(roomName);

    for (final device in roomDevices) {
      await database.child('devices/${device.id}').update({
        'isOn': false,
      });
    }
  }

  Future<void> addActivityLog(String message) async {
    final now = DateTime.now();

    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    await database.child('activity_logs').push().set({
      'message': message,
      'time': time,
      'createdAt': now.millisecondsSinceEpoch,
    });
  }

  Future<List<String>> getActivityLogs() async {
    final snapshot = await database.child('activity_logs').get();

    if (!snapshot.exists) {
      return [];
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final logs = data.entries.map((entry) {
      final value = Map<String, dynamic>.from(entry.value);

      final time = value['time'] ?? '';
      final message = value['message'] ?? '';

      return '$time - $message';
    }).toList();

    logs.sort((a, b) => b.compareTo(a));

    return logs;
  }

  Future<void> clearActivityLogs() async {
    await database.child('activity_logs').remove();
  }
  Stream<List<DeviceModel>> watchDevicesByRoom(String roomName) {
    seedDefaultDevices();

    return database.child('devices').onValue.map((event) {
      if (event.snapshot.value == null) {
        return <DeviceModel>[];
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      final devices = data.entries.map((entry) {
        final value = Map<String, dynamic>.from(entry.value);

        return DeviceModel(
          id: entry.key,
          name: value['name'] ?? '',
          roomName: value['roomName'] ?? '',
          isOn: value['isOn'] ?? false,
        );
      }).where((device) {
        return device.roomName == roomName;
      }).toList();

      return devices;
    });
  }
}