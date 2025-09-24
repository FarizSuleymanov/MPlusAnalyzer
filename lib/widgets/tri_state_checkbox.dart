import 'package:flutter/material.dart';
import 'package:mplusanalyzer/widgets/auto_sliding_text.dart';

class TriStateCheckbox extends StatefulWidget {
  final int value;
  final String label;
  final ValueChanged<int> onChanged;
  const TriStateCheckbox({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  State<TriStateCheckbox> createState() => _TriStateCheckboxState();
}

class _TriStateCheckboxState extends State<TriStateCheckbox> {
  void _handleTap() {
    int newValue;
    switch (widget.value) {
      case 0:
        newValue = 2;
        break;
      case 2:
        newValue = 0;
        break;
      default:
        newValue = 0;
        break;
    }

    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor = Theme.of(context).primaryColor;

    switch (widget.value) {
      case 0: // Unchecked state
        iconData = Icons.check_box_outline_blank;
        break;
      case 1: // Dash (indeterminate) state
        iconData = Icons.indeterminate_check_box;
        break;
      case 2: // Checked state
        iconData = Icons.check_box;
        break;
      default: // Default to unchecked if an invalid value is provided.
        iconData = Icons.check_box_outline_blank;
        iconColor = Colors.grey; // Indicate an unexpected state with grey.
        break;
    }

    return GestureDetector(
      onTap: _handleTap, // Attach the tap handler.
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 20.0, // Make the icon size prominent.
              color: iconColor,
            ),
            SizedBox(width: 5),
            Expanded(child: AutoSlidingText(text: widget.label)),
          ],
        ),
      ),
    );
  }
}
