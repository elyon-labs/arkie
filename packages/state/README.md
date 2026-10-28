# arkie_state

The presentation state shared by Arkie's desktop and mobile apps: the `flutter_bloc` cubits and the
states they emit. Widgets stay in each app; anything both apps drive lives here.

| Cubit                  | Drives                                                            |
| ---------------------- | ----------------------------------------------------------------- |
| `RCONCubit`            | A server's live connection, message history and saved commands.   |
| `ServerInfoCubit`      | Server status, players and maps, with undoable kicks/bans/changes. |
| `CommandInputCubit`    | Command autocomplete from the server's `find` command.             |
| `ServersCubit`         | The saved server list (and the desktop app's open tabs).           |
| `AddServerDialogCubit` | Validating and saving a new server.                                |

Async values in states use `Async<T>` from `dart_foundation`.
