import 'package:flutter/material.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0043A4),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {},
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.star, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
