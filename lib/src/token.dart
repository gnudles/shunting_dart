
import 'operator.dart';

enum TokenType {
  UNKNOWN,
  MAP_BRACKET,
  MAP_MATCH,
  SET_BRACKET,
  ARRAY_BRACKET,
  MATRIX_BRACKET,
  OPEN_BRACKET,
  CLOSE_BRACKET,
  SEPARATOR,
  FUNCTION,
  OPERATOR,
  VARIABLE,
  NUMERIC_LITERAL,
  NUMERIC_COMPLEX_LITERAL,
  STRING_LITERAL
}

class Token {
  int line;
  int column;
  int offset;
  String token;
  TokenType type;
  Operator op;
  Token(this.token,
      {this.line = 0,
      this.column = 0,
      this.offset = 0,
      this.type = TokenType.UNKNOWN});
}
