import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:watchers/core/theme/sizes.dart';

class SeriesCard extends StatelessWidget {
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap; // Função que deve ser chamada quando a série for selecionada

  const SeriesCard({super.key, required this.imageUrl, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover,),

            if (isSelected)
              Container(
                color: Colors.black.withAlpha(128),
              ),

            if(isSelected)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(200),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18.0,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}