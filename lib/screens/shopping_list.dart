import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping/data/categories.dart';
import 'package:shopping/models/grocery_item.dart';
import 'package:shopping/screens/add_Item.dart';
import 'package:shopping/services/shopping_list.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  List<GroceryItem> _groceryItems = [];
  final _api = FirebaseService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  Future<void> _loadItems() async {
    try {
      final response = await _api.getItems();

      print(response.body);
      print(response.statusCode);

      setState(() {
        _isLoading = false;
      });

      // no items stored on backend
      if (response.body == 'null') {
        return;
      }

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Api called failed. Please try again later.';
        });
      }

      var data = jsonDecode(response.body) as Map<String, dynamic>;

      List<GroceryItem> loadedItems = [];
      for (var item in data.entries) {
        var category = categories.entries
            .firstWhere(
                (element) => element.value.title == item.value['category'])
            .value;

        loadedItems.add(
          GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: category),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
      });
    } catch (exc) {
      print(exc);
      setState(() {
        _isLoading = false;
        _error = 'Something went wrong. Please try again later.';
      });
    }
  }

  void _addItem(BuildContext context) async {
    var item = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const AddItemScreen(),
      ),
    );
    if (item != null) {
      setState(() {
        _groceryItems.add(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _groceryItems.isEmpty
        ? const Center(
            child: Text("No items added yet."),
          )
        : ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder: (buildContext, i) {
              var item = _groceryItems[i];

              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background:
                    Container(color: Theme.of(context).colorScheme.error),
                onDismissed: (direction) => {
                  setState(() {
                    _groceryItems.remove(item);
                  })
                },
                child: ListTile(
                  leading: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(color: item.category!.color),
                  ),
                  title: Text(item.name),
                  trailing: Text('${item.quantity}'),
                ),
              );
            });

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Your Groceries',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _addItem(context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: content,
    );
  }
}
