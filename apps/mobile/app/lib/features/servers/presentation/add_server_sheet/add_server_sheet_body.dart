import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_state/features/servers/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:dart_foundation/dart_foundation.dart' as app_async;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:oxidized/oxidized.dart';

class AddServerSheetBody extends HookWidget {
  const AddServerSheetBody({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final addressController = useTextEditingController();
    final portController = useTextEditingController(text: '27015');
    final passwordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final state = context.watch<AddServerDialogCubit>().state;
    final isSaving = state.addServerResult.isLoading;
    final errorText = switch (state.addServerResult) {
      app_async.Error(:final error) => error.toString(),
      _ => null,
    };

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: Form(
          key: formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Add a server',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const VSpace(),
              Text(
                'Arkie will verify the RCON connection before saving it.',
                style: TextStyle(color: context.colors.muted),
              ),
              const VSpace(space: 22),
              TextFormField(
                controller: nameController,
                enabled: !isSaving,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Server name'),
                onChanged: context.read<AddServerDialogCubit>().setName,
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a name' : null,
              ),
              const VSpace(space: 12),
              TextFormField(
                controller: addressController,
                enabled: !isSaving,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Address or hostname'),
                onChanged: context.read<AddServerDialogCubit>().setAddress,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter an address' : null,
              ),
              const VSpace(space: 12),
              TextFormField(
                controller: portController,
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Port'),
                onChanged: (value) =>
                    context.read<AddServerDialogCubit>().setPort(int.tryParse(value) ?? -1),
                validator: (value) {
                  final port = int.tryParse(value ?? '');
                  return port == null || port < 1 || port > 65535 ? 'Enter a valid port' : null;
                },
              ),
              const VSpace(space: 12),
              TextFormField(
                controller: passwordController,
                enabled: !isSaving,
                obscureText: true,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'RCON password'),
                onChanged: context.read<AddServerDialogCubit>().setPassword,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter the RCON password' : null,
              ),
              if (errorText != null) ...[
                const VSpace(space: 14),
                Text(errorText, style: TextStyle(color: context.colors.error)),
              ],
              const VSpace(space: 22),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (formKey.currentState?.validate() ?? false) {
                          await context.read<AddServerDialogCubit>().saveServer();
                          if (!context.mounted) return;
                          final result = context.read<AddServerDialogCubit>().state.addServerResult;
                          if (result case app_async.Loaded<Result<Server, String>>(
                            :final value,
                          ) when value.isOk()) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                child: Text(isSaving ? 'Connecting…' : 'Save server'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
