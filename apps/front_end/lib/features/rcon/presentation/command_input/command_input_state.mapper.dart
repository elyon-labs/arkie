// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'command_input_state.dart';

class CommandInputStateMapper extends ClassMapperBase<CommandInputState> {
  CommandInputStateMapper._();

  static CommandInputStateMapper? _instance;
  static CommandInputStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CommandInputStateMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CommandInputState';

  static List<CommandHelp> _$autoCompleteCommands(CommandInputState v) =>
      v.autoCompleteCommands;
  static const Field<CommandInputState, List<CommandHelp>>
  _f$autoCompleteCommands = Field(
    'autoCompleteCommands',
    _$autoCompleteCommands,
  );

  @override
  final MappableFields<CommandInputState> fields = const {
    #autoCompleteCommands: _f$autoCompleteCommands,
  };

  static CommandInputState _instantiate(DecodingData data) {
    return CommandInputState(
      autoCompleteCommands: data.dec(_f$autoCompleteCommands),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CommandInputState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CommandInputState>(map);
  }

  static CommandInputState fromJson(String json) {
    return ensureInitialized().decodeJson<CommandInputState>(json);
  }
}

mixin CommandInputStateMappable {
  String toJson() {
    return CommandInputStateMapper.ensureInitialized()
        .encodeJson<CommandInputState>(this as CommandInputState);
  }

  Map<String, dynamic> toMap() {
    return CommandInputStateMapper.ensureInitialized()
        .encodeMap<CommandInputState>(this as CommandInputState);
  }

  CommandInputStateCopyWith<
    CommandInputState,
    CommandInputState,
    CommandInputState
  >
  get copyWith =>
      _CommandInputStateCopyWithImpl<CommandInputState, CommandInputState>(
        this as CommandInputState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CommandInputStateMapper.ensureInitialized().stringifyValue(
      this as CommandInputState,
    );
  }

  @override
  bool operator ==(Object other) {
    return CommandInputStateMapper.ensureInitialized().equalsValue(
      this as CommandInputState,
      other,
    );
  }

  @override
  int get hashCode {
    return CommandInputStateMapper.ensureInitialized().hashValue(
      this as CommandInputState,
    );
  }
}

extension CommandInputStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CommandInputState, $Out> {
  CommandInputStateCopyWith<$R, CommandInputState, $Out>
  get $asCommandInputState => $base.as(
    (v, t, t2) => _CommandInputStateCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CommandInputStateCopyWith<
  $R,
  $In extends CommandInputState,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, CommandHelp, ObjectCopyWith<$R, CommandHelp, CommandHelp>>
  get autoCompleteCommands;
  $R call({List<CommandHelp>? autoCompleteCommands});
  CommandInputStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CommandInputStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CommandInputState, $Out>
    implements CommandInputStateCopyWith<$R, CommandInputState, $Out> {
  _CommandInputStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CommandInputState> $mapper =
      CommandInputStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, CommandHelp, ObjectCopyWith<$R, CommandHelp, CommandHelp>>
  get autoCompleteCommands => ListCopyWith(
    $value.autoCompleteCommands,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(autoCompleteCommands: v),
  );
  @override
  $R call({List<CommandHelp>? autoCompleteCommands}) => $apply(
    FieldCopyWithData({
      if (autoCompleteCommands != null)
        #autoCompleteCommands: autoCompleteCommands,
    }),
  );
  @override
  CommandInputState $make(CopyWithData data) => CommandInputState(
    autoCompleteCommands: data.get(
      #autoCompleteCommands,
      or: $value.autoCompleteCommands,
    ),
  );

  @override
  CommandInputStateCopyWith<$R2, CommandInputState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CommandInputStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

