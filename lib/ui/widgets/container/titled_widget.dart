// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter/material.dart';

class TitledWidget extends StatelessWidget {
  const TitledWidget({
    required String title,
    required Widget child,
    MainAxisSize contentMainAxisSize = MainAxisSize.max,
    Widget? trailing,
    super.key,
  })  : _title = title,
        _child = child,
        _contentMainAxisSize = contentMainAxisSize,
        _trailing = trailing;

  final String _title;

  final Widget _child;

  final Widget? _trailing;

  final MainAxisSize _contentMainAxisSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ]),
      child: Column(
        mainAxisSize: _contentMainAxisSize,
        children: [
          Container(
              padding: const EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: 8,
                right: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (_trailing != null) _trailing,
                ],
              )),
          _child,
        ],
      ),
    );
  }
}
