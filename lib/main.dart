import 'package:flutter/material.dart';
import 'models/device_model.dart';
import 'pages/room_detail_page.dart';
import 'services/fake_api_service.dart';

void main() {
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
  final FakeApiService apiService = FakeApiService();

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

    final result = await apiService.getAllDevices();

    if (!mounted) return;

    setState(() {
      allDevices = result;
      isLoading = false;
    });
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