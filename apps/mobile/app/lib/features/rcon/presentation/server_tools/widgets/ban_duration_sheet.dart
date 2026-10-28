import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Prompts for a ban duration. Returns `null` if the user cancels, or
/// [Duration.zero] for a permanent ban.
Future<Duration?> showBanDurationSheet(BuildContext context) {
  return showModalBottomSheet<Duration>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _BanDurationSheet(),
  );
}

const _options = <(String, Duration)>[
  ('1 hour', Duration(hours: 1)),
  ('1 day', Duration(days: 1)),
  ('Permanent', Duration.zero),
];

class _BanDurationSheet extends HookWidget {
  const _BanDurationSheet();

  @override
  Widget build(BuildContext context) {
    final selected = useState<Duration>(_options.first.$2);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ArkieMetrics.edge,
          0,
          ArkieMetrics.edge,
          ArkieMetrics.edge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ban duration', style: context.text.title),
            const VSpace(space: ArkieMetrics.tight),
            RadioGroup<Duration>(
              groupValue: selected.value,
              onChanged: (value) {
                if (value != null) selected.value = value;
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (label, duration) in _options)
                    RadioListTile<Duration>(
                      value: duration,
                      title: Text(label),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
            const VSpace(space: ArkieMetrics.snug),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(selected.value),
              child: const Text('Ban player'),
            ),
          ],
        ),
      ),
    );
  }
}
