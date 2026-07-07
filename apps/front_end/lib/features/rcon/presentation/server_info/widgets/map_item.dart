import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/core_ui/rounded_superellipse_box.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:flutter/material.dart';

class MapItem extends StatelessWidget {
  const MapItem({super.key, required this.map, this.onTap, required this.isCurrentMap});

  final bool isCurrentMap;
  final CS2Map map;
  final ValueSetter<CS2Map>? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call(map);
      },
      child: Tooltip(
        message: map.displayName,
        child: Badge(
          padding: EdgeInsets.zero,
          smallSize: context.sizes.unit * 1,
          backgroundColor: context.colors.accent,
          isLabelVisible: isCurrentMap,
          label: Padding(
            padding: EdgeInsets.all(context.sizes.unit * 0.05),
            child: Icon(context.icons.check),
          ),
          child: RoundedSuperellipseBox(
            color: context.colors.backgroundSecondary,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(context.sizes.unit),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Image.asset(map.assetPath, fit: BoxFit.fitHeight),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: Text(
                              map.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
