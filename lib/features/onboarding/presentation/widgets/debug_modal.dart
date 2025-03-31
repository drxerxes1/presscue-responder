import 'package:flutter/material.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'package:presscue_patroller/core/database/boxes.dart';
import 'package:presscue_patroller/core/services/base_url_provider.dart';

class DebugModal extends StatefulWidget {
  const DebugModal({super.key});

  @override
  _DebugModalState createState() => _DebugModalState();
}

class _DebugModalState extends State<DebugModal> {
  final TextEditingController _debugController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _debugController.text = BaseUrlProvider.baseUrl;
  }

  @override
  void dispose() {
    _debugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: const Text(
        'Debug Mode',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _debugController,
            decoration: InputDecoration(
              labelText: 'Enter Base URL',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  baseUrlBox.delete(1);
                  final newUrl = _debugController.text.trim();
                  if (newUrl.isNotEmpty) {
                    await BaseUrlProvider.updateBaseUrl(newUrl);
                    print("Updated Base URL: ${BaseUrlProvider.baseUrl}");
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
