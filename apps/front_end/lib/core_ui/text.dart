import 'package:flutter/material.dart';

class CS2RCONText extends ThemeExtension<CS2RCONText> {
  const CS2RCONText({
    required this.body,
    required this.title,
    required this.header,
    required this.caption,
  });

  final TextStyle body;
  final TextStyle title;
  final TextStyle header;
  final TextStyle caption;

  @override
  ThemeExtension<CS2RCONText> copyWith({
    TextStyle? body,
    TextStyle? title,
    TextStyle? header,
    TextStyle? caption,
  }) {
    return CS2RCONText(
      body: body ?? this.body,
      title: title ?? this.title,
      header: header ?? this.header,
      caption: caption ?? this.caption,
    );
  }

  @override
  CS2RCONText lerp(ThemeExtension<CS2RCONText>? other, double t) {
    if (other is! CS2RCONText) {
      return this;
    }
    return CS2RCONText(
      body: TextStyle.lerp(body, other.body, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      header: TextStyle.lerp(header, other.header, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}
