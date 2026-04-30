import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/core_ui/rounded_superellipse_box.dart';
import 'package:flutter/material.dart';

class ClientMessageOptions extends StatelessWidget {
  const ClientMessageOptions({
    super.key,
    required this.isSaved,
    required this.onToggleSave,
    required this.onResend,
  });

  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.sizes.unit),
      child: RoundedSuperellipseBox(
        color: context.colors.background,
        child: Padding(
          padding: EdgeInsets.all(context.sizes.unit / 2),
          child: Row(
            spacing: context.sizes.unit / 2,
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: isSaved ? 'Unsave' : 'Save',
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    isSaved ? context.icons.unsave : context.icons.save,
                    size: context.sizes.unit * 2.5,
                  ),
                  onPressed: onToggleSave,
                ),
              ),
              Tooltip(
                message: 'Resend',
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(context.icons.send, size: context.sizes.unit * 2.5),
                  onPressed: onResend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
