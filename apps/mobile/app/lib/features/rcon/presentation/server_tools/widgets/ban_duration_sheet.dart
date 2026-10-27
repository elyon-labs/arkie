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
  ('1 Hour', Duration(hours: 1)),
  ('1 Day', Duration(days: 1)),
  ('Permanent', Duration.zero),
];

class _BanDurationSheet extends HookWidget {
  const _BanDurationSheet();

  @override
  Widget build(BuildContext context) {
    final selected = useState<Duration>(_options.first.$2);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ban duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
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
            const SizedBox(height: 12),
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
