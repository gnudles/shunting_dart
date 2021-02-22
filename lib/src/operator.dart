import 'package:meta/meta.dart';

enum Associativity {
  /// Left associativity
  LEFT,

  /// Right associativity
  RIGHT,
}
enum OperatorType {
  /// unary
  UNARY, //UNARY with right associativty is PREFIX, UNARY with left associativty is POSTFIX, 

  /// binary
  BINARY,
}

class Operator {
  Associativity associativity;
  String nym;
  String description;
  int precedence;
  OperatorType operatorType;
  bool isAssignment = false;
  Operator(this.nym,
      {@required this.associativity,
      @required this.precedence,
      this.description,
      this.operatorType = OperatorType.BINARY});
  Operator.assignment(this.nym) {
    associativity = Associativity.RIGHT;
    precedence = -1;
    isAssignment = true;
    description = 'Assignment Operator';
    operatorType = OperatorType.BINARY;
  }
}
