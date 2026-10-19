import 'package:flutter/material.dart';

/// Name/type based icon hints so farm and machine UI communicate their kind
/// at a glance instead of one generic icon everywhere (Free/Air/Hydro/
/// Premium farms and standard/advanced machines should read differently).
class TypeIcons {
  TypeIcons._();

  static IconData farmType(String name) {
    final n = name.toLowerCase();
    if (n.contains('air')) return Icons.air_rounded;
    if (n.contains('hydro')) return Icons.water_drop_rounded;
    if (n.contains('premium')) return Icons.workspace_premium_rounded;
    return Icons.star_border_rounded; // Free / starter farm
  }

  static IconData machine(String machineType) {
    return machineType.toLowerCase() == 'advanced'
        ? Icons.speed_rounded
        : Icons.memory_rounded;
  }
}
