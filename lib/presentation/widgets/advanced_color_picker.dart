import 'package:flutter/material.dart';

class AdvancedColorPicker extends StatefulWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const AdvancedColorPicker({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  State<AdvancedColorPicker> createState() => _AdvancedColorPickerState();
}

class _AdvancedColorPickerState extends State<AdvancedColorPicker> {
  late double _hue;
  late double _saturation;
  late double _value;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.currentColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  void _updateColor() {
    final hsv = HSVColor.fromAHSV(1.0, _hue, _saturation, _value);
    widget.onColorChanged(hsv.toColor());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Preview
        Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            '#${HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor().value.toRadixString(16).toUpperCase().substring(2)}',
            style: TextStyle(
              color: _value > 0.5 ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Hue Slider
        _ColorSlider(
          label: 'HUE',
          value: _hue,
          min: 0,
          max: 360,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF0000),
              Color(0xFFFFFF00),
              Color(0xFF00FF00),
              Color(0xFF00FFFF),
              Color(0xFF0000FF),
              Color(0xFFFF00FF),
              Color(0xFFFF0000),
            ],
          ),
          onChanged: (val) {
            setState(() => _hue = val);
            _updateColor();
          },
        ),

        // Saturation Slider
        _ColorSlider(
          label: 'SATURATION',
          value: _saturation,
          min: 0,
          max: 1,
          gradient: LinearGradient(
            colors: [
              Colors.grey,
              HSVColor.fromAHSV(1.0, _hue, 1.0, _value).toColor(),
            ],
          ),
          onChanged: (val) {
            setState(() => _saturation = val);
            _updateColor();
          },
        ),

        // Value (Brightness) Slider
        _ColorSlider(
          label: 'BRIGHTNESS',
          value: _value,
          min: 0,
          max: 1,
          gradient: const LinearGradient(colors: [Colors.black, Colors.white]),
          onChanged: (val) {
            setState(() => _value = val);
            _updateColor();
          },
        ),
      ],
    );
  }
}

class _ColorSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Gradient gradient;

  const _ColorSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: gradient,
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackShape: const RoundedRectSliderTrackShape(),
              trackHeight: 0, // Hide default track to see gradient
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 2,
              ),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.2),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
