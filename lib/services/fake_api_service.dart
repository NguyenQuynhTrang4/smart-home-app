import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_model.dart';

class FakeApiService {
  static final List<DeviceModel> _devices = [
    DeviceModel(id: 'living_light', name: 'Đèn', roomName: 'Phòng khách', isOn: false),
    DeviceModel(id: 'living_fan', name: 'Quạt', roomName: 'Phòng khách', isOn: false),
    DeviceModel(id: 'bed_light', name: 'Đèn', roomName: 'Phòng ngủ', isOn: false),
    DeviceModel(id: 'bed_fan', name: 'Quạt', roomName: 'Phòng ngủ', isOn: false),
    DeviceModel(id: 'kitchen_light', name: 'Đèn', roomName: 'Nhà bếp', isOn: false),
    DeviceModel(id: 'kitchen_fan', name: 'Quạt', roomName: 'Nhà bếp', isOn: false),
  ];

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    for (var device in _devices) {
      device.isOn = prefs.getBool(device.id) ?? false;
    }
  }

  Future<void> saveToStorage(DeviceModel device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(device.id, device.isOn);
  }

  Future<List<DeviceModel>> getDevicesByRoom(String roomName) async {
    await loadFromStorage();
    await Future.delayed(const Duration(milliseconds: 500));

    return _devices
        .where((device) => device.roomName == roomName)
        .map((d) => DeviceModel(
              id: d.id,
              name: d.name,
              roomName: d.roomName,
              isOn: d.isOn,
            ))
        .toList();
  }

  Future<List<DeviceModel>> getAllDevices() async {
    await loadFromStorage();
    await Future.delayed(const Duration(milliseconds: 500));

    return _devices
        .map((d) => DeviceModel(
              id: d.id,
              name: d.name,
              roomName: d.roomName,
              isOn: d.isOn,
            ))
        .toList();
  }

  Future<void> updateDeviceStatus(String deviceId, bool newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final device = _devices.firstWhere((d) => d.id == deviceId);
    device.isOn = newStatus;

    await saveToStorage(device);
  }

  Future<void> resetDevicesByRoom(String roomName) async {
    final prefs = await SharedPreferences.getInstance();

    for (var device in _devices) {
      if (device.roomName == roomName) {
        device.isOn = false;
        await prefs.remove(device.id);
      }
    }
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();

    for (var device in _devices) {
      device.isOn = false;
      await prefs.remove(device.id);
    }
  }

  Future<void> addActivityLog(String message) async {
    final prefs = await SharedPreferences.getInstance();

    final logs = prefs.getStringList('activity_logs') ?? [];

    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    logs.insert(0, '$time - $message');

    await prefs.setStringList('activity_logs', logs);
  }

  Future<List<String>> getActivityLogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('activity_logs') ?? [];
  }

  Future<void> clearActivityLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('activity_logs');
  }
}