import 'package:flutter/material.dart';

class RangeSliderLabelled extends StatelessWidget {
  const RangeSliderLabelled({
    super.key,
    required this.values,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.onChanged,
  });

  final RangeValues values;
  final double min;
  final double max;
  final int? divisions;
  final Function(RangeValues)? onChanged;

  @override
  Widget build(BuildContext context) {
    // This is the padding that the RangeSlider uses internally. We need to
    // account for this when calculating the position of the labels.
    const paddingOffset = 24;

    return LayoutBuilder(
      builder: (context, constraints) {
        final sliderWidth = constraints.maxWidth - paddingOffset * 2;
        final startPosition =
            (values.start - min) / (max - min) * sliderWidth + 8;
        final endPosition = (values.end - min) / (max - min) * sliderWidth + 14;

        return Stack(
          children: [
            Positioned(
              left: startPosition,
              top: 0,
              child: Container(
                alignment: Alignment.center,
                width: 40,
                child: Text(
                  '${(values.start * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            Positioned(
              left: endPosition,
              top: 0,
              child: Text(
                '${(values.end * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            RangeSlider(
              values: values,
              divisions: divisions,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ],
        );
      },
    );
  }
}
