import 'package:get/get.dart';

/// Global, app-lifetime dependencies go here. Feature-scoped controllers are
/// registered by each feature's own Binding (see features/*/bindings).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Reserved for cross-cutting singletons (e.g. a connectivity watcher).
  }
}
