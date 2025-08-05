import 'package:flutter/material.dart';
import 'package:zeta_ess/core/theme/app_theme.dart';

class DotsRowCard extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {"title": "Holiday", "color": Color(0xFFA0EC8A)},
    {"title": "Full Day", "color": AppTheme.primaryColor},
    {"title": "Half Day", "color": Colors.blue.shade200},
  ];

  DotsRowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ), // Adjusted padding for smaller UI
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) => _DotItem(item: item)).toList(),
        ),
      ),
    );
  }
}

class _DotItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _DotItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      // Changed from Column to Row for horizontal alignment
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, // Smaller dot size
          height: 10, // Smaller dot size
          decoration: BoxDecoration(
            color: item['color'] as Color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item['title'].toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
