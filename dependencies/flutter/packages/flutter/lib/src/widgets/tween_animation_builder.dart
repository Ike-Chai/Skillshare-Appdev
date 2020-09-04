// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import 'package:flutter/animation.dart';

import 'framework.dart';
import 'implicit_animations.dart';
import 'value_listenable_builder.dart';

/// [Widget] builder that animates a property of a [Widget] to a target value
/// whenever the target value changes.
///
/// The type of the animated property ([Color], [Rect], [double], etc.) is
/// defined via the type of the provided [tween] (e.g. [ColorTween],
/// [RectTween], [Tween<double>], etc.).
///
/// The [tween] also defines the target value for the animation: When the widget
/// first builds, it animates from [Tween.begin] to [Tween.end]. A new animation
/// can be triggered anytime by providing a new [tween] with a new [Tween.end]
/// value. The new animation runs from the current animation value (which may be
/// [Tween.end] of the old [tween], if that animation completed) to [Tween.end]
/// of the new [tween].
///
/// The animation is further customized by providing a [curve] and [duration].
///
/// The current value of the animation along with the [child] is passed to
/// the [builder] callback, which is expected to build a [Widget] based on the
/// current animation value. The [builder] is called throughout the animation
/// for every animation value until [Tween.end] is reached.
///
/// A provided [onEnd] callback is called whenever an animation completes.
/// Registering an [onEnd] callback my be useful to trigger an action (like
/// another animation) at the end of the current animation.
///
/// ## Performance optimizations
///
/// If your [builder] function contains a subtree that does not depend on the
/// animation, it's more efficient to build that subtree once instead of
/// rebuilding it on every animation tick.
///
/// If you pass the pre-built subtree as the [child] parameter, the
/// AnimatedBuilder will pass it back to your builder function so that you
/// can incorporate it into your build.
///
/// Using this pre-built child is entirely optional, but can improve
/// performance significantly in some cases and is therefore a good practice.
///
/// ## Ownership of the [Tween]
///
/// The [TweenAnimationBuilder] takes full ownership of the provided [tween]
/// instance and it will mutate it. Once a [Tween] has been passed to a
/// [TweenAnimationBuilder], its properties should not be accessed or changed
/// anymore to avoid interference with the [TweenAnimationBuilder].
///
/// It is good practice to never store a [Tween] provided to a
/// [TweenAnimationBuilder] in an instance variable to avoid accidental
/// modifications of the [Tween].
///
/// ## Example Code
///
/// {@tool dartpad --template=stateful_widget_scaffold_center}
/// This example shows an [IconButton] that "zooms" in when the widget first
/// builds (its size smoothly increases from 0 to 24) and whenever the button
/// is pressed, it smoothly changes its size to the new target value of either
/// 48 or 24.
///
/// ```dart
/// double targetValue = 24.0;
///
/// @override
/// Widget build(BuildContext context) {
///   return TweenAnimationBuilder(
///     tween: Tween<double>(begin: 0, end: targetValue),
///     duration: Duration(seconds: 1),
///     builder: (BuildContext context, double size, Widget child) {
///       return IconButton(
///         iconSize: size,
///         color: Colors.blue,
///         icon: child,
///         onPressed: () {
///           setState(() {
///             targetValue = targetValue == 24.0 ? 48.0 : 24.0;
///           });
///         },
///       );
///     },
///     child: Icon(Icons.aspect_ratio),
///   );
/// }
/// ```
/// {@end-tool}
///
/// ## Relationship to [ImplicitlyAnimatedWidget]s and [AnimatedWidget]s
///
/// The [ImplicitlyAnimatedWidget] has many subclasses that provide animated
/// versions of regular widgets. These subclasses (like [AnimatedOpacity],
/// [AnimatedContainer], [AnimatedSize], etc.) animate changes in their
/// properties smoothly and they are easier to use than this general-purpose
/// builder. However, [TweenAnimationBuilder] (which itself is a subclass of
/// [ImplicitlyAnimatedWidget]) is handy for animating any widget property to a
/// given target value even when the framework (or third-party widget library)
/// doesn't ship with an animated version of that widget.
///
/// Those [ImplicitlyAnimatedWidget]s (including this [TweenAnimationBuilder])
/// all manage an internal [AnimationController] to drive the animation. If you
/// want more control over the animation than just setting a target value,
/// [duration], and [curve], have a look at (subclasses of) [AnimatedWidget]s.
/// For those, you have to manually manage an [AnimationController] giving you
/// full control over the animation. An example of an [AnimatedWidget] is the
/// [AnimatedBuilder], which can be used similarly to this
/// [TweenAnimationBuilder], but unlike the latter it is powered by a
/// developer-managed [AnimationController].
class TweenAnimationBuilder<T> extends ImplicitlyAnimatedWidget {
  /// Creates a [TweenAnimationBuilder].
  ///
  /// The properties [tween], [duration], and [builder] are required. The values
  /// for [tween], [curve], and [builder] must not be null.
  ///
  /// The [TweenAnimationBuilder] takes full ownership of the provided [tween]
  /// instance and mutates it. Once a [Tween] has been passed to a
  /// [TweenAnimationBuilder], its properties should not be accessed or changed
  /// anymore to avoid interference with the [TweenAnimationBuilder].
  const TweenAnimationBuilder({
    Key key,
    @required this.tween,
    @required Duration duration,
    Curve curve = Curves.linear,
    @required this.builder,
    VoidCallback onEnd,
    this.child,
  }) : assert(tween != null),
       assert(curve != null),
       assert(builder != null),
       super(key: key, duration: duration, curve: curve, onEnd: onEnd);

  /// Defines the target value for the animation.
  ///
  /// When the widget first builds, the animation runs from [Tween.begin] to
  /// [Tween.end], if [Tween.begin] is non-null. A new animation can be
  /// triggered at anytime by providing a new [Tween] with a new [Tween.end]
  /// value. The new animation runs from the current animation value (which may
  /// be [Tween.end] of the old [tween], if that animation completed) to
  /// [Tween.end] of the new [tween]. The [Tween.begin] value is ignored except
  /// for the initial animation that is triggered when the widget builds for the
  /// first time.
  ///
  /// Any (subclass of) [Tween] is accepted as an argument. For example, to
  /// animate the height or width of a [Widget], use a [Tween<double>], or
  /// check out the [ColorTween] to animate the color property of a [Widget].
  ///
  /// Any [Tween] provided must have a non-null [Tween.end] value.
  ///
  /// ## Ownership
  ///
  /// The [TweenAnimationBuilder] takes full ownership of the provided [Tween]
  /// and it will mutate the [Tween]. Once a [Tween] instance has been passed
  /// to [TweenAnimationBuilder] its properties should not be accessed or
  /// changed anymore to avoid any interference with the
  /// [TweenAnimationBuilder]. If you need to change the [Tween], create a
  /// **new instance** with the new values.
  ///
  /// It is good practice to never store a [Tween] provided to a
  /// [TweenAnimationBuilder] in an instance variable to avoid accidental
  /// modifications of the [Tween].
  final Tween<T> tween;

  /// Called every time the animation value changes.
  ///
  /// The current animation value is passed to the builder along with the
  /// [child]. The builder should build a [Widget] based on the current
  /// animation value and incorporate the [child] into it, if it is non-null.
  final ValueWidgetBuilder<T> builder;

  /// The child widget to pass to the builder.
  ///
  /// If a builder callback's return value contains a subtree that does not
  /// depend on the animation, it's more efficient to build that subtree once
  /// instead of rebuilding it on every animation tick.
  ///
  /// If the pre-built subtree is passed as the child parameter, the
  /// [TweenAnimationBuilder] will pass it back to the [builder] function so
  /// that it can be incorporated into the build.
  ///
  /// Using this pre-built child is entirely optional, but can improve
  /// performance significantly in some cases and is therefore a good practice.
  final Widget child;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() {
    return _TweenAnimationBuilderState<T>();
  }
}

class _TweenAnimationBuilderState<T> extends AnimatedWidgetBaseState<TweenAnimationBuilder<T>> {
  Tween<T> _currentTween;

  @override
  void initState() {
    _currentTween = widget.tween;
    _currentTween.begin ??= _currentTween.end;
    super.initState();
    if (_currentTween.begin != _currentTween.end) {
      controller.forward();
    }
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    assert(
      widget.tween.end != null,
      'Tween provided to TweenAnimationBuilder must have non-null Tween.end value.',
    );
    _currentTween = visitor(_currentTween, widget.tween.end, (dynamic value) {
      // Constructor will never be called because null is never provided as current tween.
      assert(false);
      return null;
    }) as Tween<T>;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentTween.evaluate(animation), widget.child);
  }
}
