# Apps Coding Guidelines

- For Flutter widgets, prefer `HookWidget` with hooks over `StatefulWidget` whenever local widget state or lifecycle handling can be expressed cleanly with hooks.
- For Dart data classes, prefer `dart_mappable` generation over manual implementations of `copyWith`, equality, `hashCode`, serialization, or similar boilerplate.
