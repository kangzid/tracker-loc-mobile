import 'package:flutter/material.dart';

class EmployeeBannerSlider extends StatefulWidget {
  const EmployeeBannerSlider({super.key});

  @override
  State<EmployeeBannerSlider> createState() => _EmployeeBannerSliderState();
}

class _EmployeeBannerSliderState extends State<EmployeeBannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 157.43,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return OverflowBox(
                maxWidth: constraints.maxWidth + 32,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 3,
                  padEnds: false,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                        }

                        final isFirst = index == 0;
                        final isLast = index == 2;

                        return Padding(
                          padding: EdgeInsets.only(
                            left: isFirst ? 16 : 8,
                            right: isLast ? 16 : 8,
                          ),
                          child: Transform.scale(
                            scale: Curves.easeOut.transform(value),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/benner-home.png',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF4B3B47)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
