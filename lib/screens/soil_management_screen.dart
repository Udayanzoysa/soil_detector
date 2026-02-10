import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/toast_util.dart';
import 'soil_form_screen.dart'; // Make sure this import is correct

class SoilManagementScreen extends StatefulWidget {
  const SoilManagementScreen({super.key});

  @override
  State<SoilManagementScreen> createState() => _SoilManagementScreenState();
}

class _SoilManagementScreenState extends State<SoilManagementScreen> {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  List<dynamic> _soilData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSoils();
  }

  /// GET: Fetch soils from API
  Future<void> _fetchSoils() async {
    setState(() => _isLoading = true);
    try {
      // Fetching for userId=1 (Hardcoded for now)
      final response = await http.get(Uri.parse('$baseUrl/soil?userId=1'));

      if (response.statusCode == 200) {
        setState(() {
          _soilData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        ToastUtil.error("Server Error: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("FETCH ERROR: $e");
      ToastUtil.error("Failed to load data");
      setState(() => _isLoading = false);
    }
  }

  /// DELETE: Remove soil from API
  Future<void> _deleteSoil(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/soil/$id'));

      if (response.statusCode == 200) {
        ToastUtil.success("Deleted successfully");
        _fetchSoils(); // Refresh the list
      } else {
        ToastUtil.error("Delete failed: ${response.statusCode}");
      }
    } catch (e) {
      ToastUtil.error("Connection error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soil Management"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Wait for result from form screen to refresh list
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SoilFormScreen()),
          );
          if (result == true) _fetchSoils();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _soilData.isEmpty
          ? const Center(child: Text("No soil records found"))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Allows wide table to scroll
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFECEFF1)),
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Texture")),
                DataColumn(label: Text("pH")),
                DataColumn(label: Text("Drainage")),
                DataColumn(label: Text("Actions")),
              ],
              rows: _soilData.map<DataRow>((item) => _buildDataRow(item)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(dynamic item) {
    // FIX 1: Get ID correctly (Prisma uses 'id', not '_id')
    final String id = item['id']?.toString() ?? "";

    return DataRow(
      cells: [
        // FIX 2: Use correct keys matching your Prisma Schema
        DataCell(Text(item['soilName']?.toString() ?? "N/A")), // Changed from 'name'
        DataCell(Text(item['texture']?.toString() ?? "N/A")),
        DataCell(Text(item['soilPh']?.toString() ?? "N/A")),   // Changed from 'ph'
        DataCell(Text(item['drainage']?.toString() ?? "N/A")),

        // Actions Column
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF0D47A1)),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Pass the item to the form (keys will need mapping in Form too if reused)
                      builder: (_) => SoilFormScreen(soilData: item),
                    ),
                  );
                  if (result == true) _fetchSoils();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(id),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(String id) {
    if (id.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this soil record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSoil(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}