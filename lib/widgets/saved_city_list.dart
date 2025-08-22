import 'package:flutter/material.dart';
import '../models/NewCity_model.dart';

class SavedCityList extends StatelessWidget {
  final List<NewCity> cities;
  final Function(NewCity city, int index) onDelete;
  final Function(NewCity city) onSelect;

  const SavedCityList({
    super.key,
    required this.cities,
    required this.onDelete,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "Thành phố đã lưu",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...cities.asMap().entries.map((entry) {
          final index = entry.key;
          final city = entry.value;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.blue.shade400,
            child: ListTile(
              title: Text(
                city.name,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              subtitle: Text(
                city.condition,
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Text(
                "${city.temp}°C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => onSelect(city),
              onLongPress: () => onDelete(city, index),
            ),
          );
        }),
      ],
    );
  }
}
