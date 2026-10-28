import 'package:arkie_mobile/features/servers/presentation/add_server_sheet/add_server_sheet_body.dart';
import 'package:arkie_state/features/servers/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showAddServerSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider(
      create: (_) => AddServerDialogCubit.create(),
      child: const AddServerSheetBody(),
    ),
  );
}
