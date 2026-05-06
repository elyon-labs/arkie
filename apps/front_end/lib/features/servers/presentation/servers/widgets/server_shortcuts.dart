import 'package:cs2_rcon_front_end/features/servers/presentation/servers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServerShortcuts extends StatelessWidget {
  const ServerShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        ...WidgetsApp.defaultActions,
        _OpenTabIntent: CallbackAction<_OpenTabIntent>(
          onInvoke: (_) {
            context.read<ServersCubit>().openTab();
            return null;
          },
        ),
        _CloseTabIntent: CallbackAction<_CloseTabIntent>(
          onInvoke: (_) {
            context.read<ServersCubit>().closeSelectedTab();
            return null;
          },
        ),
        _SelectPreviousTabIntent: CallbackAction<_SelectPreviousTabIntent>(
          onInvoke: (_) {
            context.read<ServersCubit>().selectPreviousServer();
            return null;
          },
        ),
        _SelectNextTabIntent: CallbackAction<_SelectNextTabIntent>(
          onInvoke: (_) {
            context.read<ServersCubit>().selectNextServer();
            return null;
          },
        ),
      },
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          ...WidgetsApp.defaultShortcuts,
          const SingleActivator(LogicalKeyboardKey.keyT, meta: true): const _OpenTabIntent(),
          const SingleActivator(LogicalKeyboardKey.keyT, control: true): const _OpenTabIntent(),
          const SingleActivator(LogicalKeyboardKey.keyW, meta: true): const _CloseTabIntent(),
          const SingleActivator(LogicalKeyboardKey.bracketLeft, meta: true, shift: true):
              const _SelectPreviousTabIntent(),
          const SingleActivator(LogicalKeyboardKey.braceLeft, meta: true, shift: true):
              const _SelectPreviousTabIntent(),
          const SingleActivator(LogicalKeyboardKey.tab, control: true, shift: true):
              const _SelectPreviousTabIntent(),
          const SingleActivator(LogicalKeyboardKey.bracketRight, meta: true, shift: true):
              const _SelectNextTabIntent(),
          const SingleActivator(LogicalKeyboardKey.braceRight, meta: true, shift: true):
              const _SelectNextTabIntent(),
          const SingleActivator(LogicalKeyboardKey.tab, control: true):
              const _SelectNextTabIntent(),
        },
        child: child,
      ),
    );
  }
}

class _OpenTabIntent extends Intent {
  const _OpenTabIntent();
}

class _SelectPreviousTabIntent extends Intent {
  const _SelectPreviousTabIntent();
}

class _SelectNextTabIntent extends Intent {
  const _SelectNextTabIntent();
}

class _CloseTabIntent extends Intent {
  const _CloseTabIntent();
}
