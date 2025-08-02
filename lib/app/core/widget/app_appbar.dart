import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_style.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? refreshClick;

  const AppAppbar({
    super.key,
    this.refreshClick,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryColor,
      title: Text(
        'Car Route',
        style: text16Style(isWhiteColor: true),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: refreshClick,
          icon: Icon(
            Icons.refresh,
            color: AppColors.white,
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
