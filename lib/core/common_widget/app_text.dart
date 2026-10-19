import 'package:flutter/material.dart';
import '../constant/app_color.dart';

enum _TextColorDefault { primary, secondary }

class AppText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final Color? color;
  final _TextColorDefault _colorDefault;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    this.size = 14,
    this.weight = FontWeight.normal,
    this.color,
    this.align,
    this.maxLines,
    this.overflow,
  }) : _colorDefault = _TextColorDefault.primary;

  const AppText.heading(this.text, {super.key, this.color, this.align})
      : size = 22,
        weight = FontWeight.w700,
        maxLines = null,
        overflow = null,
        _colorDefault = _TextColorDefault.primary;

  const AppText.subHeading(this.text, {super.key, this.color, this.align})
      : size = 16,
        weight = FontWeight.w600,
        maxLines = null,
        overflow = null,
        _colorDefault = _TextColorDefault.primary;

  const AppText.caption(
    this.text, {
    super.key,
    this.color,
    this.align,
    this.maxLines,
  })  : size = 12,
        weight = FontWeight.normal,
        overflow = null,
        _colorDefault = _TextColorDefault.secondary;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ??
        (_colorDefault == _TextColorDefault.secondary ? AppColor.textSecondary : AppColor.textPrimary);
    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(fontSize: size, fontWeight: weight, color: resolvedColor),
    );
  }
}
