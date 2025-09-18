library;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'bottom_nav_bar_item.dart';

part 'bottom_nav_bar_animation_mixin.dart';
part 'bottom_nav_bar_controller.dart';

class CustomBottomNavBar extends StatefulWidget {
  final List<BottomNavBarItem> children;
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavBar({
    super.key,
    required this.children,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin, BottomNavBarAnimationMixin {
  @override
  void initState() {
    super.initState();
    initKeys(widget.children.length);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (itemKeys.isNotEmpty && itemKeys[0].currentContext != null) {
        final RenderBox itemBox =
            itemKeys[0].currentContext!.findRenderObject() as RenderBox;
        setState(() {
          boxHeight = itemBox.size.height;
        });
        selectorController.setPosition(_bottomBarsPadding, itemBox.size.width);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      initKeys(widget.children.length);
    }
  }

  void _onItemTap(int index) {
    animateToIndex(
      context,
      index,
      padding: _containerPadding * 1.05,
      onTap: () {
        widget.onTap?.call(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _bottomBarHeight,
      margin: const EdgeInsets.all(_containerPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: ValueListenableBuilder(
        valueListenable: selectorController.isDragging,
        builder: (context, isDragging, child) {
          return Listener(
            onPointerDown: (_) {
              if (!isDragging) {
                selectorController.setDragging(true);
              }
            },
            onPointerUp: (_) {
              if (mounted && isDragging) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    selectorController.setDragging(false);
                  }
                });
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  onTapDown(context, details.globalPosition),
              onPanUpdate: (details) =>
                  onTapDown(context, details.globalPosition),
              onPanEnd: (_) => onPanEnd(context, (index) {
                widget.onTap?.call(index);
              }),
              onTapUp: (_) => onPanEnd(context, (index) {
                widget.onTap?.call(index);
              }),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.centerLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(_bottomBarsPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        widget.children.length,
                        (index) => GestureDetector(
                          onTap: () => _onItemTap(index),
                          child: Container(
                            key: itemKeys[index],
                            child: _NavBarItem(
                              index: index,
                              item: widget.children[index],
                              selected: widget.currentIndex == index,
                              onTap: () => _onItemTap(index),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListenableBuilder(
                    listenable: Listenable.merge([
                      selectorController.posX,
                      selectorController.boxWidth,
                    ]),
                    builder: (context, _) {
                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        left: selectorController.posX.value,
                        top: _bottomBarsPadding,
                        width: selectorController.boxWidth.value,
                        height: boxHeight,
                        child: _SelectorWidget(isDragging: isDragging),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final BottomNavBarItem item;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: selected ? Colors.white : Colors.white70),
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorWidget extends StatelessWidget {
  final bool isDragging;

  const _SelectorWidget({required this.isDragging, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isDragging ? 1.4 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: isDragging ? 0 : 20,
          end: isDragging ? 20 : 0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        builder: (context, thickness, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDragging ? 0.1 : 0.2),
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: LiquidGlass(
              shape: LiquidRoundedSuperellipse(
                borderRadius: Radius.circular(24),
              ),
              settings: LiquidGlassSettings(
                thickness: thickness,
                glassColor: Colors.white.withValues(alpha: 0.2),
              ),
              child: const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

const double _bottomBarHeight = 64;
const double _bottomBarsPadding = 8.0;
const double _containerPadding = 12.0;
const double _borderRadius = 24.0;
