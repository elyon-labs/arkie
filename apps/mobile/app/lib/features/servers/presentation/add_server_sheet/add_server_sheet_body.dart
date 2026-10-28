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
    final cubit = context.read<AddServerDialogCubit>();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ArkieMetrics.edge,
          0,
          ArkieMetrics.edge,
          MediaQuery.viewInsetsOf(context).bottom + ArkieMetrics.edge,
        ),
        child: Form(
          key: formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Add a server', style: context.text.title),
              const VSpace(space: ArkieMetrics.tight),
              Text(
                'Arkie connects once to check the details before saving them.',
                style: context.text.caption.copyWith(color: context.arkieColors.textFaint),
              ),
              const VSpace(space: ArkieMetrics.loose),
              _Field(
                label: 'name',
                controller: nameController,
                enabled: !isSaving,
                textCapitalization: TextCapitalization.words,
                onChanged: cubit.setName,
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a name' : null,
              ),
              const VSpace(space: ArkieMetrics.snug),
              _Field(
                label: 'address',
                controller: addressController,
                enabled: !isSaving,
                keyboardType: TextInputType.url,
                onChanged: cubit.setAddress,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter an address' : null,
              ),
              const VSpace(space: ArkieMetrics.snug),
              _Field(
                label: 'port',
                controller: portController,
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                onChanged: (value) => cubit.setPort(int.tryParse(value) ?? -1),
                validator: (value) {
                  final port = int.tryParse(value ?? '');
                  return port == null || port < 1 || port > 65535 ? 'Enter a valid port' : null;
                },
              ),
              const VSpace(space: ArkieMetrics.snug),
              _Field(
                label: 'rcon password',
                controller: passwordController,
                enabled: !isSaving,
                obscureText: true,
                onChanged: cubit.setPassword,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter the RCON password' : null,
              ),
              if (errorText != null) ...[
                const VSpace(space: ArkieMetrics.snug),
                Text(errorText, style: context.text.caption.copyWith(color: context.colors.error)),
              ],
              const VSpace(space: ArkieMetrics.loose),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        await cubit.saveServer();
                        if (!context.mounted) return;
                        final result = cubit.state.addServerResult;
                        if (result case app_async.Loaded<Result<Server, String>>(
                          :final value,
                        ) when value.isOk()) {
                          Navigator.of(context).pop();
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

/// A field labelled above the box rather than inside it, so a column of them
/// shows every label at once and the boxes stay the same height.
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onChanged,
    required this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.caption.copyWith(color: context.colors.muted)),
        const VSpace(space: ArkieMetrics.gutter),
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          autocorrect: false,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: context.text.body,
          cursorWidth: 8,
          cursorRadius: Radius.zero,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
