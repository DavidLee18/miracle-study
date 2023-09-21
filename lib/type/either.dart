sealed class Either<A,B> {}

class Left<A,B> implements Either<A,B> {
  final A val;

  Left(this.val);
}

class Right<A,B> implements Either<A,B> {
  final B val;

  Right(this.val);
}