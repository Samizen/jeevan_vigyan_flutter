// add_category_form.dart

import 'package:flutter/material.dart';
import 'package:jeevan_vigyan/models/category.dart';
import 'package:jeevan_vigyan/services/database_service.dart';

class AddCategoryForm extends StatefulWidget {
  final String categoryType; // 'income' or 'expense'

  const AddCategoryForm({super.key, required this.categoryType});

  @override
  State<AddCategoryForm> createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<AddCategoryForm> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Helper method to get the Nepali name for the category type
  String _getNepaliCategoryType(String type) {
    return type == 'income' ? 'आय' : 'खर्च';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newCategory = Category(
        type:
            widget.categoryType, // Keep the English identifier for the database
        name: _nameController.text,
      );

      final newCategoryId = await _dbService.insertCategory(newCategory);

      // Return the new category's ID to the previous screen
      Navigator.of(context).pop(newCategoryId);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'नयाँ श्रेणी थप्नुहोस्',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall!.copyWith(color: Colors.red[800]),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              // CHANGE: Use the helper method to translate the type for display
              'श्रेणी प्रकार: ${_getNepaliCategoryType(widget.categoryType)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'श्रेणीको नाम',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'नाम आवश्यक छ।';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('रद्द गर्नुहोस्'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ठीक छ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
