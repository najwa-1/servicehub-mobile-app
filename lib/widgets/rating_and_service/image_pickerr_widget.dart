import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final Uint8List? imageBytes;
  final Function() onTap;
  static const double containerSize = 150.0;
  static const double borderRadiusValue = 15.0;
  static const double borderWidth = 2.0;

  ImagePickerWidget({required this.imageBytes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(borderRadiusValue),
          border: Border.all(color: Colors.teal, width: borderWidth),
        ),
        child: imageBytes == null
            ? Center(child: Icon(Icons.add_a_photo, color: Colors.teal))
            : ClipRRect(
                borderRadius: BorderRadius.circular(borderRadiusValue),
                child: Image.memory(imageBytes!, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
