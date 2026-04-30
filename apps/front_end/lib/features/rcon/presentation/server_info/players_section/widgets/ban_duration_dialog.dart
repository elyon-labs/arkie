import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BanDurationDialog extends HookWidget {
  const BanDurationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDuration = useState<Duration>(const Duration(hours: 1));

    return AlertDialog(
      title: const Text('Select Ban Duration'),
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
                SizedBox(width: context.sizes.unit * 2),
                Text('1 Hour', style: context.text.title),
              ],
            ),
            Row(
              children: [
                const Radio(value: Duration(days: 1)),
                SizedBox(width: context.sizes.unit * 2),
                Text('1 Day', style: context.text.title),
              ],
            ),
            Row(
              children: [
                const Radio(value: Duration.zero),
                SizedBox(width: context.sizes.unit * 2),
                Text('Permanent', style: context.text.title),
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
          child: const Text('Ban'),
        ),
      ],
    );
  }
}
