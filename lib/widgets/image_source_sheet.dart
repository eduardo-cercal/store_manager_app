import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {
  final Function(File) onImageSelected;

  const ImageSourceSheet({required this.onImageSelected,Key? key}) : super(key: key);

  void imageSelected(XFile? image) async {
    if (image != null) {
      File? croppedImage =
          await ImageCropper().cropImage(sourcePath: image.path);
      onImageSelected(croppedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();
    return BottomSheet(
      onClosing: () {},
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
              onPressed: () async {
                XFile? image =
                    await picker.pickImage(source: ImageSource.camera);
                imageSelected(image);
              },
              child: const Text("Câmera")),
          TextButton(
              onPressed: () async {
                XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                imageSelected(image);
              },
              child: const Text("Galeria")),
        ],
      ),
    );
  }
}
