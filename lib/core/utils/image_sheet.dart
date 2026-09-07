import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_style.dart';
import '../constants/app_colors.dart';
import 'utils.dart';

class ImageSourceSheet extends StatelessWidget {
  const ImageSourceSheet({super.key});

  static Future<XFile?> showSheet() async {
    return await Get.bottomSheet(const ImageSourceSheet());
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      enableDrag: false,
      onClosing: () {},
      backgroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(defaultRadius * 2),
          topLeft: Radius.circular(defaultRadius * 2),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogHeader(context, title: 'Select Option'),
              _buildListTile(
                icon: Icons.image_rounded,
                title: 'Gallery',
                onTap: () async {
                  XFile? file = await Utils.pickImage(ImageSource.gallery);
                  Get.back(result: file);
                },
              ),
              _buildListTile(
                icon: Icons.camera_alt_rounded,
                title: 'Camera',
                onTap: () async {
                  XFile? file = await Utils.pickImage(ImageSource.camera);
                  Get.back(result: file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24, color: AppColors.primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _dialogHeader(BuildContext context, {required String title}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(title),
          trailing: InkWell(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.close,
              color: AppColors.primaryColor,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Divider(height: 0, color: AppColors.borderColor),
        const SizedBox(height: 2),
      ],
    );
  }
}
