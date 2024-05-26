// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _AppTextType {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
  textLinkLarge,
  textLinkSmall,
  button,
}

class AppText extends ConsumerWidget {
  const AppText.displayLarge(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.displayLarge;

  const AppText.displayMedium(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.displayMedium;

  const AppText.displaySmall(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.displaySmall;

  const AppText.headlineLarge(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.headlineLarge;

  const AppText.headlineMedium(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.headlineMedium;

  const AppText.titleLarge(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.titleLarge;

  const AppText.titleMedium(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.titleMedium;

  const AppText.titleSmall(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.titleSmall;

  const AppText.bodyMedium(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.bodyMedium;

  const AppText.bodySmall(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.bodySmall;

  const AppText.labelLarge(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.labelLarge;

  const AppText.labelMedium(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.labelMedium;

  const AppText.labelSmall(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.labelSmall;

  const AppText.textLinkLarge(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.textLinkLarge;

  const AppText.textLinkSmall(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.textLinkSmall;

  const AppText.button(
    this.data, {
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.style,
    super.key,
  }) : _type = _AppTextType.button;

  final _AppTextType _type;
  final String data;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final TextStyle? style;

  TextStyle? getStyle(ThemeData theme) {
    switch (_type) {
      case _AppTextType.displayLarge:
        return theme.textTheme.displayLarge;
      case _AppTextType.displayMedium:
        return theme.textTheme.displayMedium;
      case _AppTextType.displaySmall:
        return theme.textTheme.displaySmall;
      case _AppTextType.headlineLarge:
        return theme.textTheme.headlineLarge;
      case _AppTextType.headlineMedium:
        return theme.textTheme.headlineMedium;
      case _AppTextType.titleLarge:
        return theme.textTheme.titleLarge;
      case _AppTextType.titleMedium:
        return theme.textTheme.titleMedium;
      case _AppTextType.titleSmall:
        return theme.textTheme.titleSmall;
      case _AppTextType.bodyMedium:
        return theme.textTheme.bodyMedium;
      case _AppTextType.bodySmall:
        return theme.textTheme.bodySmall;
      case _AppTextType.labelLarge:
        return theme.textTheme.labelLarge;
      case _AppTextType.labelMedium:
        return theme.textTheme.labelMedium;
      case _AppTextType.labelSmall:
        return theme.textTheme.labelSmall;
      case _AppTextType.textLinkLarge:
        return theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
          letterSpacing: 0,
        );
      case _AppTextType.textLinkSmall:
        return theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
          letterSpacing: 0,
        );
      case _AppTextType.button:
        return theme.textTheme.titleLarge;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = Theme.of(context);

    return Text(
      data,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.fade,
      textAlign: textAlign,
      style: getStyle(appTheme)?.merge(style),
    );
  }
}
