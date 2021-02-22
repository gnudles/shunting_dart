import 'package:shunting_dart/src/operator.dart';
import 'package:shunting_dart/src/tokenizer.dart';
import 'package:shunting_dart/src/variable.dart';

import 'func.dart';
import 'token.dart';
import 'value.dart';

enum Brackets { curly, round, square }
var bracketNyms = {
  Brackets.curly: ['{', '}'],
  Brackets.round: ['(', ')'],
  Brackets.square: ['[', ']']
};

class Evaluator {
  bool caseSensitive = true;
  bool enableMultilineMode = true;
  bool allowAssignment;
  bool allowFunctionDefinitions;
  String statementEnding = '\n';
  bool allowArrays = false;
  bool allowMatrices = false;
  Brackets arrayBrackets = Brackets.square;
  Brackets accessBrackets = Brackets.square; //index operator
  String arraySeperator = ',';
  String matrixLineSeperator = ';';
  bool allowMaps = false;
  bool allowSets = false;
  Brackets mapBrackets = Brackets.curly;
  String mapSeperator = ',';
  String mapMatches = ':';
  ValueType mapAllowedKeyType = ValueType.VALUE;
  Brackets functionBrackets = Brackets.round;
  String functionSeperator = ',';
  Brackets expressionBrackets = Brackets.round;
  Brackets controlBlockBrackets = Brackets.curly;
  bool allowStringLiteral = false;
  bool allowComplexNumbers = true;
  String lineComment = '#'; //if null then no comments
  List<Operator> operators;
  Map<String, Variable> variables;
  Map<String, Func> functions;
  ValueFactory valueFactory;
  Evaluator(this.operators, this.variables, this.functions, this.valueFactory,{this.allowArrays = false,this.allowMatrices = false,this.allowMaps = false,this.allowSets = false,this.allowStringLiteral = false}) {
    allowAssignment = operators.any((element) => element.isAssignment);
    if (allowArrays) assert(arrayBrackets != expressionBrackets);

    assert(functions.keys.every((funcName) =>
        Tokenizer.alphanumPattern.matchAsPrefix(funcName).group(0) ==
        funcName));
    assert(variables.keys.every((variName) =>
        Tokenizer.alphanumPattern.matchAsPrefix(variName).group(0) ==
        variName));
  }


  Tokenizer createTokenizer() {
    var nyms = <String>{};
    if (allowMaps) {
      nyms.addAll(bracketNyms[mapBrackets]);
      if (mapSeperator != null) {
        nyms.add(mapSeperator);
      } else {
        throw FormatException();
      }
      if (mapMatches != null) {
        nyms.add(mapMatches);
      } else {
        throw FormatException();
      }
    }
    if (allowArrays) {
      nyms.addAll(bracketNyms[arrayBrackets]);
      if (arraySeperator != null) {
        nyms.add(arraySeperator);
      }
      if (allowMatrices)
      {
        nyms.add(matrixLineSeperator);
      }
    }
    nyms.addAll(bracketNyms[functionBrackets]);
    nyms.addAll(bracketNyms[expressionBrackets]);

    nyms.addAll(operators.map((e) => e.nym));
    if (lineComment != null) {
      //sanity check
      assert(nyms.every((element) => !element.contains(lineComment)));
      assert(
          RegExp(r'^[#/\~\^\!\?%\$\@\*]*$').matchAsPrefix(lineComment) != null);
    }
    if (statementEnding != null) {
      nyms.add(statementEnding);
    }
    if (functionSeperator != null) {
      nyms.add(functionSeperator);
    }
    return Tokenizer(nyms.toList(),
        handleStrings: allowStringLiteral, lineComment: lineComment);
  }
}

/// https://www.andr.mu/logs/the-shunting-yard-algorithm/