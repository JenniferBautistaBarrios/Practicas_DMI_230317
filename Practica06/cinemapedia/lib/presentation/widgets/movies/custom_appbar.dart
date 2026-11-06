import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 32,
          semanticLabel: 'Logo Cinemapedia',
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CINEMAPEDIA',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Text('230389', style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}
