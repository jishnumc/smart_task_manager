import 'dart:async' show scheduleMicrotask;
import 'dart:collection' show Queue;
import 'dart:ui' show PointerDataPacket;

import 'package:flutter/gestures.dart' show PointerEventConverter;
import 'package:flutter/rendering.dart' show RenderView, ViewConfiguration;
import 'package:flutter/widgets.dart';

/// A function that calculates the scale factor based on the device size.
///
/// Returns a double representing the scale. A scale of 1.0 means original size.
typedef ScaleResolver = double Function(Size deviceSize);

/// A custom [WidgetsFlutterBinding] that allows scaling the UI based on a
/// provided [ScaleResolver].
///
/// This binding overrides [createViewConfigurationFor] to adjust the
/// [ViewConfiguration] with a new device pixel ratio and logical constraints,
/// effectively scaling the entire application UI.
class ScaleUiBinding extends WidgetsFlutterBinding {
  ScaleUiBinding._({ScaleResolver? scaleResolver})
    : _scaleResolver = scaleResolver;

  /// The current, active instance of [ScaleUiBinding].
  ///
  /// This variable is initialized in [ensureInitialized].
  static ScaleUiBinding? _instance;

  /// Returns the singleton instance of [ScaleUiBinding].
  ///
  /// Throws if [ensureInitialized] has not been called.
  static ScaleUiBinding get instance => _instance!;

  /// Initializes the binding with an optional [ScaleResolver].
  ///
  /// This must be called before `runApp`.
  static WidgetsBinding ensureInitialized({ScaleResolver? scaleResolver}) {
    _instance ??= ScaleUiBinding._(scaleResolver: scaleResolver);
    return _instance!;
  }

  /// The resolver used to determine the scale factor.
  ScaleResolver? _scaleResolver;

  /// Cached scale value to avoid repeated calculations.
  double? _cachedScale;

  /// Default resolver that returns 1.0 (no scaling).
  static double _defaultScaleResolver(Size _) => 1;

  /// Gets the current scale factor derived from the [scaleResolver].
  ///
  /// Defaults to 1.0 if no resolver is set.
  double get scale {
    if (_cachedScale != null) return _cachedScale!;

    final view = platformDispatcher.implicitView!;
    final pixelRatio = view.devicePixelRatio;
    final physicalSize = view.physicalSize;

    // Cache the result
    return _cachedScale = scaleResolver(physicalSize / pixelRatio);
  }

  /// The active [ScaleResolver].
  ///
  /// Defaults to returning 1.0 if not explicitly set.
  ScaleResolver get scaleResolver => _scaleResolver ?? _defaultScaleResolver;

  /// Updates the [ScaleResolver] and triggers a layout rebuild.
  set scaleResolver(ScaleResolver? resolver) {
    _scaleResolver = resolver;
    handleMetricsChanged();
  }

  @override
  void handleMetricsChanged() {
    _cachedScale = null; // Invalidate cache
    _scaledPixelRatio = 0; // Invalidate pixel ratio cache
    super.handleMetricsChanged();
  }

  /// Returns `true` if the current scale is not 1.0.
  bool get isScaling => scale != 1.0;

  /// Caches the scaled device pixel ratio for use in pointer events.
  double _scaledPixelRatio = 0;

  /// Public accessor for the scaled device pixel ratio.
  ///
  /// This is updated whenever [createViewConfigurationFor] is called,
  /// or calculated on demand if not yet set.
  double get scaledPixelRatio {
    if (_scaledPixelRatio == 0) {
      final view = platformDispatcher.implicitView!;
      _scaledPixelRatio = view.devicePixelRatio * scale;
    }
    return _scaledPixelRatio;
  }

  @override
  ViewConfiguration createViewConfigurationFor(RenderView renderView) {
    final view = platformDispatcher.implicitView!;
    final pixelRatio = view.devicePixelRatio;
    final physicalSize = view.physicalSize;

    if (physicalSize.isEmpty) {
      return super.createViewConfigurationFor(renderView);
    }

    _scaledPixelRatio = pixelRatio * scale;

    final physicalConstraints = BoxConstraints.fromViewConstraints(
      view.physicalConstraints,
    );

    return ViewConfiguration(
      physicalConstraints: physicalConstraints,
      logicalConstraints: physicalConstraints / _scaledPixelRatio,
      devicePixelRatio: _scaledPixelRatio,
    );
  }

  @override
  void initInstances() {
    super.initInstances();
    // Intercept pointer data to adjust for the scaled UI.
    platformDispatcher.onPointerDataPacket = _handlePointerDataPacket;
  }

  @override
  void unlocked() {
    super.unlocked();
    _flushPointerEventQueue();
  }

  final Queue<PointerEvent> _pendingPointerEvents = Queue<PointerEvent>();

  /// Handles incoming pointer data packets.
  ///
  /// Because the UI is scaled, the pointer coordinates must be adjusted
  /// to match the logical pixels expected by the framework.
  void _handlePointerDataPacket(PointerDataPacket packet) {
    try {
      _pendingPointerEvents.addAll(
        PointerEventConverter.expand(packet.data, (viewId) {
          // Use the cached scaled pixel ratio.
          return scaledPixelRatio;
        }),
      );
      if (!locked) {
        _flushPointerEventQueue();
      }
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'gestures library',
          context: ErrorDescription(
            'while handling a scaled pointer data packet',
          ),
        ),
      );
    }
  }

  @override
  void cancelPointer(int pointer) {
    if (_pendingPointerEvents.isEmpty && !locked) {
      scheduleMicrotask(_flushPointerEventQueue);
    }
    _pendingPointerEvents.addFirst(PointerCancelEvent(pointer: pointer));
  }

  void _flushPointerEventQueue() {
    assert(!locked, '_flushPointerEventQueue called while locked');
    while (_pendingPointerEvents.isNotEmpty) {
      handlePointerEvent(_pendingPointerEvents.removeFirst());
    }
  }
}

/// Extensions to help usage with Scaled UI.
extension ScaledMediaQueryData on MediaQueryData {
  /// Scales the [MediaQueryData] to account for the custom scale factor.
  ///
  /// This ensures that widgets relying on [MediaQuery], such as keyboards
  /// or app bars, are laid out correctly in the scaled environment.
  MediaQueryData scaled() {
    final scale = ScaleUiBinding._instance?.scale ?? 1.0;
    return copyWith(
      size: size / scale,
      devicePixelRatio: devicePixelRatio * scale,
      viewInsets: viewInsets / scale,
      viewPadding: viewPadding / scale,
      padding: padding / scale,
    );
  }
}
