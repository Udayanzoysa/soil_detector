import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/toast_util.dart';

class SoilFormScreen extends StatefulWidget {
  final Map<String, dynamic>? soilData;

  const SoilFormScreen({super.key, this.soilData});

  @override
  State<SoilFormScreen> createState() => _SoilFormScreenState();
}

class _SoilFormScreenState extends State<SoilFormScreen> {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  final _nameCtrl = TextEditingController();
  final _textureCtrl = TextEditingController();
  final _phCtrl = TextEditingController();
  final _drainageCtrl = TextEditingController();

  bool _isSaving = false;
  bool get isEditing => widget.soilData != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameCtrl.text = widget.soilData!['name']?.toString() ?? '';
      _textureCtrl.text = widget.soilData!['texture']?.toString() ?? '';
      _phCtrl.text = widget.soilData!['ph']?.toString() ?? '';
      _drainageCtrl.text = widget.soilData!['drainage']?.toString() ?? '';
    }
  }

  Future<void> _saveSoil() async {
    // 1. Basic Validation
    if (_nameCtrl.text.isEmpty || _textureCtrl.text.isEmpty) {
      ToastUtil.error("Please fill required fields");
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 2. Parse pH safely (Default to 0.0 if empty or invalid)
      double phValue = double.tryParse(_phCtrl.text.trim()) ?? 0.0;

      // 3. Prepare Data Map (FIXED KEYS HERE)
      final Map<String, dynamic> data = {
        'userId': "1",           // Fixed ID for now
        'soilName': _nameCtrl.text.trim(), // CHANGED from 'name' to 'soilName'
        'texture': _textureCtrl.text.trim(),
        'soilPh': phValue,       // CHANGED from 'ph' to 'soilPh' (and sent as number)
        'drainage': _drainageCtrl.text.trim(),
      };

      print("Sending Data: $data"); // Debug print to verify keys

      final headers = {'Content-Type': 'application/json'};
      http.Response response;

      // 4. Send Request
      if (isEditing) {
        // Handle ID mismatch (MongoDB uses _id, SQL uses id)
        final id = widget.soilData!['id']?.toString() ?? widget.soilData!['_id']?.toString();

        response = await http.put(
          Uri.parse('$baseUrl/soil/$id'), // Ensure ID is part of URL
          headers: headers,
          body: jsonEncode(data),
        );
      } else {
        response = await http.post(
          Uri.parse('$baseUrl/soil'),
          headers: headers,
          body: jsonEncode(data),
        );
      }

      // 5. Handle Response
      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastUtil.success(isEditing ? "Updated!" : "Saved!");
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        print("SERVER ERROR: ${response.body}");
        // Parse the error message from backend if possible
        try {
          final errorJson = jsonDecode(response.body);
          ToastUtil.error(errorJson['error'] ?? "Server Error");
        } catch (_) {
          ToastUtil.error("Server Error: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("CONNECTION ERROR: $e");
      ToastUtil.error("Connection failed");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Soil" : "Add Soil"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nameCtrl, "Soil Name", Icons.badge),
              _buildTextField(_textureCtrl, "Texture (e.g. Clay, Sandy)", Icons.texture),
              _buildTextField(_phCtrl, "pH Level", Icons.science, isNumber: true),
              _buildTextField(_drainageCtrl, "Drainage (High/Low)", Icons.water_drop),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _saveSoil,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? "Update Details" : "Save Soil Data"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _textureCtrl.dispose();
    _phCtrl.dispose();
    _drainageCtrl.dispose();
    super.dispose();
  }
}