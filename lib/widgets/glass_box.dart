import 'package:flutter/material.dart';
import 'glass_container.dart';

class GlassBox extends StatelessWidget {
  const GlassBox({
    super.key,
    required this.title,
    this.icon = const Icon(Icons.cloud_download, color: Colors.white, size: 44),
  });

  final String title;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    const width = 350.0;
    const height = 230.0;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),

          // Centered glass container
          Center(
            child: GlassContainer(
              width: width,
              height: height,
              borderRadius: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
