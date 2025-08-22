import 'package:flutter/material.dart';
import '../models/new_city_model.dart';

class SearchResultList extends StatelessWidget {
  final List<NewCity> cities;
  final Function(NewCity) onSelect;

  const SearchResultList({
    super.key,
    required this.cities,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) return const SizedBox();

    return Column(
      children: cities.map((city) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.location_city),
            title: Text("${city.name}, ${city.country}"),
            subtitle: Text("${city.condition}   ${city.temp}°C"),
            onTap: () => onSelect(city),
          ),
        );
      }).toList(),
    );
  }
}
