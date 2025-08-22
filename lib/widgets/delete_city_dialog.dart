import 'package:flutter/material.dart';
import '../models/new_city_model.dart';

class DeleteCityDialog extends StatelessWidget {
  final NewCity city;
  final VoidCallback onConfirm;

  const DeleteCityDialog({
    super.key,
    required this.city,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text("Xóa ${city.name}?"),
      content: const Text("Bạn có chắc muốn xóa thành phố này khỏi danh sách?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text("Xóa", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
