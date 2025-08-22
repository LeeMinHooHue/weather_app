import 'package:flutter/material.dart';
import 'package:weather_app/widgets/delete_city_dialog.dart';
import 'package:weather_app/widgets/saved_city_list.dart';
import 'package:weather_app/widgets/search_result_list.dart';
import '../models/new_city_model.dart';
import '../services/new_city_service.dart';

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
    setState(() => _savedCities = saved);
  }

  Future<void> _searchCities(String query) async {
    setState(() => _loading = true);
    final results = await _cityService.searchCities(query);
    setState(() {
      _cities = results;
      _loading = false;
    });
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
              _buildSearchField(),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : Expanded(
                      child: ListView(
                        children: [
                          //Form tìm kiếm
                          SearchResultList(
                            cities: _cities,
                            onSelect: (city) async {
                              await _cityService.saveCity(city);
                              Navigator.pop(context, city.toJson());
                            },
                          ),
                          const SizedBox(height: 20),
                          //hiển thị thành phố đã lưu
                          SavedCityList(
                            cities: _savedCities,
                            onSelect: (city) =>
                                Navigator.pop(context, city.toJson()),
                            onDelete: (city, index) {
                              //dialog thông báo xóa
                              showDialog(
                                context: context,
                                builder: (context) => DeleteCityDialog(
                                  city: city,
                                  onConfirm: () async {
                                    await _cityService.deleteCity(
                                      index,
                                      _savedCities,
                                    );
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("${city.name} đã bị xóa"),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: "Nhập tên thành phố",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(99)),
      ),
      onChanged: (value) {
        if (value.length > 1) _searchCities(value);
      },
    );
  }
}
