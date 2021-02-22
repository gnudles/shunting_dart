import 'token.dart';

class TokenizationException implements Exception {}

class Tokenizer {
  bool handleStrings;
  List<String> nyms;
  Pattern spacesPattern;
  String lineComment;
  Pattern nymsPattern;
  bool enableBinaryBase;
  bool enableOctalBase;
  bool enableHexadecimalBase;
  bool enableFloatingNumbers;
  bool enableComplexNumbers;
  static final Pattern stringPattern = RegExp(r'".*?(?<!\\)"(?![a-z0-9A-Z"])');
  static final Pattern floatPattern =
      RegExp(r'\d+\.\d+\b|\d+(\.\d+)?[eE][+-]?\d+\b');
  static final Pattern integerPattern = RegExp(r'\d+\b');
  static final Pattern complexFloatPattern =
      RegExp(r'\d+\.\d+i\b|\d+(\.\d+)?[eE][+-]?\d+i\b');
  static final Pattern complexIntegerPattern = RegExp(r'\d*i\b');
  static final Pattern hexPattern = RegExp(r'0x[0-9a-fA-F]+\b');
  static final Pattern octPattern = RegExp(r'0c[0-7]+\b');
  static final Pattern binPattern = RegExp(r'0b[01]+\b');
  static final Pattern alphanumPattern = RegExp(
      r'[_a-zA-ZΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθικλμνξοπρστυφχψω][_a-zA-Z0-9]*\b');
  Pattern lineCommentPattern;
  Tokenizer(this.nyms,
      {this.handleStrings = false,
      this.lineComment,
      this.enableFloatingNumbers = true,
      this.enableBinaryBase = false,
      this.enableHexadecimalBase = false,
      this.enableOctalBase = false,
      this.enableComplexNumbers = false}) {
    nyms.sort((a, b) => -a.length.compareTo(b.length));
    nymsPattern =
        RegExp(nyms.map((element) => RegExp.escape(element)).join('|'));
    if (lineComment != null) {
      lineCommentPattern =
          RegExp(RegExp.escape(lineComment) + r'.*$', multiLine: true);
    }

    if (!nyms.contains('\n')) {
      spacesPattern = RegExp(r'[ \n\t\r\f]+');
    } else {
      spacesPattern = RegExp(r'[ \t\r\f]+');
    }
  }
  List<Token> tokenize(String input) {
    var line = 0, column = 0;
    var out = <Token>[];
    var offset = 0;
    var lineOffsets = [0];
    lineOffsets.addAll(input.allMatches('\n').map((e) => e.end));
    lineOffsets.add(input.length + 1);
    while (offset < input.length) {
      Match match;
      var foundMatch = false;
      var skipMatch = false;
      var tokenType = TokenType.UNKNOWN;
      if (lineComment != null &&
          (match = lineCommentPattern.matchAsPrefix(input, offset)) != null) {
        foundMatch = true;
        skipMatch = true;
        print('lineCommentPattern: ${match.group(0)}');
      } else if ((match = spacesPattern.matchAsPrefix(input, offset)) != null) {
        foundMatch = true;
        skipMatch = true;
        print('spacesPattern: ${match.group(0)}');
      } else if ((match = nymsPattern.matchAsPrefix(input, offset)) != null) {
        foundMatch = true;
        print('nymsPattern: ${match.group(0)}');
      } else if (handleStrings &&
          (match = stringPattern.matchAsPrefix(input, offset)) != null) {
        foundMatch = true;
        tokenType = TokenType.STRING_LITERAL;
        print('stringPattern: ${match.group(0)}');
      } else if ((match = floatPattern.matchAsPrefix(input, offset)) != null) {
        foundMatch = true;
        tokenType = TokenType.NUMERIC_LITERAL;
        print('floatPattern: ${match.group(0)}');
      } else if (enableHexadecimalBase &&
          (match = hexPattern.matchAsPrefix(input, offset)) != null) {
        foundMatch = true;
        tokenType = TokenType.NUMERIC_LITERAL;
        print('hexPattern: ${match.group(0)}');
      } else if (enableOctalBase &&
          (match = octPattern.matchAsPrefix(input, offset)) != null) {
        foundMatch = true;
        tokenType = TokenType.NUMERIC_LITERAL;
        print('octPattern: ${match.group(0)}');
      } else if (enableBinaryBase &&
          (match = binPattern.matchAsPrefix(input, offset)) != null) {
        foundMatch = true;
        tokenType = TokenType.NUMERIC_LITERAL;
        print('binPattern: ${match.group(0)}');
      } else if ((match = integerPattern.matchAsPrefix(input, offset)) !=
          null) {
        foundMatch = true;
        tokenType = TokenType.NUMERIC_LITERAL;
        print('integerPattern: ${match.group(0)}');
      } else if (enableComplexNumbers &&
          (match = complexFloatPattern.matchAsPrefix(input, offset)) != null) {
        foundMatch = true;
        tokenType = TokenType.NUMERIC_COMPLEX_LITERAL;
        print('complexFloatPattern: ${match.group(0)}');
      } else if (enableComplexNumbers &&
          (match = complexIntegerPattern.matchAsPrefix(input, offset)) !=
              null) {
        foundMatch = true;
        tokenType = TokenType.NUMERIC_COMPLEX_LITERAL;
        print('complexIntegerPattern: ${match.group(0)}');
      } else if ((match = alphanumPattern.matchAsPrefix(input, offset)) !=
          null) {
        foundMatch = true;
        print('alphanumPattern: ${match.group(0)}');
      }
      if (foundMatch) {
        if (!skipMatch) {
          out.add(Token(match.group(0),
              offset: offset,
              line: line + 1,
              column: column + 1,
              type: tokenType));
          //print(out.last.type);
        }
        offset = match.end;
      } else {
        print(out);
        print(offset);
        print(integerPattern);
        print(input);
        print('handleStrings $handleStrings');
        print(integerPattern.matchAsPrefix(input));
        throw TokenizationException();
      }
      while (lineOffsets[line + 1] <= offset) {
        line++;
      }
      column = offset - lineOffsets[line];
    }
    return out;
  }
}
