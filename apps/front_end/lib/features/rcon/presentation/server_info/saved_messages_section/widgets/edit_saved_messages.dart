import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/saved_messages_section/widgets/rename_saved_message_dialog.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/section_header.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/sidebar_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EditSavedMessages extends HookWidget {
  const EditSavedMessages({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final savedMessages = context.select((RCONCubit cubit) => cubit.state.savedMessages).toList();
    final dialogContext = Navigator.of(context, rootNavigator: true).context;
    return SidebarWrapper(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.sizes.edgeSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: const Text('Edit Saved Commands'),
              actions: [IconButton(onPressed: onClose, icon: Icon(context.icons.close))],
            ),

            SizedBox(height: context.sizes.unit * 2),

            for (final savedMessage in savedMessages)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(savedMessage.name),
                subtitle: savedMessage.name != savedMessage.body
                    ? Text(savedMessage.body, maxLines: 1, overflow: TextOverflow.ellipsis)
                    : null,
                trailing: FractionalTranslation(
                  translation: const Offset(0.25, 0),
                  child: MenuAnchor(
                    style: const MenuStyle(alignment: Alignment.centerLeft),
                    builder: (context, controller, child) => IconButton(
                      onPressed: () {
                        controller.isOpen ? controller.close() : controller.open();
                      },
                      icon: Icon(context.icons.menu),
                    ),
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () async {
                          await showDialog(
                            context: dialogContext,
                            builder: (_) => RenameSavedMessageDialog(
                              cubit: context.read<RCONCubit>(),
                              savedMessage: savedMessage,
                            ),
                          );
                        },
                        child: const Text('Rename'),
                      ),
                      MenuItemButton(
                        onPressed: () async {
                          await context.read<RCONCubit>().unsaveMessage(savedMessage);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
