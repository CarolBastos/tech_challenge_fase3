import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkTeal,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.error),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: AppColors.error,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
