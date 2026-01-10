import 'package:flutter/material.dart';
import 'soil_form_screen.dart';

class SoilManagementScreen extends StatelessWidget {
  const SoilManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Soil Management")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SoilFormScreen()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DataTable(
            headingRowColor:
            MaterialStateProperty.all(const Color(0xFFECEFF1)),
            columns: const [
              DataColumn(label: Text("ID")),
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Texture")),
              DataColumn(label: Text("pH")),
              DataColumn(label: Text("Drainage")),
              DataColumn(label: Text("Action")),
            ],
            rows: [
              _row(context, "10", "Black Soil", "Clay", "Alkaline", "Low"),
              _row(context, "11", "Cinder Soil", "Silt", "Neutral", "Medium"),
              _row(context, "12", "Laterite", "Sand", "Acidic", "High"),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _row(BuildContext context, String id, String name, String texture,
      String ph, String drainage) {
    return DataRow(
      cells: [
        DataCell(Text(id)),
        DataCell(Text(name)),
        DataCell(Text(texture)),
        DataCell(Text(ph)),
        DataCell(Text(drainage)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF0D47A1)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SoilFormScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}
