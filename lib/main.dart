import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart'; // Để check kIsWeb
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';


class SurveyRecord {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final int lightLux;
  final double dynamicMagnitude;
  final double magneticMagnitude;

  SurveyRecord({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.lightLux,
    required this.dynamicMagnitude,
    required this.magneticMagnitude,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'lightLux': lightLux,
        'dynamicMagnitude': dynamicMagnitude,
        'magneticMagnitude': magneticMagnitude,
      };

  factory SurveyRecord.fromJson(Map<String, dynamic> json) {
    return SurveyRecord(
      timestamp: DateTime.parse(json['timestamp']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      lightLux: json['lightLux'],
      dynamicMagnitude: json['dynamicMagnitude'],
      magneticMagnitude: json['magneticMagnitude'],
    );
  }
}

void main() {
  runApp(const SchoolHeatmapApp());
}

class SchoolHeatmapApp extends StatelessWidget {
  const SchoolHeatmapApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bản đồ nhiệt Sân trường (Laptop Mode)',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const SurveyStationScreen(), // Màn hình khảo sát
    const DataMapScreen(),       // Màn hình bản đồ
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: "Trạm Khảo sát"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Bản đồ Dữ liệu"),
        ],
      ),
    );
  }
}

// --- MÀN HÌNH KHẢO SÁT ----
class SurveyStationScreen extends StatefulWidget {
  const SurveyStationScreen({super.key});
  @override
  State<SurveyStationScreen> createState() => _SurveyStationScreenState();
}

class _SurveyStationScreenState extends State<SurveyStationScreen> {
  // Giá trị cảm biến
  double _luxValue = 0;
  double _accelValue = 0;
  double _magnetValue = 0;

  // Biến kiểm tra môi trường: Nếu chạy trên Windows/Web thì là true
  bool _isSimulationMode = false;
  
  // Stream subscriptions
  StreamSubscription? _lightSub;
  StreamSubscription? _accelSub;
  StreamSubscription? _magnetSub;

  @override
  void initState() {
    super.initState();
    _checkEnvironment();
  }

  void _checkEnvironment() {
    // Nếu chạy trên Web hoặc Windows, tự động bật chế độ giả lập
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setState(() {
        _isSimulationMode = true;
        // Giá trị mặc định ban đầu
        _luxValue = 500; 
        _accelValue = 0.5; 
        _magnetValue = 40;
      });
    } else {
      // Nếu là điện thoại thật, thì khởi động cảm biến
      _initRealSensors();
    }
  }

  void _initRealSensors() {
    try {
      _lightSub = Light().lightSensorStream.listen((lux) {
        setState(() => _luxValue = lux.toDouble());
      });
      _accelSub = userAccelerometerEventStream().listen((event) {
        double magnitude = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
        setState(() => _accelValue = magnitude);
      });
      _magnetSub = magnetometerEventStream().listen((event) {
        double magnitude = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
        setState(() => _magnetValue = magnitude);
      });
    } catch (e) {
      // Nếu lỗi cảm biến, chuyển sang chế độ giả lập
      setState(() => _isSimulationMode = true);
    }
  }

  @override
  void dispose() {
    _lightSub?.cancel();
    _accelSub?.cancel();
    _magnetSub?.cancel();
    super.dispose();
  }

  Future<void> _recordData() async {
    // Giả lập tọa độ GPS ngẫu nhiên quanh một điểm (để test)
    // Vĩ độ sân trường giả định: 21.0
    double lat = 21.00000 + (Random().nextInt(100) / 10000); 
    double long = 105.80000 + (Random().nextInt(100) / 10000);

    // Nếu có thiết bị thật thì lấy GPS thật (code cũ), ở đây mình rút gọn cho trường hợp Laptop
    
    final record = SurveyRecord(
      timestamp: DateTime.now(),
      latitude: lat,
      longitude: long,
      lightLux: _luxValue.toInt(),
      dynamicMagnitude: _accelValue,
      magneticMagnitude: _magnetValue,
    );

    await _saveToFile(record);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã ghi dữ liệu (Mô phỏng)!')));
  }
  
  // Lưu file (Phiên bản tương thích Web/Windows dùng shared_preferences hoặc local storage giả định)
  Future<void> _saveToFile(SurveyRecord record) async {
      mockDatabase.add(record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSimulationMode ? 'Trạm Khảo sát (GIẢ LẬP)' : 'Trạm Khảo sát')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_isSimulationMode) ...[
                const Text("Bạn đang chạy trên Laptop. Hãy kéo thanh trượt để giả lập môi trường:", 
                  style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
                const Divider(),
                _buildSlider("Ánh sáng (Lux)", _luxValue, 0, 2000, (v) => setState(() => _luxValue = v)),
                _buildSlider("Độ Năng động", _accelValue, 0, 10, (v) => setState(() => _accelValue = v)),
                _buildSlider("Từ trường", _magnetValue, 0, 200, (v) => setState(() => _magnetValue = v)),
                const Divider(),
              ],
              _buildSensorCard("Ánh sáng", "${_luxValue.toInt()} lux", Icons.wb_sunny, Colors.orange),
              _buildSensorCard("Năng động", "${_accelValue.toStringAsFixed(2)} m/s²", Icons.directions_run, Colors.red),
              _buildSensorCard("Từ trường", "${_magnetValue.toStringAsFixed(2)} µT", Icons.explore, Colors.blue),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _recordData,
                icon: const Icon(Icons.save),
                label: const Text("GHI DỮ LIỆU"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toInt()}"),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- DATABASE GIẢ (Trong RAM) ĐỂ CHẠY TRÊN MỌI THIẾT BỊ ---
List<SurveyRecord> mockDatabase = [];

class DataMapScreen extends StatefulWidget {
  const DataMapScreen({super.key});
  @override
  State<DataMapScreen> createState() => _DataMapScreenState();
}

class _DataMapScreenState extends State<DataMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ Dữ liệu'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() {}))],
      ),
      body: mockDatabase.isEmpty 
        ? const Center(child: Text("Chưa có dữ liệu. Hãy sang tab Khảo sát để ghi.")) 
        : ListView.builder(
            itemCount: mockDatabase.length,
            itemBuilder: (context, index) {
              final record = mockDatabase[mockDatabase.length - 1 - index]; // Đảo ngược
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Tọa độ: ${record.latitude.toStringAsFixed(4)}, ${record.longitude.toStringAsFixed(4)}"),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Sáng: ${record.lightLux}"),
                      Text("Động: ${record.dynamicMagnitude.toStringAsFixed(1)}"),
                      Text("Từ: ${record.magneticMagnitude.toStringAsFixed(1)}"),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}