import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/dashboard_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Soil Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Date & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(now),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('hh:mm a').format(now),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Soil Condition
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Soil Condition: SOLID ✅",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            /// Matrix Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: const [
                  DashboardTile(
                    title: "Temperature",
                    value: "12.5 °C",
                    color: Colors.green,
                    icon: Icons.thermostat,
                  ),
                  DashboardTile(
                    title: "Humidity",
                    value: "42 %",
                    color: Colors.blue,
                    icon: Icons.water_drop,
                  ),
                  DashboardTile(
                    title: "Water Level",
                    value: "Normal",
                    color: Colors.cyan,
                    icon: Icons.opacity,
                  ),
                  DashboardTile(
                    title: "Soil pH",
                    value: "7.9",
                    color: Colors.orange,
                    icon: Icons.science,
                  ),
                  DashboardTile(
                    title: "Nitrogen (N)",
                    value: "68 mg/kg",
                    color: Colors.pink,
                    icon: Icons.eco,
                  ),
                  DashboardTile(
                    title: "Phosphorus (P)",
                    value: "96 mg/kg",
                    color: Colors.blueAccent,
                    icon: Icons.grass,
                  ),
                  DashboardTile(
                    title: "Potassium (K)",
                    value: "220 mg/kg",
                    color: Colors.teal,
                    icon: Icons.local_florist,
                  ),
                  DashboardTile(
                    title: "Fertility",
                    value: "757 mg/kg",
                    color: Colors.deepOrange,
                    icon: Icons.agriculture,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Suggestions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "🌱 Suggestions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text("• Irrigation: Normal"),
                  Text("• Fertilizer: Required"),
                  Text("• Crop Health: Good"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
