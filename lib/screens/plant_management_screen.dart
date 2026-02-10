import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Required for Base64 images
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/toast_util.dart';
import 'add_plant_screen.dart'; // Ensure this matches your filename

class PlantManagementScreen extends StatefulWidget {
  const PlantManagementScreen({super.key});

  @override
  State<PlantManagementScreen> createState() => _PlantManagementScreenState();
}

class _PlantManagementScreenState extends State<PlantManagementScreen> {
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
      ToastUtil.error("Failed to load plants");
      setState(() => _isLoading = false);
    }
  }

  /// DELETE: Remove plant
  Future<void> _deletePlant(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/plant/$id'));
      if (response.statusCode == 200) {
        ToastUtil.success("Plant removed");
        _fetchPlants();
      }
    } catch (e) {
      ToastUtil.error("Delete failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("My Garden 🌿", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: _fetchPlants, icon: const Icon(Icons.refresh))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You have ${_plants.length} plants in your collection",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            _plants.isEmpty
                ? const Center(child: Text("No plants found. Add your first one!"))
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75,
              ),
              itemCount: _plants.length,
              itemBuilder: (context, index) {
                return _plantCard(_plants[index]);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlantScreen()),
          );
          if (result == true) _fetchPlants();
        },
        backgroundColor: const Color(0xFF0D47A1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Plant", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _plantCard(dynamic plant) {
    final String name = plant['name'] ?? "Unknown";
    final String description = plant['description'] ?? "No description";
    final String? imageBase64 = plant['imageBase64'];
    final String id = plant['id'] ?? plant['_id'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image Decoding Logic (Already correct in your code)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: imageBase64 != null && imageBase64.isNotEmpty
                    ? Image.memory(base64Decode(imageBase64), height: 100, width: 100, fit: BoxFit.cover)
                    : Container(height: 100, width: 100, color: Colors.green.shade50, child: Icon(Icons.eco)),
              ),
              const SizedBox(height: 12),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),

          // ACTION BUTTONS
          Positioned(
            top: 0,
            right: 0,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () async {
                    // Navigate to AddPlantScreen but pass existing data
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPlantScreen(plantData: plant)),
                    );
                    if (result == true) _fetchPlants();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDelete(id),
                ),
              ],
            ),
          )
        ],
      )
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Plant?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deletePlant(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}