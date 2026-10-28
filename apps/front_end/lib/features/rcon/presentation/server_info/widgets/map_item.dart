import 'package:arkie_core/features/rcon/domain/models/cs2_map.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A map as an outlined tile. The one that is loaded keeps the accent, which
/// is the only thing distinguishing it — no badge, because the border already
/// has somewhere to say it.
class MapItem extends HookWidget {
  const MapItem({super.key, required this.map, this.onTap, required this.isCurrentMap});

  final bool isCurrentMap;
  final CS2Map map;
  final ValueSetter<CS2Map>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final arkie = context.arkieColors;
    final hovered = useState(false);

    final borderColor = isCurrentMap
        ? colors.accent
        : hovered.value
        ? arkie.borderStrong
        : arkie.border;

    return Tooltip(
      message: map.displayName,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => hovered.value = true,
        onExit: (_) => hovered.value = false,
        child: GestureDetector(
          onTap: () => onTap?.call(map),
          child: Container(
            decoration: BoxDecoration(
              color: isCurrentMap ? arkie.accentSurface : null,
              border: Border.all(color: borderColor, width: ArkieMetrics.hairline),
            ),
            padding: const EdgeInsets.symmetric(horizontal: ArkieMetrics.tight),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Image.asset(
                    map.assetPath,
                    package: CS2Map.assetPackage,
                    fit: BoxFit.contain,
                  ),
                ),
                const HSpace(space: ArkieMetrics.tight),
                Expanded(
                  child: Text(
                    map.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.caption.copyWith(
                      color: isCurrentMap ? colors.accent : colors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
