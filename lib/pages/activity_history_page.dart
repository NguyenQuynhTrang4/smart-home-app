import 'package:flutter/material.dart';
import '../services/firebase_realtime_service.dart';

class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  final FirebaseRealtimeService apiService = FirebaseRealtimeService();

  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  Future<void> loadLogs() async {
    final result = await apiService.getActivityLogs();

    setState(() {
      logs = result;
    });
  }

  Future<void> clearLogs() async {
    await apiService.clearActivityLogs();
    await loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử hoạt động'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearLogs,
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(
              child: Text('Chưa có hoạt động nào'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(logs[index]),
                  ),
                );
              },
            ),
    );
  }
}