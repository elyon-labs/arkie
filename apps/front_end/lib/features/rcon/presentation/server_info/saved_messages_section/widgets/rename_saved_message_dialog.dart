import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RenameSavedMessageDialog extends HookWidget {
  const RenameSavedMessageDialog({super.key, required this.savedMessage, required this.cubit});

  final SavedMessage savedMessage;
  final RCONCubit cubit;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: savedMessage.name);
    final updates = useListenable(controller);
    final canSubmit = useState(false);

    useEffect(() {
      canSubmit.value = updates.value.text.isNotEmpty && updates.value.text != savedMessage.name;
      return null;
    }, [updates.value.text]);

    Future<void> submit() async {
      if (!canSubmit.value) return;

      await cubit.renameSavedMessage(savedMessage.id, controller.text);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return AlertDialog(
      title: Text('Rename ${savedMessage.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'New command name'),
            onSubmitted: (_) => submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: canSubmit.value ? submit : null, child: const Text('Rename')),
      ],
    );
  }
}
