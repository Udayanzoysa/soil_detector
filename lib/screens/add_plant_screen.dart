import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/toast_util.dart';

class AddPlantScreen extends StatefulWidget {
  // Added plantData parameter to handle editing
  final Map<String, dynamic>? plantData;

  const AddPlantScreen({super.key, this.plantData});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _nameCtrl = TextEditingController();
  final _speciesCtrl = TextEditingController();
  final _waterCtrl = TextEditingController();

  File? _selectedImage;
  bool _isSaving = false;
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  // Helper to check if we are in Edit mode
  bool get isEditing => widget.plantData != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers if editing
    if (isEditing) {
      _nameCtrl.text = widget.plantData!['name'] ?? '';

      // Parsing the description back into species and water cycle fields
      String desc = widget.plantData!['description'] ?? '';
      if (desc.contains("Species: ") && desc.contains(", Cycle: ")) {
        _speciesCtrl.text = desc.split("Species: ")[1].split(", Cycle: ")[0];
        _waterCtrl.text = desc.split(", Cycle: ")[1];
      } else {
        _speciesCtrl.text = desc;
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _savePlant() async {
    final name = _nameCtrl.text.trim();
    final description = "Species: ${_speciesCtrl.text.trim()}, Cycle: ${_waterCtrl.text.trim()}";

    if (name.isEmpty) {
      ToastUtil.error("Plant Name is required");
      return;
    }

    setState(() => _isSaving = true);

    String? base64Image;
    if (_selectedImage != null) {
      base64Image = base64Encode(_selectedImage!.readAsBytesSync());
    } else if (isEditing) {
      // Keep existing image if no new one is selected
      base64Image = widget.plantData!['imageBase64'];
    }

    try {
      http.Response response;
      final headers = {"Content-Type": "application/json"};
      final body = jsonEncode({
        "userId": "1",
        "name": name,
        "description": description,
        "imageBase64": base64Image,
      });

      if (isEditing) {
        // UPDATE: Call /api/plant/[id] with PUT
        final id = widget.plantData!['id'] ?? widget.plantData!['_id'];
        response = await http.put(
          Uri.parse('$baseUrl/plant/$id'),
          headers: headers,
          body: body,
        );
      } else {
        // CREATE: Call /api/plant with POST
        response = await http.post(
          Uri.parse('$baseUrl/plant'),
          headers: headers,
          body: body,
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        ToastUtil.success(isEditing ? "Plant updated!" : "Plant added!");
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        print("Backend Error: ${response.body}");
        ToastUtil.error("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Connection Error: $e");
      ToastUtil.error("Server connection failed");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(isEditing ? "Edit Plant" : "Add New Plant",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Image Picker UI
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                    : isEditing && widget.plantData!['imageBase64'] != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(
                    base64Decode(widget.plantData!['imageBase64']),
                    fit: BoxFit.cover,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const Text("Change Plant Photo", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            _buildInput(label: "Plant Name", hint: "Enter plant name", controller: _nameCtrl),
            const SizedBox(height: 16),
            _buildInput(label: "Species", hint: "e.g., Succulent, Vegetable", controller: _speciesCtrl),
            const SizedBox(height: 16),
            _buildInput(label: "Watering Cycle", hint: "e.g., Every 3 days", controller: _waterCtrl),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _savePlant,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? "Update Plant" : "Save Plant",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({required String label, required String hint, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _speciesCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }
}