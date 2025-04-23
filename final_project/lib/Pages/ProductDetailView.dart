import 'package:flutter/material.dart';
import 'package:final_project/Components/ActionBar.dart';
import 'package:get/get.dart';
import 'package:final_project/Back/Product.dart';
import 'dart:io';
import 'package:final_project/Back/fullscreen.dart';

class ProductDetailView extends StatefulWidget {
  final Product product;

  const ProductDetailView({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailViewState createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  // check current image index
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text('Product Details'),
      ),
      body: ListView(
        children: [
          //add bar after;
          GestureDetector(
            onTap: () {
              // full screen view when click on the image
              if (widget.product.imageUrls.isNotEmpty) {
                Get.to(() => FullScreenImageViewer(
                  imageUrls: widget.product.imageUrls,
                  initialIndex: _currentImageIndex, // get current image index
                ));
              }
            },
            child: Stack(
              children: [
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    itemCount:
                    widget.product.imageUrls.isEmpty ? 1 : widget.product.imageUrls.length,
                    onPageChanged: (index) {
                      // 更新当前查看的图片索引
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return widget.product.imageUrls.isNotEmpty
                          ? Image.network(
                        widget.product.imageUrls[index],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Image loading error: $error');
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.error,
                                size: 50,
                                color: Colors.red,
                              ),
                            ),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image, size: 100, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                // add zoom in icon for reminding user to zoom in
                if (widget.product.imageUrls.isNotEmpty)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                // image counter
                if (widget.product.imageUrls.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${widget.product.imageUrls.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50, bottom: 20, left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "\$${widget.product.price.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 23, color: Colors.black),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Text(
              widget.product.description,
              style: TextStyle(fontSize: 17, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}