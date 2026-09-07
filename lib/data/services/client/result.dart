abstract class Result<S, F> {
  T when<T>(T Function(S value) ifSuccess, T Function(F error) ifFailure);

  S? valueOrNull() => when((value) => value, (_) => null);
}

class Success<S, F> extends Result<S, F> {
  Success(this._value);

  final S _value;
  S get value => _value;

  @override
  T when<T>(T Function(S s) ifSuccess, T Function(F f) ifFailure) =>
      ifSuccess(_value);
}

class Failure<S, F> extends Result<S, F> {
  Failure(this._value);

  final F _value;
  F get value => _value;

  @override
  T when<T>(T Function(S s) ifSuccess, T Function(F f) ifFailure) =>
      ifFailure(_value);
}
