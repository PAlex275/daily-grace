import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeCarousel extends StatelessWidget {
  const HomeCarousel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final items = [2, 1, 1, 1];
    return CarouselSlider(
      items: items.map((e) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.70,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          },
        );
      }).toList(),
      options: CarouselOptions(
        viewportFraction: 0.75,
        aspectRatio: 20 / 10,
        enableInfiniteScroll: false,
      ),
    );
  }
}
