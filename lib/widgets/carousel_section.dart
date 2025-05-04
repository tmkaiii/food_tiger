// 使用 flutter_carousel_widget 实现轮播图
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CarouselSection extends StatefulWidget {
  const CarouselSection({Key? key}) : super(key: key);

  @override
  State<CarouselSection> createState() => _CarouselSectionState();
}

class _CarouselSectionState extends State<CarouselSection> {
  int _currentCarouselIndex = 0;

  final List<Map<String, String>> carouselItems = [
    {
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
      'title': 'Food Festival',
    },
    {
      'image': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1',
      'title': 'Local Specialties',
    },
    {
      'image': 'https://images.unsplash.com/photo-1578474846511-04ba529f0b88',
      'title': 'Limited Offers',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FlutterCarousel(
          items:
              carouselItems.map((item) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: Colors.grey),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: item['image']!,
                        memCacheWidth: 100,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) => const Icon(Icons.error),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Text(
                          item['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          options: CarouselOptions(
            height: 200.0,
            showIndicator: true,
            slideIndicator: CircularSlideIndicator(
              // indicatorRadius: 4,
              // itemSpacing: 8,
              // currentIndicatorColor: const Color(0xFF008080),
              // indicatorBackgroundColor: Colors.grey,
            ),
            autoPlay: true,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
        ),
      ],
    );
  }
}
