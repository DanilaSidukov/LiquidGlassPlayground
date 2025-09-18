import 'dart:ui';

import 'package:flutter/material.dart';

import 'bottom_navigation_bar_item.dart';

class BottomNavBar extends StatefulWidget {
  final List<BottomNavBarItem> children;
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavBar({
    super.key,
    required this.children,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  double posX = 0;
  late final List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _initKeys();
  }

  void _initKeys() {
    _itemKeys = List.generate(widget.children.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _initKeys();
    }
  }

  void onTapDown(BuildContext context, Offset globalPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(globalPosition);

    final double parentWidth = box.size.width;
    double newX = localOffset.dx - _boxWidth / 2;
    newX = newX.clamp(0.0, parentWidth - _boxWidth);

    setState(() {
      posX = newX;
    });
  }

  void onPanEnd(BuildContext context) {
    final RenderBox parentBox = context.findRenderObject() as RenderBox;
    final double parentWidth = parentBox.size.width;

    // Собираем центры айтемов в локальных координатах parentBox
    final List<double> centers = <double>[];
    for (var key in _itemKeys) {
      final ctx = key.currentContext;
      if (ctx == null) {
        centers.add(double.nan); // пометим, если нет контекста
        continue;
      }
      final RenderBox itemBox = ctx.findRenderObject() as RenderBox;
      final Offset itemGlobalCenter = itemBox.localToGlobal(
        itemBox.size.center(Offset.zero),
      );
      final Offset itemLocalCenter = parentBox.globalToLocal(itemGlobalCenter);
      centers.add(itemLocalCenter.dx);
    }

    // Если центры не удалось вычислить (например, ключи ещё не привязаны),
    // fallback: равномерное распределение
    if (centers.any((c) => c.isNaN)) {
      final itemWidthFallback = parentWidth / widget.children.length;
      for (int i = 0; i < widget.children.length; i++) {
        centers[i] = itemWidthFallback * i + itemWidthFallback / 2;
      }
    }

    final double selectorCenter = posX + _boxWidth / 2;

    // Находим ближайший индекс
    int nearestIndex = 0;
    double minDist = double.infinity;
    for (int i = 0; i < centers.length; i++) {
      final d = (selectorCenter - centers[i]).abs();
      if (d < minDist) {
        minDist = d;
        nearestIndex = i;
      }
    }

    // Целевая позиция: центр айтема минус половина ширины селектора
    double targetX = centers[nearestIndex] - _boxWidth / 2;
    targetX = targetX.clamp(0.0, parentWidth - _boxWidth);

    setState(() {
      posX = targetX;
    });

    // Уведомляем родителя (чтобы он обновил currentIndex)
    widget.onTap?.call(nearestIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.all(_containerPadding),
      height: _bottomBarHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => onTapDown(context, details.globalPosition),
        onPanUpdate: (details) => onTapDown(context, details.globalPosition),
        onPanEnd: (_) => onPanEnd(context),
        onTapUp: (_) => onPanEnd(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Stack(
                children: [
                  Padding(
                    //padding: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.all(0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        widget.children.length,
                        (index) => NavBarItem(
                          key: _itemKeys[index],
                          index: index,
                          item: widget.children[index],
                          selected: widget.currentIndex == index,
                          onTap: () => {}, //,widget.onTap?.call(index),
                        ),
                      ),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: posX, end: posX),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(value, 0),
                        child: child,
                      );
                    },
                    child: Container(
                      width: _boxWidth,
                      height: _bottomBarHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const double _bottomBarHeight = 74;
const double _boxWidth = 80;
const double _selectorPadding = 4.0;
const double _containerPadding = 12.0;

class NavBarItem extends StatelessWidget {
  final BottomNavBarItem item;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const NavBarItem({
    super.key,
    required this.item,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      //padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
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
