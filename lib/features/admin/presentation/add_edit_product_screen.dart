import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/features/admin/application/product_provider.dart';
import 'package:zello/features/admin/application/category_provider.dart';
import 'package:zello/features/admin/domain/product.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _imgUrlCtrl;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _brandCtrl = TextEditingController(text: widget.product?.brandName ?? '');
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockCtrl = TextEditingController(text: widget.product?.stock.toString() ?? '0');
    _imgUrlCtrl = TextEditingController(text: widget.product?.images.isNotEmpty == true ? widget.product!.images.first : 'https://via.placeholder.com/150');
    _selectedCategoryId = widget.product?.categoryId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _imgUrlCtrl.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
        return;
      }

      final newProduct = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameCtrl.text.trim(),
        brandName: _brandCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        stock: int.parse(_stockCtrl.text.trim()),
        categoryId: _selectedCategoryId!,
        images: [_imgUrlCtrl.text.trim()],
        isActive: widget.product?.isActive ?? true,
        avgRating: widget.product?.avgRating ?? 0.0,
      );

      if (widget.product != null) {
        ref.read(productProvider.notifier).updateProduct(newProduct);
      } else {
        ref.read(productProvider.notifier).addProduct(newProduct);
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandCtrl,
                decoration: const InputDecoration(labelText: 'Brand Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? '❌ Please enter the brand name.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: 'Price (\$)', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || int.tryParse(val) == null ? 'Invalid' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (categories) {
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    value: _selectedCategoryId,
                    items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => const Text('Failed to load categories'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imgUrlCtrl,
                decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  child: Text(widget.product != null ? 'Save Changes' : 'Create Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
