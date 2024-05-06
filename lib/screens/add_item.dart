import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping/data/categories.dart';
import 'package:shopping/models/category.dart';
import 'package:shopping/models/grocery_item.dart';
import 'package:shopping/services/shopping_list.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _form = GlobalKey<FormState>();

  final api = FirebaseService();

  String _title = '';
  String _quantity = '1';
  Category _category = categories[Categories.vegetables]!;
  bool _isSaving = false;
  String? _error;

  void _saveItem() async {
    var isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();

      try {
        setState(() {
          _isSaving = true;
        });

        final result =
            await api.addItem(_title, _category.title, int.parse(_quantity));

        print(result.body);
        print(result.statusCode);

        setState(() {
          _isSaving = false;
        });

        if (result.statusCode >= 400) {
          print(result.statusCode);
          _error = "Something went wrong. Please try again.";
        }

        var response = jsonDecode(result.body);

        var groceryItem = GroceryItem(
            id: response['name'],
            name: _title,
            quantity: int.parse(_quantity),
            category: _category);

        if (!context.mounted) {
          return;
        }

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(groceryItem);
      } catch (err) {
        print(err);
        _error = "Something went wrong. Please try again.";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Add an item',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Title')),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length < 2 ||
                      value.trim().length > 50) {
                    return 'You must enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _quantity,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      validator: (value) {
                        var intValue = int.tryParse(value!);
                        if (intValue == null || intValue <= 0) {
                          return 'You must set a quantity';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _quantity = value!;
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _category,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        _category = value!;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(),
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            _form.currentState!.reset();
                          },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            _saveItem();
                          },
                    child: _isSaving
                        ? const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : const Text('Submit'),
                  ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!),
                )
            ],
          ),
        ),
      ),
    );
  }
}
