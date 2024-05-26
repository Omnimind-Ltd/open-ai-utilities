// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum SpinKitType {
  pulse,
  wave,
}

class LoadingWidget extends ConsumerWidget {
  const LoadingWidget({
    final double size = 50.0,
    SpinKitType spinKitType = SpinKitType.pulse,
    super.key,
  })  : _size = size,
        _spinKitType = spinKitType;

  final SpinKitType _spinKitType;

  final double _size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = Theme.of(context);

    switch (_spinKitType) {
      case SpinKitType.pulse:
        return SpinKitPulse(
          size: _size,
          color: appTheme.colorScheme.secondary,
        );
      case SpinKitType.wave:
        return SpinKitWave(
          size: _size,
          color: appTheme.colorScheme.secondary,
        );
    }
  }
}
