import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/toast_util.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  File? image;
  bool _isAnalyzing = false;
  bool analyzed = false;

  // Data received from AI Backend
  Map<String, dynamic>? _analysisResult;

  late Timer _timer;
  DateTime now = DateTime.now();

  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000/api';
  final String userName = "Udaya Perera";
  final String userEmail = "udaya@gmail.com";

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() {
        image = File(picked.path);
        analyzed = false;
        _analysisResult = null;
      });
    }
  }

  /// API Call to AI Backend
  Future<void> _analyzeSoil() async {
    if (image == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final bytes = await image!.readAsBytes();
      final String base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$baseUrl/soil/analyze'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"imageBase64": base64Image}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _analysisResult = jsonDecode(response.body);
          analyzed = true;
        });
        ToastUtil.success("AI Analysis Complete");
      } else {
        ToastUtil.error("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      ToastUtil.error("Failed to connect to AI server");
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void showProfileSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(userEmail),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context),
                child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Welcome Header
              _buildHeader(),

              const SizedBox(height: 20),

              /// Summary Cards
              _infoCard(icon: Icons.wb_sunny, title: "Weather", value: "28°C • Sunny"),
              const SizedBox(height: 12),
              _infoCard(
                icon: Icons.check_circle,
                title: "System Status",
                value: _isAnalyzing ? "ANALYZING..." : (analyzed ? "COMPLETE" : "READY"),
                color: analyzed ? Colors.green : Colors.blue,
              ),

              const SizedBox(height: 20),

              /// Camera Section
              _buildCameraSection(),

              const SizedBox(height: 16),

              /// AI Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: image == null || _isAnalyzing ? null : _analyzeSoil,
                  child: _isAnalyzing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Analyze Soil with AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),

              /// Results or Tips
              analyzed ? _resultCard() : _tipsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const CircleAvatar(radius: 24, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome back 👋", style: TextStyle(color: Colors.grey.shade600)),
              Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("${DateFormat('dd MMM').format(now)} • ${DateFormat('hh:mm a').format(now)}",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: showProfileSheet),
        ],
      ),
    );
  }

  Widget _buildCameraSection() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: image == null
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 40, color: Color(0xFF0D47A1)),
            SizedBox(height: 8),
            Text("Tap to capture soil for AI analysis"),
          ],
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(image!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _resultCard() {
    if (_analysisResult == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("AI Analysis Result", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
          const Divider(height: 24),
          // Use .toString() to prevent the double-to-string error
          _Row("Soil Type", _analysisResult!['soilName']?.toString() ?? "N/A"),
          _Row("Texture", _analysisResult!['texture']?.toString() ?? "N/A"),
          _Row("pH Level", _analysisResult!['ph']?.toString() ?? "N/A"),
          _Row("Drainage", _analysisResult!['drainage']?.toString() ?? "N/A"),
          const SizedBox(height: 15),
          const Text("AI Recommendation:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(
              _analysisResult!['recommendation']?.toString() ?? "Match crops to these conditions for best yield.",
              style: const TextStyle(fontSize: 13, color: Colors.grey)
          ),
        ],
      ),
    );
  }

  // Inside your DashboardScreen state
  Widget _tipsCard() {
    final soilType = _analysisResult?['soilName']?.toString().toLowerCase() ?? "";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Text("🌱 Smart Soil Tips", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (soilType.contains("black")) ...[
            _tipRow(Icons.water_drop, "Watering", "Black soil holds water well; avoid over-watering."),
            _tipRow(Icons.agriculture, "Crop", "Perfect for cotton or sunflower."),
          ] else if (soilType.contains("sandy")) ...[
            _tipRow(Icons.opacity, "Watering", "Sandy soil drains fast; water more frequently."),
            _tipRow(Icons.eco, "Nutrients", "Add organic compost to help hold nutrients."),
          ] else ...[
            _tipRow(Icons.science, "pH Check", "Always monitor pH levels for optimal growth."),
            _tipRow(Icons.eco, "Mulching", "Use mulch to maintain soil temperature."),
          ],
        ],
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String value, Color color = const Color(0xFF0D47A1)}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tipRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: const Color(0xFFE3F2FD), child: Icon(icon, color: const Color(0xFF0D47A1), size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String left;
  final String right;
  const _Row(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(color: Colors.grey)),
          Text(right, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}