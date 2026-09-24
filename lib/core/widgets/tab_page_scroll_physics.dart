import 'package:flutter/widgets.dart';

/// Reports the direction of the in-progress user drag: `1.0` forward
/// (towards later pages), `-1.0` backward, `0.0` when not dragging.
typedef DragDirectionCallback = double Function();

/// Scroll physics for the status-tab pager.
///
/// Flutter's [PageScrollPhysics] decides whether to advance using a velocity
/// threshold of roughly `1 / (0.05 * devicePixelRatio)` logical pixels per
/// second (~7.6 px/s on a 420dpi device). That is small enough that a tiny
/// backwards release velocity — finger recoil, or noisy velocity tracking —
/// flips the result and makes an otherwise identical swipe snap back.
///
/// This physics makes the decision deterministic instead:
///
/// * a deliberate fling (`|velocity| > [flingVelocity]`) advances one page;
/// * otherwise a drag that has moved past [advanceFraction] of a page in the
///   direction the finger was travelling advances one page;
/// * anything else snaps back to the page it started on.
///
/// Small release velocities are ignored entirely, so the outcome depends on
/// the gesture the user actually performed rather than on how cleanly the
/// pointer was lifted.
class TabPageScrollPhysics extends ScrollPhysics {
  const TabPageScrollPhysics({this.dragDirection, super.parent});

  /// Supplies the direction of the current drag.
  final DragDirectionCallback? dragDirection;

  /// Fraction of a page a non-fling drag must cover to advance.
  static const double advanceFraction = 0.2;

  /// Release velocity, in logical pixels per second, above which a flick is
  /// always treated as a deliberate page change.
  static const double flingVelocity = 250.0;

  @override
  TabPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return TabPageScrollPhysics(
      dragDirection: dragDirection,
      parent: buildParent(ancestor),
    );
  }

  double _targetPage(ScrollMetrics position, double velocity) {
    final double page = position.pixels / position.viewportDimension;
    final double maxPage =
        (position.maxScrollExtent / position.viewportDimension).roundToDouble();
    final double direction = dragDirection?.call() ?? 0.0;

    final double lower = page.floorToDouble();
    final double upper = page.ceilToDouble();

    double target;
    if (velocity > flingVelocity) {
      target = lower + 1.0;
    } else if (velocity < -flingVelocity) {
      target = upper - 1.0;
    } else if (direction > 0.0) {
      target = page - lower >= advanceFraction ? lower + 1.0 : lower;
    } else if (direction < 0.0) {
      target = upper - page >= advanceFraction ? upper - 1.0 : upper;
    } else {
      target = page.roundToDouble();
    }
    return target.clamp(0.0, maxPage);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Let the platform physics handle the edges (overscroll / bounce).
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final double targetPixels =
        _targetPage(position, velocity) * position.viewportDimension;
    if ((targetPixels - position.pixels).abs() < 1e-9) {
      return null;
    }

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      targetPixels,
      velocity,
      tolerance: toleranceFor(position),
    );
  }

  @override
  bool get allowImplicitScrolling => false;

  @override
  SpringDescription get spring => SpringDescription.withDurationAndBounce(
        duration: const Duration(milliseconds: 300),
        bounce: 0.0,
      );
}
