import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_service_manager/widgets/buttons/dismiss_button.dart';
import '../utils/utils.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final infoFont = GoogleFonts.inter(color: Colors.black54);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/branding.png', width: 120, height: 120),
                Column(
                  children: [
                    Text(
                      'Mobile Service Manager',
                      style: infoFont.copyWith(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text('Version 1.0.0 (1)', style: infoFont)),
                    Text(
                        'Copyright © 2025 com.soeminthein. \n All rights reserved.',
                        textAlign: TextAlign.center,
                        style: infoFont),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                      child: Text('You can reach me on:',
                          style: infoFont.copyWith(color: Colors.black)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => openUrl(
                              'https://www.facebook.com/soemin.thein.16696'),
                          child: Image.asset('assets/facebook.png',
                              width: 48, height: 48),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => openUrl(
                              'https://www.linkedin.com/in/soemin-thein/'),
                          child: Image.asset('assets/linkedin.png',
                              width: 48, height: 48),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15)
                  ],
                )
              ],
            ),
          ),
          const DismissButton(spacing: 10),
        ],
      ),
    );
  }
}
