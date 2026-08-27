import 'package:flutter/material.dart';
import '../constant/app_color.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColor.primary));
  }
}

class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: const Center(child: CircularProgressIndicator(color: AppColor.primary)),
    );
  }
}
