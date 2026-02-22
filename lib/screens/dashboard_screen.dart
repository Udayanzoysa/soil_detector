import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/toast_util.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  File? image;
  bool _isAnalyzing = false;
  bool analyzed = false;
  bool _isLoadingUser = true;

  // Data received from AI Backend
  Map<String, dynamic>? _analysisResult;

  late Timer _timer;
  DateTime now = DateTime.now();

  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  // Dynamic user data
  String userName = "Loading...";
  String userEmail = "...";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Fetch User Details from API
  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users?id=1'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userName = data['name'] ?? "User";
          userEmail = data['email'] ?? "";
          _isLoadingUser = false;
        });
      } else {
        setState(() => _isLoadingUser = false);
        ToastUtil.error("Failed to load user profile");
      }
    } catch (e) {
      setState(() => _isLoadingUser = false);
      print("User Fetch Error: $e");
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF0D47A1)),
              title: const Text('Upload from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0D47A1)),
              title: const Text('Capture with Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
      );
      if (picked != null) {
        setState(() {
          image = File(picked.path);
          analyzed = false;
          _analysisResult = null;
        });
      }
    } catch (e) {
      ToastUtil.error("Error picking image");
    }
  }
  Future<void> _analyzeSoil() async {
    if (image == null) return;
    setState(() => _isAnalyzing = true);

    try {
      final bytes = await image!.readAsBytes();
      final String base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$baseUrl/soil/analyze'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "imageBase64": base64Image,
          "userId": "1", // Pass as string to match backend type
        }),
      );

      // Handle the 201 Created response from your new backend
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _analysisResult = jsonDecode(response.body);
          analyzed = true;
        });
        ToastUtil.success("Soil Processed Successfully!");
      } else {
        print("Backend Error: ${response.body}");
        ToastUtil.error("Analysis Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Connection Error: $e");
      ToastUtil.error("Server connection lost");
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Widget _resultCard() {
    if (_analysisResult == null) return const SizedBox();

    String soilName = _analysisResult!['soilName']?.toString() ?? "Unknown";
    List<String> crops = _getPlantsForSoil(soilName);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Analysis Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
          const Divider(height: 24),
          _Row("Soil Type", soilName),
          _Row("Texture", _analysisResult!['texture']?.toString() ?? "N/A"),
          _Row("pH Level", _analysisResult!['soilPh']?.toString() ?? "N/A"),
          _Row("Drainage", _analysisResult!['drainage']?.toString() ?? "N/A"),
          const SizedBox(height: 20),
          const Text("🌾 Recommended Crops:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: crops.map((crop) => Chip(
              label: Text(crop, style: const TextStyle(fontSize: 12)),
              backgroundColor: const Color(0xFFE3F2FD),
            )).toList(),
          ),
          const SizedBox(height: 16),
          // Specific Recommendation Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
            child: Text(
                _analysisResult!['recommendation']?.toString() ?? "Ready for planting.",
                style: TextStyle(fontSize: 13, color: Colors.green.shade900)
            ),
          )
        ],
      ),
    );
  }

  // --- LOGIC FOR RECOMMENDATIONS ---
  List<String> _getPlantsForSoil(String? soilType) {
    if (soilType == null) return [];
    String st = soilType.toLowerCase();

    if (st.contains("black")) return ["Cotton", "Sugarcane", "Sunflower", "Millets", "Wheat"];
    if (st.contains("red")) return ["Groundnut", "Potato", "Rice", "Ragi", "Tobacco"];
    if (st.contains("clay")) return ["Rice", "Lettuce", "Broccoli", "Cabbage", "Soybean"];
    if (st.contains("sandy")) return ["Watermelon", "Coconut", "Corn", "Peanuts", "Cactus"];
    if (st.contains("loam")) return ["Tomato", "Peppers", "Carrots", "Spinach", "Onions"];
    if (st.contains("silt")) return ["Strawberries", "Tomatoes", "Corn", "Wheat"];

    return ["Wheat", "Rice", "Corn", "Beans"]; // Default fallback
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
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
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
        child: _isLoadingUser
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              // Conditional rendering: Show Result if analyzed, else show info cards
              if (!analyzed) ...[
                _infoCard(icon: Icons.wb_sunny, title: "Weather", value: "28°C • Sunny"),
                const SizedBox(height: 12),
                _infoCard(
                  icon: Icons.check_circle,
                  title: "System Status",
                  value: _isAnalyzing ? "ANALYZING..." : "READY",
                  color: Colors.blue,
                ),
              ],
              const SizedBox(height: 20),
              _buildCameraSection(),
              const SizedBox(height: 16),
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
              // Show result only if analyzed
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
      onTap: _showImageSourceOptions,
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
            Icon(Icons.add_a_photo, size: 40, color: Color(0xFF0D47A1)),
            SizedBox(height: 8),
            Text("Tap to capture or upload soil image"),
          ],
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(image!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _tipsCard() {
    // Default tips if not analyzed yet
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Text("🌱 General Soil Tips", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _tipRow(Icons.water_drop, "Watering", "Most crops prefer early morning watering."),
          _tipRow(Icons.wb_sunny, "Sunlight", "Ensure at least 6 hours of direct sunlight."),
          _tipRow(Icons.science, "Testing", "Test pH levels every season."),
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