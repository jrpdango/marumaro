import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru/widgets/tab_page_scroll_physics.dart';

const double _viewport = 400.0;
const double _dpr = 420 / 160; // emulator: 420dpi / 160

PageMetrics _metrics({required double page}) {
  return PageMetrics(
    viewportDimension: _viewport,
    minScrollExtent: 0.0,
    maxScrollExtent: _viewport * 4,
    pixels: page * _viewport,
    axisDirection: AxisDirection.right,
    devicePixelRatio: _dpr,
    viewportFraction: 1.0,
  );
}

/// The page the ballistic simulation settles on, or null if none is returned.
double? _targetPage(double page, double velocity, {double direction = 0.0}) {
  final physics = TabPageScrollPhysics(dragDirection: () => direction);
  final Simulation? simulation =
      physics.createBallisticSimulation(_metrics(page: page), velocity);
  if (simulation == null) return null;
  return simulation.x(10.0) / _viewport;
}

void main() {
  group('fling', () {
    test('a deliberate forward flick advances one page', () {
      expect(_targetPage(0.1, 500), 1.0);
      expect(_targetPage(0.6, 500), 1.0);
      expect(_targetPage(1.1, 500), 2.0);
    });

    test('a deliberate backward flick goes back one page', () {
      expect(_targetPage(0.9, -500), 0.0);
      expect(_targetPage(1.6, -500), 1.0);
    });
  });

  group('slow drag', () {
    test('forward drag past the threshold advances', () {
      expect(_targetPage(0.25, 0, direction: 1), 1.0);
      expect(_targetPage(0.8, 0, direction: 1), 1.0);
    });

    test('forward drag under the threshold snaps back', () {
      expect(_targetPage(0.1, 0, direction: 1), 0.0);
      expect(_targetPage(1.1, 0, direction: 1), 1.0);
    });

    test('backward drag past the threshold goes back', () {
      expect(_targetPage(0.75, 0, direction: -1), 0.0);
      expect(_targetPage(1.75, 0, direction: -1), 1.0);
    });

    test('backward drag under the threshold snaps back', () {
      expect(_targetPage(0.9, 0, direction: -1), 1.0);
    });
  });

  group('release-velocity noise is ignored', () {
    test('a tiny forward velocity no longer advances a short drag', () {
      expect(_targetPage(0.2, 8), 0.0);
    });

    test('a tiny backward velocity no longer snaps back a long drag', () {
      expect(_targetPage(0.8, -8), 1.0);
    });
  });

  test('edges defer to the parent physics', () {
    expect(_targetPage(0.0, -500), isNull);
  });
}
