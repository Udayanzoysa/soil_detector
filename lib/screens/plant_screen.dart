import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'add_plant_screen.dart'; // Ensure this path is correct
import '../utils/toast_util.dart';

class PlantScreen extends StatefulWidget {
  const PlantScreen({super.key});

  @override
  State<PlantScreen> createState() => _PlantScreenState();
}

class _PlantScreenState extends State<PlantScreen> {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000/api';
  List<dynamic> _plants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlants();
  }

  /// GET: Fetch plants from Backend
  Future<void> _fetchPlants() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/plant?userId=1'));

      if (response.statusCode == 200) {
        setState(() {
          _plants = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      ToastUtil.error("Failed to load your garden");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchPlants,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "My Garden 🌿",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "You have ${_plants.length} plants in your collection",
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 25),

                /// Priority Section (Static UI for now)
                const Text(
                  "Priority Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _priorityCard("Watering", "3 Plants", Icons.opacity, Colors.blue),
                      _priorityCard("Fertilizing", "1 Plant", Icons.auto_awesome, Colors.orange),
                      _priorityCard("Pruning", "0 Plants", Icons.content_cut, Colors.green),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Your Collection",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                        onPressed: _fetchPlants,
                        child: const Text("Refresh")
                    ),
                  ],
                ),

                /// Dynamic Plant Grid
                _plants.isEmpty
                    ? const Center(child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text("Your garden is empty. Add a plant!"),
                ))
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _plants.length,
                  itemBuilder: (context, index) {
                    final plant = _plants[index];
                    return _plantItem(
                      plant['name'] ?? "Unknown",
                      plant['description'] ?? "Healthy",
                      plant['imageBase64'],
                      Colors.green,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlantScreen()),
          );
          if (result == true) _fetchPlants(); // Refresh list if new plant added
        },
        backgroundColor: const Color(0xFF0D47A1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Plant", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _priorityCard(String title, String count, IconData icon, Color color) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(count, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _plantItem(String name, String status, String? base64Img, Color statusColor) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Decoder
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: base64Img != null && base64Img.isNotEmpty
                  ? Image.memory(
                base64Decode(base64Img),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
              )
                  : const Icon(Icons.eco, size: 40, color: Colors.green),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  status,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}