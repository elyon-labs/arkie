import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/core_ui/rounded_superellipse_box.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedMessagesSection extends StatelessWidget {
  const SavedMessagesSection({super.key, required this.onMenuTap, required this.padding});

  final VoidCallback onMenuTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final savedMessages = context.select((RCONCubit cubit) => cubit.state.savedMessages).toList();

    if (savedMessages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: const Text('Commands'),
            actions: [IconButton(onPressed: onMenuTap, icon: Icon(context.icons.menu))],
          ),
          SizedBox(height: context.sizes.unit * 2),
          GridView.builder(
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: context.sizes.unit,
              crossAxisSpacing: context.sizes.unit * 2,
              childAspectRatio: 4,
            ),
            itemCount: savedMessages.length,
            itemBuilder: (context, index) {
              final command = savedMessages[index];
              return _SavedMessageItem(message: command);
            },
          ),
        ],
      ),
    );
  }
}

class _SavedMessageItem extends StatelessWidget {
  const _SavedMessageItem({required this.message});

  final SavedMessage message;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message.body,
      child: GestureDetector(
        onTap: () async {
          await context.read<RCONCubit>().sendCommand(message.body);
        },
        child: RoundedSuperellipseBox(
          color: context.colors.backgroundSecondary,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(context.sizes.unit),
              child: Text(message.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ),
    );
  }
}
