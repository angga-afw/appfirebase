import 'package:appfirebase/firestore_services.dart';
import 'package:flutter/material.dart';

class FirestorePage extends StatefulWidget {
  const FirestorePage({super.key});

  @override
  State<FirestorePage> createState() => _FirestorePageState();
}

class _FirestorePageState extends State<FirestorePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Product Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                final priceText = _priceController.text.trim();

                if (name.isEmpty || priceText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
                  );
                  return;
                }

                final price = int.tryParse(priceText);
                if (price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Price must be a valid number'),
                    ),
                  );
                  return;
                }

                FirestoreServices.createOrUpdateProduct(name, price);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Product "$name" added successfully!')),
                );

                _nameController.clear();
                _priceController.clear();
              },
              child: const Text('Add Product'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Product List:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder(
                stream: FirestoreServices.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No products available.'),
                    );
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final productId = product.id;
                      final name = product['name'] ?? 'Unnamed';
                      final price = product['price'] ?? 0;

                      return ListTile(
                        title: Text(name),
                        subtitle: Text('Price: \$${price.toString()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showUpdateDialog(
                                  context,
                                  productId,
                                  name,
                                  price,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                FirestoreServices.deleteProduct(productId);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(
    BuildContext context,
    String productId,
    String currentName,
    int currentPrice,
  ) {
    final TextEditingController updateNameController =
        TextEditingController(text: currentName);
    final TextEditingController updatePriceController =
        TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: updateNameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: updatePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Product Price',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedName = updateNameController.text.trim();
                final updatedPriceText = updatePriceController.text.trim();

                if (updatedName.isEmpty || updatedPriceText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
                  );
                  return;
                }

                final updatedPrice = int.tryParse(updatedPriceText);
                if (updatedPrice == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Price must be a valid number'),
                    ),
                  );
                  return;
                }

                FirestoreServices.updateProduct(
                    productId, updatedName, updatedPrice);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
