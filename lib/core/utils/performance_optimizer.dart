import 'package:flutter/material.dart';

class PerformanceOptimizer {
  static double calculateItemExtent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 120.0;
    } else if (screenWidth < 1024) {
      return 140.0;
    } else {
      return 160.0;
    }
  }

  static double calculateCacheExtent(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.5;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 1;
    } else if (screenWidth < 900) {
      return 2;
    } else if (screenWidth < 1200) {
      return 3;
    } else {
      return 4;
    }
  }

  static double getGridChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 1.5;
    } else if (screenWidth < 1024) {
      return 1.2;
    } else {
      return 1.0;
    }
  }

  static void debounce(
      Function() action, {
        Duration delay = const Duration(milliseconds: 500),
      }) {
    Future.delayed(delay, action);
  }

  static bool _isThrottling = false;

  static void throttle(
      Function() action, {
        Duration interval = const Duration(milliseconds: 200),
      }) {
    if (_isThrottling) return;

    action();
    _isThrottling = true;

    Future.delayed(interval, () {
      _isThrottling = false;
    });
  }

  static int getImageCacheSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 50;
    } else if (screenWidth < 1024) {
      return 100;
    } else {
      return 200;
    }
  }

  static int getImageQuality(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 70;
    } else if (screenWidth < 1024) {
      return 85;
    } else {
      return 95;
    }
  }

  static bool shouldUseRepaintBoundary(int itemCount) {
    return itemCount > 20;
  }

  static bool shouldUseKeepAlive(int itemCount) {
    return itemCount < 50;
  }

  static ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}