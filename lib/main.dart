import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'models/device_model.dart';
import 'pages/room_detail_page.dart';
import 'services/firebase_realtime_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Khởi tạo Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseRealtimeService apiService = FirebaseRealtimeService();

  final List<String> rooms = [
    'Phòng khách',
    'Phòng ngủ',
    'Nhà bếp',
  ];

  List<DeviceModel> allDevices = [];
  bool isLoading = true;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await apiService.getAllDevices();

      if (!mounted) return;

      setState(() {
        allDevices = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải dữ liệu Firebase: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  List<String> get filteredRooms {
    return rooms
        .where((room) => room.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  int getTotalDevices(String roomName) {
    return allDevices.where((d) => d.roomName == roomName).length;
  }

  int getActiveDevices(String roomName) {
    return allDevices.where((d) => d.roomName == roomName && d.isOn).length;
  }

  Future<void> resetAllRooms() async {
    await apiService.resetAll();
    await loadDashboard();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã reset toàn bộ phòng'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadDashboard,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: resetAllRooms,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🔥 nền icon nhà
          Center(
            child: Icon(
              Icons.home,
              size: 260,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
            ),
          ),

          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: loadDashboard,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 🔍 search
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Tìm phòng...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // 📦 danh sách phòng
                      ...filteredRooms.map((room) {
                        return roomCard(context, room);
                      }).toList(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget roomCard(BuildContext context, String name) {
    final total = getTotalDevices(name);
    final active = getActiveDevices(name);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.home_outlined, size: 32),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$total thiết bị • Đang bật: $active',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomDetailPage(roomName: name),
            ),
          );

          loadDashboard();
        },
      ),
    );
  }
}