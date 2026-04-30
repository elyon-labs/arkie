import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:oxidized/oxidized.dart';

sealed class Async<T extends Object> extends Equatable {
  const Async();

  @override
  List<Object?> get props => [];
}

class Loaded<T extends Object> extends Async<T> {
  const Loaded(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

class Idle<T extends Object> extends Async<T> {
  const Idle();
}

class Loading<T extends Object> extends Async<T> {
  const Loading();
}

class Error<T extends Object> extends Async<T> {
  const Error(this.error);

  final Object error;
}

extension AsyncX<T extends Object> on Async<T> {
  T valueOr(T defaultValue) {
    return switch (this) {
      Loaded(:final value) => value,
      _ => defaultValue,
    };
  }

  R mapOr<R>(R Function(T value) op, R defaultValue) {
    return switch (this) {
      Loaded(:final value) => op(value),
      _ => defaultValue,
    };
  }

  bool get isLoading => this is Loading<T>;

  bool get isError => this is Error<T>;

  bool get isLoaded => this is Loaded<T>;

  T unwrap() {
    return switch (this) {
      Loaded(:final value) => value,
      _ => throw StateError('Cannot unwrap $this'),
    };
  }

  Option<T> get value {
    return switch (this) {
      Loaded(:final value) => Some(value),
      _ => None<T>(),
    };
  }

  Option<Object> get error {
    return switch (this) {
      Error(:final error) => Some(error),
      _ => const None<Object>(),
    };
  }
}

extension AsyncSnapshotX<T extends Object> on AsyncSnapshot<T> {
  Async<T> toAsync() {
    if (hasData) {
      return Loaded(data!);
    }

    if (hasError) {
      return Error(error!);
    }

    return const Loading();
  }
}
