import 'package:flutter/material.dart';
import 'package:libadwaita/src/animations/slide_hide.dart';
import 'package:libadwaita/src/internal/window_resize_listener.dart';
import 'package:libadwaita/src/utils/colors.dart';

import 'custom_flap_controller.dart';
import 'custom_slide_hide.dart';

enum CustomFoldPolicy { never, always, auto }
enum FlapPosition { start, end }

class FlapCustomStyle {
  FlapCustomStyle({
    this.seperator,
    this.locked = false,
    this.breakpoint = 900,
    this.flapWidth = 270.0,
    this.foldPolicy = CustomFoldPolicy.auto,
    this.flapPosition = FlapPosition.start,
  });

  /// The seperator b/w flap and the content
  final Widget? seperator;

  /// The FoldPolicy of this flap, defaults to auto
  final CustomFoldPolicy foldPolicy;

  /// The FlapPosition of this flap, defaults to start
  final FlapPosition flapPosition;

  /// The breakpoint for small devices
  final double breakpoint;

  /// flap has a width of `flapWidth`
  /// Rest is allocated to content
  final double flapWidth;

  /// Whether to keep the flap's open
  /// state when screen is resized or
  /// not
  final bool locked;
}

class AdwCustomFlap extends StatefulWidget {
  AdwCustomFlap({
    Key? key,
    required this.flap,
    required this.child,
    this.controller,
    FlapCustomStyle? style,
    this.animationController
  })  : style = style ?? FlapCustomStyle(),
        super(key: key);

  /// The flap widget itself, Mainly is a `AdwSidebar` instance
  final Widget flap;

  /// The content of the page
  final Widget child;

  /// The style of this flap
  final FlapCustomStyle style;

  /// The controller for this flap
  final CustomFlapController? controller;

  final AnimationController? animationController;

  @override
  _AdwCustomFlapState createState() => _AdwCustomFlapState();
}

class _AdwCustomFlapState extends State<AdwCustomFlap> {
  late CustomFlapController _controller;

  void rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = CustomFlapController();
    } else {
      _controller = widget.controller!;
    }

    _controller.addListener(rebuild);
    updateFlapData();
    _controller.context = context;
  }

  void updateFlapData() {
    _controller
      ..policy = widget.style.foldPolicy
      ..position = widget.style.flapPosition
      ..locked = widget.style.locked;
  }

  @override
  void didUpdateWidget(covariant AdwCustomFlap oldWidget) {
    updateFlapData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.removeListener(rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // probably shouldn;t do this but no one is looking :P
    _controller.context = context;

    final content = Expanded(
      child: widget.child,
    );

    final flap = CustomSlideHide(
      controller: widget.animationController,
      isHidden: _controller.shouldHide(),
      width: widget.style.flapWidth,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: widget.flap,
      ),
    );

    final seperator = widget.style.seperator ??
        Container(
          width: 1,
          color: context.borderColor,
        );

    final widgets = widget.style.flapPosition == FlapPosition.start
        ? [flap, seperator, content]
        : [content, seperator, flap];

    return WindowResizeListener(
      onResize: (Size size) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          // The stuff that happens when the window is resized
          // We check for the mobile state and update it on every resize
          // Do nothin if FoldPolicy is never / always, because they are not
          // affected by window resizes.
          // If FoldPolicy is auto, then close / open the sidebar depending on the
          // state
          final isMobile = size.width < widget.style.breakpoint;
          _controller.updateModalState(context, state: isMobile);

          switch (widget.style.foldPolicy) {
            case CustomFoldPolicy.never:
            case CustomFoldPolicy.always:
              break;
            case CustomFoldPolicy.auto:
              _controller.updateOpenState(state: !isMobile);
              break;
          }
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }
}
