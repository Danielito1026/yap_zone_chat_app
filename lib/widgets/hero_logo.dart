import 'package:flutter/material.dart';

class HeroLogo extends StatelessWidget {
  const HeroLogo({super.key, this.showTitle = true});
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'hero1',
      child: ClipRRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Image.asset(
              'assets/images/yz-logo.png',
              height: 70,
              width: 70, 
              fit: BoxFit.cover, 
              alignment: Alignment.bottomCenter, 
            ),
            if (showTitle) 
              Text(
                'Yap Zone',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}