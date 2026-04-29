import 'dart:async';

import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/firebase_realtime_service.dart';
import 'activity_history_page.dart';

class RoomDetailPage extends StatefulWidget {
  final String roomName;

  const RoomDetailPage({super.key, required this.roomName});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final FirebaseRealtimeService apiService = FirebaseRealtimeService();

  List<DeviceModel> devices = [];
  bool isLoading = true;
  Set<String> loadingDevices = {};
  String searchText = "";

  StreamSubscription<List<DeviceModel>>? devicesSubscription;

  @override
  void initState() {
    super.initState();
    listenDevices();
  }

  @override
  void dispose() {
    devicesSubscription?.cancel();
    super.dispose();
  }

  void listenDevices() {
    setState(() {
      isLoading = true;
    });

    devicesSubscription =
        apiService.watchDevicesByRoom(widget.roomName).listen(
      (result) {
        if (!mounted) return;

        setState(() {
          devices = result;
          isLoading = false;
        });
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi realtime Firebase: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Future<void> refreshDevices() async {
    final result = await apiService.getDevicesByRoom(widget.roomName);

    if (!mounted) return;

    setState(() {
      devices = result;
    });
  }

  Future<void> toggleDevice(DeviceModel device, bool value) async {
    final oldValue = device.isOn;

    setState(() {
      loadingDevices.add(device.id);
      device.isOn = value;
    });

    try {
      await apiService.updateDeviceStatus(device.id, value);

      await apiService.addActivityLog(
        '${value ? 'Bật' : 'Tắt'} ${device.name} - ${widget.roomName}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Đã bật ${device.name}' : 'Đã tắt ${device.name}',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      setState(() {
        device.isOn = oldValue;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không kết nối được'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        loadingDevices.remove(device.id);
      });
    }
  }

  List<DeviceModel> get filteredDevices {
    return devices
        .where((d) => d.name.toLowerCase().contains(searchText))
        .toList();
  }

  Future<void> resetCurrentRoom() async {
    await apiService.resetDevicesByRoom(widget.roomName);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã reset thiết bị trong phòng này'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ActivityHistoryPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetCurrentRoom,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Tìm thiết bị...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: refreshDevices,
                      child: ListView.separated(
                        itemCount: filteredDevices.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final device = filteredDevices[index];
                          return deviceTile(device);
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget deviceTile(DeviceModel device) {
    final IconData icon =
        device.name == 'Đèn' ? Icons.lightbulb : Icons.air;

    return Card(
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(device.name),
        subtitle: Text(device.isOn ? 'Đang bật' : 'Đang tắt'),
        trailing: loadingDevices.contains(device.id)
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Switch(
                value: device.isOn,
                onChanged: (value) {
                  toggleDevice(device, value);
                },
              ),
      ),
    );
  }
}