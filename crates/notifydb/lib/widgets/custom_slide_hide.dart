import 'package:flutter/widgets.dart';

class CustomSlideHide extends StatefulWidget {
  const CustomSlideHide({
    Key? key,
    required this.child,
    required this.isHidden,
    required this.width,
    this.controller,
  }) : super(key: key);

  final Widget child;
  final bool isHidden;
  final double width;
  final AnimationController? controller;

  @override
  _CustomSlideHideState createState() => _CustomSlideHideState();
}

class _CustomSlideHideState extends State<CustomSlideHide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> widthAnimation;
  late GlobalKey key;

  @override
  void initState() {
    _controller = widget.controller ?? AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    widthAnimation = Tween<double>(begin: widget.width, end: 0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));

    animate();
    super.initState();
  }

  AnimationController get controller => _controller;

  void animate() {
    if (widget.isHidden) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(CustomSlideHide oldWidget) {
    super.didUpdateWidget(oldWidget);
    animate();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 1,
          child: SizedBox(
            height: double.infinity,
            width: widthAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
