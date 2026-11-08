// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'app_version_state.dart';

class AppVersionStateMapper extends ClassMapperBase<AppVersionState> {
  AppVersionStateMapper._();

  static AppVersionStateMapper? _instance;
  static AppVersionStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppVersionStateMapper._());
      _t$_R0Mapper.ensureInitialized();
      UpdateStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AppVersionState';

  static Result<VersionInfo, Exception> _$appVersion(AppVersionState v) =>
      v.appVersion;
  static const Field<AppVersionState, Result<VersionInfo, Exception>>
  _f$appVersion = Field('appVersion', _$appVersion);
  static Async<UpdateStatus> _$updateStatus(AppVersionState v) =>
      v.updateStatus;
  static const Field<AppVersionState, Async<UpdateStatus>> _f$updateStatus =
      Field('updateStatus', _$updateStatus);

  @override
  final MappableFields<AppVersionState> fields = const {
    #appVersion: _f$appVersion,
    #updateStatus: _f$updateStatus,
  };

  static AppVersionState _instantiate(DecodingData data) {
    return AppVersionState(
      appVersion: data.dec(_f$appVersion),
      updateStatus: data.dec(_f$updateStatus),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AppVersionState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppVersionState>(map);
  }

  static AppVersionState fromJson(String json) {
    return ensureInitialized().decodeJson<AppVersionState>(json);
  }
}

mixin AppVersionStateMappable {
  String toJson() {
    return AppVersionStateMapper.ensureInitialized()
        .encodeJson<AppVersionState>(this as AppVersionState);
  }

  Map<String, dynamic> toMap() {
    return AppVersionStateMapper.ensureInitialized().encodeMap<AppVersionState>(
      this as AppVersionState,
    );
  }

  AppVersionStateCopyWith<AppVersionState, AppVersionState, AppVersionState>
  get copyWith =>
      _AppVersionStateCopyWithImpl<AppVersionState, AppVersionState>(
        this as AppVersionState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AppVersionStateMapper.ensureInitialized().stringifyValue(
      this as AppVersionState,
    );
  }

  @override
  bool operator ==(Object other) {
    return AppVersionStateMapper.ensureInitialized().equalsValue(
      this as AppVersionState,
      other,
    );
  }

  @override
  int get hashCode {
    return AppVersionStateMapper.ensureInitialized().hashValue(
      this as AppVersionState,
    );
  }
}

extension AppVersionStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AppVersionState, $Out> {
  AppVersionStateCopyWith<$R, AppVersionState, $Out> get $asAppVersionState =>
      $base.as((v, t, t2) => _AppVersionStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AppVersionStateCopyWith<$R, $In extends AppVersionState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    Result<VersionInfo, Exception>? appVersion,
    Async<UpdateStatus>? updateStatus,
  });
  AppVersionStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AppVersionStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AppVersionState, $Out>
    implements AppVersionStateCopyWith<$R, AppVersionState, $Out> {
  _AppVersionStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppVersionState> $mapper =
      AppVersionStateMapper.ensureInitialized();
  @override
  $R call({
    Result<VersionInfo, Exception>? appVersion,
    Async<UpdateStatus>? updateStatus,
  }) => $apply(
    FieldCopyWithData({
      if (appVersion != null) #appVersion: appVersion,
      if (updateStatus != null) #updateStatus: updateStatus,
    }),
  );
  @override
  AppVersionState $make(CopyWithData data) => AppVersionState(
    appVersion: data.get(#appVersion, or: $value.appVersion),
    updateStatus: data.get(#updateStatus, or: $value.updateStatus),
  );

  @override
  AppVersionStateCopyWith<$R2, AppVersionState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AppVersionStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

typedef _t$_R0<A, B> = ({A buildNumber, B version});

class _t$_R0Mapper extends RecordMapperBase<_t$_R0> {
  static _t$_R0Mapper? _instance;
  _t$_R0Mapper._();

  static _t$_R0Mapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = _t$_R0Mapper._());
      MapperBase.addType(<A, B>(f) => f<({A buildNumber, B version})>());
    }
    return _instance!;
  }

  static dynamic _$buildNumber(_t$_R0 v) => v.buildNumber;
  static dynamic _arg$buildNumber<A, B>(f) => f<A>();
  static const Field<_t$_R0, dynamic> _f$buildNumber = Field(
    'buildNumber',
    _$buildNumber,
    arg: _arg$buildNumber,
  );
  static dynamic _$version(_t$_R0 v) => v.version;
  static dynamic _arg$version<A, B>(f) => f<B>();
  static const Field<_t$_R0, dynamic> _f$version = Field(
    'version',
    _$version,
    arg: _arg$version,
  );

  @override
  final MappableFields<_t$_R0> fields = const {
    #buildNumber: _f$buildNumber,
    #version: _f$version,
  };

  @override
  Function get typeFactory =>
      <A, B>(f) => f<_t$_R0<A, B>>();

  static _t$_R0<A, B> _instantiate<A, B>(DecodingData<_t$_R0> data) {
    return (
      buildNumber: data.dec(_f$buildNumber),
      version: data.dec(_f$version),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static _t$_R0<A, B> fromMap<A, B>(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<_t$_R0<A, B>>(map);
  }

  static _t$_R0<A, B> fromJson<A, B>(String json) {
    return ensureInitialized().decodeJson<_t$_R0<A, B>>(json);
  }
}

