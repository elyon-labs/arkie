import 'package:flutter/material.dart';

class CS2RCONIcons extends ThemeExtension<CS2RCONIcons> {
  const CS2RCONIcons({
    required this.server,
    required this.settings,
    required this.delete,
    required this.save,
    required this.unsave,
    required this.send,
    required this.edit,
    required this.grid,
    required this.list,
    required this.menu,
    required this.back,
    required this.close,
    required this.bot,
    required this.human,
    required this.kick,
    required this.ban,
    required this.add,
    required this.github,
    required this.check,
  });

  final IconData server;
  final IconData settings;
  final IconData delete;
  final IconData save;
  final IconData unsave;
  final IconData send;
  final IconData edit;
  final IconData grid;
  final IconData list;
  final IconData menu;
  final IconData back;
  final IconData close;
  final IconData bot;
  final IconData human;
  final IconData kick;
  final IconData ban;
  final IconData add;
  final IconData github;
  final IconData check;

  @override
  CS2RCONIcons copyWith({
    IconData? server,
    IconData? settings,
    IconData? delete,
    IconData? save,
    IconData? unsave,
    IconData? send,
    IconData? edit,
    IconData? grid,
    IconData? list,
    IconData? menu,
    IconData? back,
    IconData? close,
    IconData? bot,
    IconData? human,
    IconData? kick,
    IconData? ban,
    IconData? add,
    IconData? github,
    IconData? check,
  }) {
    return CS2RCONIcons(
      server: server ?? this.server,
      settings: settings ?? this.settings,
      delete: delete ?? this.delete,
      save: save ?? this.save,
      unsave: unsave ?? this.unsave,
      send: send ?? this.send,
      edit: edit ?? this.edit,
      grid: grid ?? this.grid,
      list: list ?? this.list,
      menu: menu ?? this.menu,
      back: back ?? this.back,
      close: close ?? this.close,
      bot: bot ?? this.bot,
      human: human ?? this.human,
      kick: kick ?? this.kick,
      ban: ban ?? this.ban,
      add: add ?? this.add,
      github: github ?? this.github,
      check: check ?? this.check,
    );
  }

  @override
  CS2RCONIcons lerp(ThemeExtension<CS2RCONIcons>? other, double t) {
    if (other is! CS2RCONIcons) {
      return this;
    }
    return CS2RCONIcons(
      server: t < 0.5 ? server : other.server,
      settings: t < 0.5 ? settings : other.settings,
      delete: t < 0.5 ? delete : other.delete,
      save: t < 0.5 ? save : other.save,
      unsave: t < 0.5 ? unsave : other.unsave,
      send: t < 0.5 ? send : other.send,
      edit: t < 0.5 ? edit : other.edit,
      grid: t < 0.5 ? grid : other.grid,
      list: t < 0.5 ? list : other.list,
      menu: t < 0.5 ? menu : other.menu,
      back: t < 0.5 ? back : other.back,
      close: t < 0.5 ? close : other.close,
      bot: t < 0.5 ? bot : other.bot,
      human: t < 0.5 ? human : other.human,
      kick: t < 0.5 ? kick : other.kick,
      ban: t < 0.5 ? ban : other.ban,
      add: t < 0.5 ? add : other.add,
      github: t < 0.5 ? github : other.github,
      check: t < 0.5 ? check : other.check,
    );
  }
}
