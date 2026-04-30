// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'app_state.dart';

class AppStateMapper extends ClassMapperBase<AppState> {
  AppStateMapper._();

  static AppStateMapper? _instance;
  static AppStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppStateMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AppState';

  static bool _$isPrivacyModeEnabled(AppState v) => v.isPrivacyModeEnabled;
  static const Field<AppState, bool> _f$isPrivacyModeEnabled = Field(
    'isPrivacyModeEnabled',
    _$isPrivacyModeEnabled,
  );
  static ThemeMode _$themeMode(AppState v) => v.themeMode;
  static const Field<AppState, ThemeMode> _f$themeMode = Field(
    'themeMode',
    _$themeMode,
  );

  @override
  final MappableFields<AppState> fields = const {
    #isPrivacyModeEnabled: _f$isPrivacyModeEnabled,
    #themeMode: _f$themeMode,
  };

  static AppState _instantiate(DecodingData data) {
    return AppState(
      isPrivacyModeEnabled: data.dec(_f$isPrivacyModeEnabled),
      themeMode: data.dec(_f$themeMode),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AppState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppState>(map);
  }

  static AppState fromJson(String json) {
    return ensureInitialized().decodeJson<AppState>(json);
  }
}

mixin AppStateMappable {
  String toJson() {
    return AppStateMapper.ensureInitialized().encodeJson<AppState>(
      this as AppState,
    );
  }

  Map<String, dynamic> toMap() {
    return AppStateMapper.ensureInitialized().encodeMap<AppState>(
      this as AppState,
    );
  }

  AppStateCopyWith<AppState, AppState, AppState> get copyWith =>
      _AppStateCopyWithImpl<AppState, AppState>(
        this as AppState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AppStateMapper.ensureInitialized().stringifyValue(this as AppState);
  }

  @override
  bool operator ==(Object other) {
    return AppStateMapper.ensureInitialized().equalsValue(
      this as AppState,
      other,
    );
  }

  @override
  int get hashCode {
    return AppStateMapper.ensureInitialized().hashValue(this as AppState);
  }
}

extension AppStateValueCopy<$R, $Out> on ObjectCopyWith<$R, AppState, $Out> {
  AppStateCopyWith<$R, AppState, $Out> get $asAppState =>
      $base.as((v, t, t2) => _AppStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AppStateCopyWith<$R, $In extends AppState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({bool? isPrivacyModeEnabled, ThemeMode? themeMode});
  AppStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AppStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AppState, $Out>
    implements AppStateCopyWith<$R, AppState, $Out> {
  _AppStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppState> $mapper =
      AppStateMapper.ensureInitialized();
  @override
  $R call({bool? isPrivacyModeEnabled, ThemeMode? themeMode}) => $apply(
    FieldCopyWithData({
      if (isPrivacyModeEnabled != null)
        #isPrivacyModeEnabled: isPrivacyModeEnabled,
      if (themeMode != null) #themeMode: themeMode,
    }),
  );
  @override
  AppState $make(CopyWithData data) => AppState(
    isPrivacyModeEnabled: data.get(
      #isPrivacyModeEnabled,
      or: $value.isPrivacyModeEnabled,
    ),
    themeMode: data.get(#themeMode, or: $value.themeMode),
  );

  @override
  AppStateCopyWith<$R2, AppState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AppStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

