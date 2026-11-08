// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'update_status.dart';

class UpdateStatusMapper extends ClassMapperBase<UpdateStatus> {
  UpdateStatusMapper._();

  static UpdateStatusMapper? _instance;
  static UpdateStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UpdateStatusMapper._());
      UpToDateMapper.ensureInitialized();
      UpdateAvailableMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'UpdateStatus';

  @override
  final MappableFields<UpdateStatus> fields = const {};

  static UpdateStatus _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'UpdateStatus',
      'status',
      '${data.value['status']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UpdateStatus fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UpdateStatus>(map);
  }

  static UpdateStatus fromJson(String json) {
    return ensureInitialized().decodeJson<UpdateStatus>(json);
  }
}

mixin UpdateStatusMappable {
  String toJson();
  Map<String, dynamic> toMap();
  UpdateStatusCopyWith<UpdateStatus, UpdateStatus, UpdateStatus> get copyWith;
}

abstract class UpdateStatusCopyWith<$R, $In extends UpdateStatus, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  UpdateStatusCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class UpToDateMapper extends SubClassMapperBase<UpToDate> {
  UpToDateMapper._();

  static UpToDateMapper? _instance;
  static UpToDateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UpToDateMapper._());
      UpdateStatusMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'UpToDate';

  @override
  final MappableFields<UpToDate> fields = const {};

  @override
  final String discriminatorKey = 'status';
  @override
  final dynamic discriminatorValue = 'UpToDate';
  @override
  late final ClassMapperBase superMapper =
      UpdateStatusMapper.ensureInitialized();

  static UpToDate _instantiate(DecodingData data) {
    return UpToDate();
  }

  @override
  final Function instantiate = _instantiate;

  static UpToDate fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UpToDate>(map);
  }

  static UpToDate fromJson(String json) {
    return ensureInitialized().decodeJson<UpToDate>(json);
  }
}

mixin UpToDateMappable {
  String toJson() {
    return UpToDateMapper.ensureInitialized().encodeJson<UpToDate>(
      this as UpToDate,
    );
  }

  Map<String, dynamic> toMap() {
    return UpToDateMapper.ensureInitialized().encodeMap<UpToDate>(
      this as UpToDate,
    );
  }

  UpToDateCopyWith<UpToDate, UpToDate, UpToDate> get copyWith =>
      _UpToDateCopyWithImpl<UpToDate, UpToDate>(
        this as UpToDate,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UpToDateMapper.ensureInitialized().stringifyValue(this as UpToDate);
  }

  @override
  bool operator ==(Object other) {
    return UpToDateMapper.ensureInitialized().equalsValue(
      this as UpToDate,
      other,
    );
  }

  @override
  int get hashCode {
    return UpToDateMapper.ensureInitialized().hashValue(this as UpToDate);
  }
}

extension UpToDateValueCopy<$R, $Out> on ObjectCopyWith<$R, UpToDate, $Out> {
  UpToDateCopyWith<$R, UpToDate, $Out> get $asUpToDate =>
      $base.as((v, t, t2) => _UpToDateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UpToDateCopyWith<$R, $In extends UpToDate, $Out>
    implements UpdateStatusCopyWith<$R, $In, $Out> {
  @override
  $R call();
  UpToDateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UpToDateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UpToDate, $Out>
    implements UpToDateCopyWith<$R, UpToDate, $Out> {
  _UpToDateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UpToDate> $mapper =
      UpToDateMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  UpToDate $make(CopyWithData data) => UpToDate();

  @override
  UpToDateCopyWith<$R2, UpToDate, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UpToDateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class UpdateAvailableMapper extends SubClassMapperBase<UpdateAvailable> {
  UpdateAvailableMapper._();

  static UpdateAvailableMapper? _instance;
  static UpdateAvailableMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UpdateAvailableMapper._());
      UpdateStatusMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'UpdateAvailable';

  static Version _$version(UpdateAvailable v) => v.version;
  static const Field<UpdateAvailable, Version> _f$version = Field(
    'version',
    _$version,
  );

  @override
  final MappableFields<UpdateAvailable> fields = const {#version: _f$version};

  @override
  final String discriminatorKey = 'status';
  @override
  final dynamic discriminatorValue = 'UpdateAvailable';
  @override
  late final ClassMapperBase superMapper =
      UpdateStatusMapper.ensureInitialized();

  static UpdateAvailable _instantiate(DecodingData data) {
    return UpdateAvailable(version: data.dec(_f$version));
  }

  @override
  final Function instantiate = _instantiate;

  static UpdateAvailable fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UpdateAvailable>(map);
  }

  static UpdateAvailable fromJson(String json) {
    return ensureInitialized().decodeJson<UpdateAvailable>(json);
  }
}

mixin UpdateAvailableMappable {
  String toJson() {
    return UpdateAvailableMapper.ensureInitialized()
        .encodeJson<UpdateAvailable>(this as UpdateAvailable);
  }

  Map<String, dynamic> toMap() {
    return UpdateAvailableMapper.ensureInitialized().encodeMap<UpdateAvailable>(
      this as UpdateAvailable,
    );
  }

  UpdateAvailableCopyWith<UpdateAvailable, UpdateAvailable, UpdateAvailable>
  get copyWith =>
      _UpdateAvailableCopyWithImpl<UpdateAvailable, UpdateAvailable>(
        this as UpdateAvailable,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UpdateAvailableMapper.ensureInitialized().stringifyValue(
      this as UpdateAvailable,
    );
  }

  @override
  bool operator ==(Object other) {
    return UpdateAvailableMapper.ensureInitialized().equalsValue(
      this as UpdateAvailable,
      other,
    );
  }

  @override
  int get hashCode {
    return UpdateAvailableMapper.ensureInitialized().hashValue(
      this as UpdateAvailable,
    );
  }
}

extension UpdateAvailableValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UpdateAvailable, $Out> {
  UpdateAvailableCopyWith<$R, UpdateAvailable, $Out> get $asUpdateAvailable =>
      $base.as((v, t, t2) => _UpdateAvailableCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UpdateAvailableCopyWith<$R, $In extends UpdateAvailable, $Out>
    implements UpdateStatusCopyWith<$R, $In, $Out> {
  @override
  $R call({Version? version});
  UpdateAvailableCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _UpdateAvailableCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UpdateAvailable, $Out>
    implements UpdateAvailableCopyWith<$R, UpdateAvailable, $Out> {
  _UpdateAvailableCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UpdateAvailable> $mapper =
      UpdateAvailableMapper.ensureInitialized();
  @override
  $R call({Version? version}) =>
      $apply(FieldCopyWithData({if (version != null) #version: version}));
  @override
  UpdateAvailable $make(CopyWithData data) =>
      UpdateAvailable(version: data.get(#version, or: $value.version));

  @override
  UpdateAvailableCopyWith<$R2, UpdateAvailable, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UpdateAvailableCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

