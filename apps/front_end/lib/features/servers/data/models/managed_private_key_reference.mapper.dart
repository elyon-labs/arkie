// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'managed_private_key_reference.dart';

class ManagedPrivateKeyReferenceMapper
    extends ClassMapperBase<ManagedPrivateKeyReference> {
  ManagedPrivateKeyReferenceMapper._();

  static ManagedPrivateKeyReferenceMapper? _instance;
  static ManagedPrivateKeyReferenceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = ManagedPrivateKeyReferenceMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'ManagedPrivateKeyReference';

  static String _$id(ManagedPrivateKeyReference v) => v.id;
  static const Field<ManagedPrivateKeyReference, String> _f$id = Field(
    'id',
    _$id,
  );
  static String _$displayName(ManagedPrivateKeyReference v) => v.displayName;
  static const Field<ManagedPrivateKeyReference, String> _f$displayName = Field(
    'displayName',
    _$displayName,
  );

  @override
  final MappableFields<ManagedPrivateKeyReference> fields = const {
    #id: _f$id,
    #displayName: _f$displayName,
  };

  static ManagedPrivateKeyReference _instantiate(DecodingData data) {
    return ManagedPrivateKeyReference(
      id: data.dec(_f$id),
      displayName: data.dec(_f$displayName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ManagedPrivateKeyReference fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ManagedPrivateKeyReference>(map);
  }

  static ManagedPrivateKeyReference fromJson(String json) {
    return ensureInitialized().decodeJson<ManagedPrivateKeyReference>(json);
  }
}

mixin ManagedPrivateKeyReferenceMappable {
  String toJson() {
    return ManagedPrivateKeyReferenceMapper.ensureInitialized()
        .encodeJson<ManagedPrivateKeyReference>(
          this as ManagedPrivateKeyReference,
        );
  }

  Map<String, dynamic> toMap() {
    return ManagedPrivateKeyReferenceMapper.ensureInitialized()
        .encodeMap<ManagedPrivateKeyReference>(
          this as ManagedPrivateKeyReference,
        );
  }

  ManagedPrivateKeyReferenceCopyWith<
    ManagedPrivateKeyReference,
    ManagedPrivateKeyReference,
    ManagedPrivateKeyReference
  >
  get copyWith =>
      _ManagedPrivateKeyReferenceCopyWithImpl<
        ManagedPrivateKeyReference,
        ManagedPrivateKeyReference
      >(this as ManagedPrivateKeyReference, $identity, $identity);
  @override
  String toString() {
    return ManagedPrivateKeyReferenceMapper.ensureInitialized().stringifyValue(
      this as ManagedPrivateKeyReference,
    );
  }

  @override
  bool operator ==(Object other) {
    return ManagedPrivateKeyReferenceMapper.ensureInitialized().equalsValue(
      this as ManagedPrivateKeyReference,
      other,
    );
  }

  @override
  int get hashCode {
    return ManagedPrivateKeyReferenceMapper.ensureInitialized().hashValue(
      this as ManagedPrivateKeyReference,
    );
  }
}

extension ManagedPrivateKeyReferenceValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ManagedPrivateKeyReference, $Out> {
  ManagedPrivateKeyReferenceCopyWith<$R, ManagedPrivateKeyReference, $Out>
  get $asManagedPrivateKeyReference => $base.as(
    (v, t, t2) => _ManagedPrivateKeyReferenceCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ManagedPrivateKeyReferenceCopyWith<
  $R,
  $In extends ManagedPrivateKeyReference,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? displayName});
  ManagedPrivateKeyReferenceCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ManagedPrivateKeyReferenceCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ManagedPrivateKeyReference, $Out>
    implements
        ManagedPrivateKeyReferenceCopyWith<
          $R,
          ManagedPrivateKeyReference,
          $Out
        > {
  _ManagedPrivateKeyReferenceCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ManagedPrivateKeyReference> $mapper =
      ManagedPrivateKeyReferenceMapper.ensureInitialized();
  @override
  $R call({String? id, String? displayName}) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (displayName != null) #displayName: displayName,
    }),
  );
  @override
  ManagedPrivateKeyReference $make(CopyWithData data) =>
      ManagedPrivateKeyReference(
        id: data.get(#id, or: $value.id),
        displayName: data.get(#displayName, or: $value.displayName),
      );

  @override
  ManagedPrivateKeyReferenceCopyWith<$R2, ManagedPrivateKeyReference, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ManagedPrivateKeyReferenceCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

