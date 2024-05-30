// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter/material.dart';

class InteractiveButton extends StatefulWidget {
  const InteractiveButton({
    required Widget child,
    void Function()? onTap,
    super.key,
  })  : _child = child,
        _onTap = onTap;

  final Widget _child;

  final VoidCallback? _onTap;

  @override
  State<InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<InteractiveButton> {
  bool _hovering = false;
  bool _tapped = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _tapped
            ? Colors.grey.shade300.withOpacity(0.2)
            : _hovering
                ? Colors.grey.shade200.withOpacity(0.2)
                : Colors.transparent,
      ),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _hovering = true;
          });
        },
        onExit: (_) {
          setState(() {
            _hovering = false;
            _tapped = false;
          });
        },
        child: InkWell(
          onTap: widget._onTap,
          onTapDown: (_) {
            setState(() {
              _tapped = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              _tapped = false;
            });
          },
          child: widget._child,
        ),
      ),
    );
  }
}
