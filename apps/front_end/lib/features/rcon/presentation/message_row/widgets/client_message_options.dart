import 'package:arkie_ui/arkie_ui.dart';
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
      padding: const EdgeInsets.all(Sizes.unit),
      child: RoundedSuperellipseBox(
        color: context.colors.body,
        child: Padding(
          padding: const EdgeInsets.all(Sizes.unit / 2),
          child: Row(
            spacing: Sizes.unit / 2,
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: isSaved ? 'Unsave' : 'Save',
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    isSaved ? context.icons.unsave : context.icons.save,
                    size: Sizes.unit * 2.5,
                  ),
                  onPressed: onToggleSave,
                ),
              ),
              Tooltip(
                message: 'Resend',
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(context.icons.send, size: Sizes.unit * 2.5),
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
