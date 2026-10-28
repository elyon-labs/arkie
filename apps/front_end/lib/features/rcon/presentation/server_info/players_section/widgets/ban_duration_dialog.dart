import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BanDurationDialog extends HookWidget {
  const BanDurationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDuration = useState<Duration>(const Duration(hours: 1));

    return AlertDialog(
      title: const Text('Ban duration'),
      content: RadioGroup<Duration>(
        groupValue: selectedDuration.value,
        onChanged: (value) {
          if (value != null) {
            selectedDuration.value = value;
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Radio(value: Duration(hours: 1)),
                const HSpace(space: ArkieMetrics.snug),
                Text('1 hour', style: context.text.body),
              ],
            ),
            Row(
              children: [
                const Radio(value: Duration(days: 1)),
                const HSpace(space: ArkieMetrics.snug),
                Text('1 day', style: context.text.body),
              ],
            ),
            Row(
              children: [
                const Radio(value: Duration.zero),
                const HSpace(space: ArkieMetrics.snug),
                Text('Permanent', style: context.text.body),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(selectedDuration.value);
          },
          child: const Text('Ban player'),
        ),
      ],
    );
  }
}
