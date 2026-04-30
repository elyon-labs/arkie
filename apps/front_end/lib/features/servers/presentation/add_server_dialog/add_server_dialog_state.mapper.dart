// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'add_server_dialog_state.dart';

class AddServerDialogStateMapper extends ClassMapperBase<AddServerDialogState> {
  AddServerDialogStateMapper._();

  static AddServerDialogStateMapper? _instance;
  static AddServerDialogStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AddServerDialogStateMapper._());
      ServerMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AddServerDialogState';

  static Async<Result<Server, String>> _$addServerResult(
    AddServerDialogState v,
  ) => v.addServerResult;
  static const Field<AddServerDialogState, Async<Result<Server, String>>>
  _f$addServerResult = Field('addServerResult', _$addServerResult);
  static String _$name(AddServerDialogState v) => v.name;
  static const Field<AddServerDialogState, String> _f$name = Field(
    'name',
    _$name,
  );
  static String _$address(AddServerDialogState v) => v.address;
  static const Field<AddServerDialogState, String> _f$address = Field(
    'address',
    _$address,
  );
  static int _$port(AddServerDialogState v) => v.port;
  static const Field<AddServerDialogState, int> _f$port = Field('port', _$port);
  static String _$password(AddServerDialogState v) => v.password;
  static const Field<AddServerDialogState, String> _f$password = Field(
    'password',
    _$password,
  );

  @override
  final MappableFields<AddServerDialogState> fields = const {
    #addServerResult: _f$addServerResult,
    #name: _f$name,
    #address: _f$address,
    #port: _f$port,
    #password: _f$password,
  };

  static AddServerDialogState _instantiate(DecodingData data) {
    return AddServerDialogState(
      addServerResult: data.dec(_f$addServerResult),
      name: data.dec(_f$name),
      address: data.dec(_f$address),
      port: data.dec(_f$port),
      password: data.dec(_f$password),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AddServerDialogState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AddServerDialogState>(map);
  }

  static AddServerDialogState fromJson(String json) {
    return ensureInitialized().decodeJson<AddServerDialogState>(json);
  }
}

mixin AddServerDialogStateMappable {
  String toJson() {
    return AddServerDialogStateMapper.ensureInitialized()
        .encodeJson<AddServerDialogState>(this as AddServerDialogState);
  }

  Map<String, dynamic> toMap() {
    return AddServerDialogStateMapper.ensureInitialized()
        .encodeMap<AddServerDialogState>(this as AddServerDialogState);
  }

  AddServerDialogStateCopyWith<
    AddServerDialogState,
    AddServerDialogState,
    AddServerDialogState
  >
  get copyWith =>
      _AddServerDialogStateCopyWithImpl<
        AddServerDialogState,
        AddServerDialogState
      >(this as AddServerDialogState, $identity, $identity);
  @override
  String toString() {
    return AddServerDialogStateMapper.ensureInitialized().stringifyValue(
      this as AddServerDialogState,
    );
  }

  @override
  bool operator ==(Object other) {
    return AddServerDialogStateMapper.ensureInitialized().equalsValue(
      this as AddServerDialogState,
      other,
    );
  }

  @override
  int get hashCode {
    return AddServerDialogStateMapper.ensureInitialized().hashValue(
      this as AddServerDialogState,
    );
  }
}

extension AddServerDialogStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AddServerDialogState, $Out> {
  AddServerDialogStateCopyWith<$R, AddServerDialogState, $Out>
  get $asAddServerDialogState => $base.as(
    (v, t, t2) => _AddServerDialogStateCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class AddServerDialogStateCopyWith<
  $R,
  $In extends AddServerDialogState,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    Async<Result<Server, String>>? addServerResult,
    String? name,
    String? address,
    int? port,
    String? password,
  });
  AddServerDialogStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AddServerDialogStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AddServerDialogState, $Out>
    implements AddServerDialogStateCopyWith<$R, AddServerDialogState, $Out> {
  _AddServerDialogStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AddServerDialogState> $mapper =
      AddServerDialogStateMapper.ensureInitialized();
  @override
  $R call({
    Async<Result<Server, String>>? addServerResult,
    String? name,
    String? address,
    int? port,
    String? password,
  }) => $apply(
    FieldCopyWithData({
      if (addServerResult != null) #addServerResult: addServerResult,
      if (name != null) #name: name,
      if (address != null) #address: address,
      if (port != null) #port: port,
      if (password != null) #password: password,
    }),
  );
  @override
  AddServerDialogState $make(CopyWithData data) => AddServerDialogState(
    addServerResult: data.get(#addServerResult, or: $value.addServerResult),
    name: data.get(#name, or: $value.name),
    address: data.get(#address, or: $value.address),
    port: data.get(#port, or: $value.port),
    password: data.get(#password, or: $value.password),
  );

  @override
  AddServerDialogStateCopyWith<$R2, AddServerDialogState, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AddServerDialogStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

