import 'package:flutter/material.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const HomeAppbar({super.key, required this.title});

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
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            height: 30,
            width: 50,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset('assets/logo/git_logo.png', fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}
