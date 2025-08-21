import 'package:flutter/material.dart';
import '../models/NewCity_model.dart';
import '../services/NewCity_service.dart';

class NewCityScreen extends StatefulWidget {
  const NewCityScreen({super.key});

  @override
  State<NewCityScreen> createState() => _NewCityScreenState();
}

class _NewCityScreenState extends State<NewCityScreen> {
  final TextEditingController _controller = TextEditingController();
  final CityService _cityService = CityService();

  List<NewCity> _cities = [];
  List<NewCity> _savedCities = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCities();
  }

  Future<void> _loadSavedCities() async {
    final saved = await _cityService.loadSavedCities();
    setState(() {
      _savedCities = saved;
    });
  }

  Future<void> _searchCities(String query) async {
    setState(() => _loading = true);
    final results = await _cityService.searchCities(query);
    setState(() {
      _cities = results;
      _loading = false;
    });
  }

  Widget _buildSavedCities() {
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
        ..._savedCities.asMap().entries.map((entry) {
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
              onTap: () {
                Navigator.pop(context, city.toJson());
              },
              //dialog xóa thành phố
              onLongPress: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text("Xóa ${city.name}?"),
                    content: const Text(
                      "Bạn có chắc muốn xóa thành phố này khỏi danh sách?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // đóng dialog
                        child: const Text("Hủy"),
                      ),
                      TextButton(
                        onPressed: () async {
                          // gọi service xóa
                          await _cityService.deleteCity(index, _savedCities);

                          // cập nhật UI
                          setState(() {});

                          // đóng dialog
                          Navigator.pop(context);

                          // thông báo snack bar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${city.name} đã bị xóa")),
                          );
                        },
                        child: const Text(
                          "Xóa",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý thành phố")),
      body: RefreshIndicator(
        onRefresh: _loadSavedCities,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Nhập tên thành phố",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                onChanged: (value) {
                  if (value.length > 1) _searchCities(value);
                },
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : Expanded(
                      child: ListView(
                        children: [
                          ..._cities.map((city) {
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.location_city),
                                title: Text("${city.name}, ${city.country}"),
                                subtitle: Text(
                                  "${city.condition}   ${city.temp}°C",
                                ),
                                onTap: () async {
                                  await _cityService.saveCity(city);
                                  Navigator.pop(context, city.toJson());
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          _buildSavedCities(),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
