part of 'custom_nav_bar.dart';

mixin BottomNavBarAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController positionController;
  late Animation<double> positionAnimation;
  late final BottomNavBarController selectorController =
      BottomNavBarController();

  List<GlobalKey> itemKeys = [];
  double boxHeight = 0;

  @override
  void initState() {
    positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    positionAnimation = CurvedAnimation(
      parent: positionController,
      curve: Curves.easeOut,
    );
    super.initState();
  }

  @override
  void dispose() {
    positionController.dispose();
    super.dispose();
  }

  void initKeys(int count) {
    itemKeys = List.generate(count, (_) => GlobalKey());
  }

  void onTapDown(BuildContext context, Offset globalPosition) {
    selectorController.setDragging(true);

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(globalPosition);
    final double parentWidth = box.size.width;
    final boxWidth = selectorController.boxWidth.value;

    double newX = localOffset.dx - boxWidth / 2;
    newX = newX.clamp(0.0, parentWidth - boxWidth);

    selectorController.setPosition(newX, boxWidth);
  }

  void onPanEnd(BuildContext context, void Function(int index)? onTap) {
    selectorController.setDragging(false);
    animateToNearestIndex(context, onTap);
  }

  void animateToNearestIndex(
    BuildContext context,
    void Function(int index)? onTap,
  ) {
    final RenderBox parentBox = context.findRenderObject() as RenderBox;
    int nearestIndex = 0;
    double minDist = double.infinity;
    double selectorCenter =
        selectorController.posX.value + selectorController.boxWidth.value / 2;

    for (int i = 0; i < itemKeys.length; i++) {
      final ctx = itemKeys[i].currentContext;
      if (ctx == null) continue;

      final RenderBox itemBox = ctx.findRenderObject() as RenderBox;
      final Offset itemGlobal = itemBox.localToGlobal(Offset.zero);
      final Offset itemLocal = parentBox.globalToLocal(itemGlobal);

      final double itemLeft = itemLocal.dx;
      final double itemWidth = itemBox.size.width;
      final double itemCenter = itemLeft + itemWidth / 2;

      final dist = (selectorCenter - itemCenter).abs();
      if (dist < minDist) {
        minDist = dist;
        nearestIndex = i;
      }
    }
    animateToIndex(
      context,
      nearestIndex,
      onTap: () {
        onTap?.call(nearestIndex);
      },
    );
  }

  void animateToIndex(
    BuildContext context,
    int index, {
    double padding = 0,
    VoidCallback? onTap,
  }) {
    final RenderBox parentBox = context.findRenderObject() as RenderBox;
    final ctx = itemKeys[index].currentContext;
    if (ctx == null) return;

    final RenderBox itemBox = ctx.findRenderObject() as RenderBox;
    final Offset itemGlobal = itemBox.localToGlobal(Offset.zero);
    final Offset itemLocal = parentBox.globalToLocal(itemGlobal);

    final double targetX = itemLocal.dx - padding;
    final double targetWidth = itemBox.size.width;

    animateToPosition(targetX, targetWidth, index, onTap: onTap);
  }

  void animateToPosition(
    double targetX,
    double targetWidth,
    int index, {
    VoidCallback? onTap,
  }) {
    final positionTween = Tween<double>(
      begin: selectorController.posX.value,
      end: targetX,
    );
    final widthTween = Tween<double>(
      begin: selectorController.boxWidth.value,
      end: targetWidth,
    );

    selectorController.setDragging(true);

    positionController.reset();
    positionAnimation.addListener(() {
      if (mounted) {
        final posX = positionTween.evaluate(positionAnimation);
        final boxWidth = widthTween.evaluate(positionAnimation);
        selectorController.setPosition(posX, boxWidth);
      }
    });

    positionController.forward().then((_) {
      if (mounted) {
        selectorController.setDragging(false);
        onTap?.call();
      }
    });
  }
}
