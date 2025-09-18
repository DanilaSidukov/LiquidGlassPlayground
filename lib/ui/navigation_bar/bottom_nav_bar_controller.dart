part of 'custom_nav_bar.dart';

class BottomNavBarController {
  final ValueNotifier<double> posX = ValueNotifier(0);
  final ValueNotifier<double> boxWidth = ValueNotifier(0);
  final ValueNotifier<bool> isDragging = ValueNotifier(false);

  VoidCallback? _onTapIndex;
  void attachOnTap(VoidCallback callback) {
    _onTapIndex = callback;
  }

  void setDragging(bool dragging) {
    isDragging.value = dragging;
  }

  void setPosition(double x, double width) {
    posX.value = x;
    boxWidth.value = width;
  }

  void triggerTap(int index) {
    _onTapIndex?.call();
  }

  void dispose() {
    posX.dispose();
    boxWidth.dispose();
    isDragging.dispose();
  }
}
