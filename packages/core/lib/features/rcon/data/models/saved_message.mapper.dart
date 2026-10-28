// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'saved_message.dart';

class SavedMessageMapper extends ClassMapperBase<SavedMessage> {
  SavedMessageMapper._();

  static SavedMessageMapper? _instance;
  static SavedMessageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SavedMessageMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SavedMessage';

  static String _$id(SavedMessage v) => v.id;
  static const Field<SavedMessage, String> _f$id = Field('id', _$id);
  static String _$serverId(SavedMessage v) => v.serverId;
  static const Field<SavedMessage, String> _f$serverId = Field(
    'serverId',
    _$serverId,
  );
  static String _$body(SavedMessage v) => v.body;
  static const Field<SavedMessage, String> _f$body = Field('body', _$body);
  static String _$name(SavedMessage v) => v.name;
  static const Field<SavedMessage, String> _f$name = Field('name', _$name);

  @override
  final MappableFields<SavedMessage> fields = const {
    #id: _f$id,
    #serverId: _f$serverId,
    #body: _f$body,
    #name: _f$name,
  };

  static SavedMessage _instantiate(DecodingData data) {
    return SavedMessage(
      id: data.dec(_f$id),
      serverId: data.dec(_f$serverId),
      body: data.dec(_f$body),
      name: data.dec(_f$name),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SavedMessage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SavedMessage>(map);
  }

  static SavedMessage fromJson(String json) {
    return ensureInitialized().decodeJson<SavedMessage>(json);
  }
}

mixin SavedMessageMappable {
  String toJson() {
    return SavedMessageMapper.ensureInitialized().encodeJson<SavedMessage>(
      this as SavedMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return SavedMessageMapper.ensureInitialized().encodeMap<SavedMessage>(
      this as SavedMessage,
    );
  }

  SavedMessageCopyWith<SavedMessage, SavedMessage, SavedMessage> get copyWith =>
      _SavedMessageCopyWithImpl<SavedMessage, SavedMessage>(
        this as SavedMessage,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SavedMessageMapper.ensureInitialized().stringifyValue(
      this as SavedMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return SavedMessageMapper.ensureInitialized().equalsValue(
      this as SavedMessage,
      other,
    );
  }

  @override
  int get hashCode {
    return SavedMessageMapper.ensureInitialized().hashValue(
      this as SavedMessage,
    );
  }
}

extension SavedMessageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SavedMessage, $Out> {
  SavedMessageCopyWith<$R, SavedMessage, $Out> get $asSavedMessage =>
      $base.as((v, t, t2) => _SavedMessageCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SavedMessageCopyWith<$R, $In extends SavedMessage, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? serverId, String? body, String? name});
  SavedMessageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SavedMessageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SavedMessage, $Out>
    implements SavedMessageCopyWith<$R, SavedMessage, $Out> {
  _SavedMessageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SavedMessage> $mapper =
      SavedMessageMapper.ensureInitialized();
  @override
  $R call({String? id, String? serverId, String? body, String? name}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (serverId != null) #serverId: serverId,
      if (body != null) #body: body,
      if (name != null) #name: name,
    }),
  );
  @override
  SavedMessage $make(CopyWithData data) => SavedMessage(
    id: data.get(#id, or: $value.id),
    serverId: data.get(#serverId, or: $value.serverId),
    body: data.get(#body, or: $value.body),
    name: data.get(#name, or: $value.name),
  );

  @override
  SavedMessageCopyWith<$R2, SavedMessage, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SavedMessageCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

