// Copyright (c) 2024. Omnimind Ltd.

import 'package:flutter/material.dart';
import 'package:open_ai_utilities/ui/widgets/text/app_text.dart';

class ValueSelector extends StatelessWidget {
  const ValueSelector({
    required this.value,
    this.decrease,
    this.increase,
    super.key,
  });

  final String value;

  final VoidCallback? decrease;

  final VoidCallback? increase;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: decrease, icon: const Icon(Icons.arrow_back)),
        AppText.labelLarge(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(onPressed: increase, icon: const Icon(Icons.arrow_forward)),
      ],
    );
  }
}
