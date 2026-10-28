import 'package:arkie_mobile/features/servers/presentation/add_server_sheet/add_server_sheet_body.dart';
import 'package:arkie_state/features/servers/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:arkie_state/features/servers/servers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showAddServerSheet(BuildContext context) async {
  // The sheet is built off the navigator rather than this subtree, so the
  // servers cubit has to be carried across for the demo-server offer.
  final serversCubit = context.read<ServersCubit>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: serversCubit),
        BlocProvider(create: (_) => AddServerDialogCubit.create()),
      ],
      child: const AddServerSheetBody(),
    ),
  );
}
