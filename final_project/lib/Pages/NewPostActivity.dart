import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project/Back/Product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Back/firebase_service.dart' as firebase_service;
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class NewPostActivity extends StatefulWidget {
  const NewPostActivity({Key? key}) : super(key: key);

  @override
  State<NewPostActivity> createState() => _NewPostActivityState();
}

class _NewPostActivityState extends State<NewPostActivity> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<File> _selectedImage = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /*
  Future<List<String>> _saveImages() async {
    final List<String> imagePaths = [];
    final appDir = await getApplicationDocumentsDirectory();

    for (var i = 0; i < _selectedImage.length; i++) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i${path.extension(_selectedImage[i].path)}';
      final savedImage = await _selectedImage[i].copy('${appDir.path}/$fileName');
      imagePaths.add(savedImage.path);
    }

    return imagePaths;
  }
  */

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('please upload at least a image')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final firebaseService = firebase_service.FirebaseService();

        // get image url paths
        List<String> imagePaths =
            _selectedImage.map((file) => file.path).toList();

        // upload products
        String? productId = await firebaseService.uploadProduct(
          name: _titleController.text,
          price: double.parse(_priceController.text),
          description: _descriptionController.text,
          images: imagePaths,
        );

        setState(() {
          _isLoading = false;
        });

        if (productId != null) {
          // If successfully uploaded，Create a product and return
          DocumentSnapshot doc =
              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(productId)
                  .get();

          if (doc.exists) {
            Product newProduct = Product.fromFirestore(doc);

            // return new product created
            Navigator.pop(context, newProduct);
          } else {
            // return basic info if did not get all info
            List<String> imageUrls =
                _selectedImage.map((file) => file.path).toList();
            Product newProduct = Product(
              id: productId,
              name: _titleController.text,
              price: double.parse(_priceController.text),
              description: _descriptionController.text,
              imageUrls: imageUrls,
              userId: firebaseService.currentUser?.uid ?? '',
            );

            // return new product created
            Navigator.pop(context, newProduct);
          }
        } else {
          // upload failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product upload failed, please try again'),
            ),
          );
        }
      } catch (e) {
        print('Product upload error: $e');

        setState(() {
          _isLoading = false;
        });

        // show snackbar
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text('Adding New Product'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Name of the product',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please enter the name of the product';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 16),
                // Price Field
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price of the item',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please enter the price of the item';
                    }
                    if (double.tryParse(value) == null) {
                      return 'please enter valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description of the proudct',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please enter the description of the product';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Container(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_selectedImage.length < 4)
                        GestureDetector(
                          onTap: () {
                            showImagePickerOption(context);
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ..._selectedImage.asMap().entries.map((entry) {
                        final index = entry.key;
                        final image = entry.value;
                        return Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImage.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Post Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Post',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (builder) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImageFromGallery();
                    },
                    child: const SizedBox(
                      child: Column(
                        children: [
                          Icon(Icons.image, size: 50),
                          Text('Gallery'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImageFromCamera();
                    },
                    child: const SizedBox(
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt, size: 50),
                          Text('Camera'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    if (_selectedImage.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only maximum upload four pictures '),
        ),
      );
      return;
    }
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage.add(File(pickedFile.path));
      });
    }
  }

  Future _pickImageFromCamera() async {
    if (_selectedImage.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only maximum upload four pictures '),
        ),
      );
      return;
    }
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage.add(File(pickedFile.path));
      });
    }
  }
}
