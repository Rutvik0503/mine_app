import 'package:flutter/material.dart';
import '../constant/app_color.dart';

class AppText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    this.size = 14,
    this.weight = FontWeight.normal,
    this.color = AppColor.textPrimary,
    this.align,
    this.maxLines,
    this.overflow,
  });

  const AppText.heading(this.text, {super.key, this.color = AppColor.textPrimary, this.align})
      : size = 22,
        weight = FontWeight.w700,
        maxLines = null,
        overflow = null;

  const AppText.subHeading(this.text, {super.key, this.color = AppColor.textPrimary, this.align})
      : size = 16,
        weight = FontWeight.w600,
        maxLines = null,
        overflow = null;

  const AppText.caption(
    this.text, {
    super.key,
    this.color = AppColor.textSecondary,
    this.align,
    this.maxLines,
  })  : size = 12,
        weight = FontWeight.normal,
        overflow = null;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(fontSize: size, fontWeight: weight, color: color),
    );
  }
}
