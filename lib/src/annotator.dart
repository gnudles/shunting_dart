import 'package:shunting_dart/shunting_dart.dart';
import 'package:shunting_dart/src/operator.dart';

import 'func.dart';
import 'token.dart';
import 'tokenizer.dart';

enum LevelStateLabel {
  NONE,
  EXPRESSION_BRACKETS,
  ARRAY_OR_MATRIX_BRACKETS,
  ARRAY_BRACKETS,
  ACCESS_BRACKETS,
  MATRIX_BRACKETS,
  MAP_OR_SET_BRACKETS,
  MAP_BRACKETS,
  SET_BRACKETS,
  FUNCTION_BRACKETS,
}

class LevelState {
  int current = 0;
  int matrixLine = 0;
  Func func;
  LevelStateLabel label;
  Token token;
  LevelState({this.label = LevelStateLabel.NONE, this.func = null, this.token});
}

enum AnnotatorStateLabel {
  SEPERATOR,
  STATEMENT_END,
  LITERAL,
  EXIST_VARIABLE_NAME,
  UNEXIST_VARIABLE_NAME,
  OPEN_EXPRESSION_BRACKETS,
  OPEN_ARRAY_BRACKETS,
  OPEN_ACCESS_BRACKETS,
  OPEN_MAP_BRACKETS,
  LEFT_UNARY_OPERATOR,
  RIGHT_UNARY_OPERATOR,
  BINARY_OPERATOR,
  CLOSE_BRACKETS,
  FUNCTION,
  OPEN_FUNCTION_BRACKETS,
  ASSIGNMENT, //ONLY after first literal that is not read only
  MAP_MATCH,
  MATRIX_LINE_SEPERATOR,
}
enum AssignmentState {
  CLEAR,
  AFTER_WRITABLE_VARIABLE,
  AFTER_ASSIGNMENT_OPERATOR,
  AFTER_UNASSIGNABLE
}
enum MapState {
  NONE,
  KEY,
  VALUE,
}
/*
abstract class AnnotatorState {
  List<AnnotatorStateLabel> possibleNext(LevelState levelState);
  void updateLevelState(List<LevelState> levelStack);
  AssignmentState updateAssignmentState(AssignmentState assignmentState);
}

class AnnotatorStateSeperator implements AnnotatorState {
  @override
  List<AnnotatorStateLabel> possibleNext(LevelState levelState) {
    return [];
  }

  @override
  AssignmentState updateAssignmentState(AssignmentState assignmentState) {
    // TODO: implement updateAssignmentState
    throw UnimplementedError();
  }

  @override
  void updateLevelState(List<LevelState> levelStack) {
    // TODO: implement updateLevelState
  }
}

class AnnotatorStateCloseBrackets implements AnnotatorState {
  @override
  List<AnnotatorStateLabel> possibleNext(LevelState levelState) {
    return [];
  }

  @override
  AssignmentState updateAssignmentState(AssignmentState assignmentState) {
    // TODO: implement updateAssignmentState
    throw UnimplementedError();
  }

  @override
  void updateLevelState(List<LevelState> levelStack) {
    // TODO: implement updateLevelState
  }
}

class AnnotatorStateFunctionOpen implements AnnotatorState {
  @override
  List<AnnotatorStateLabel> possibleNext(LevelState levelState) {
    return [];
  }

  @override
  AssignmentState updateAssignmentState(AssignmentState assignmentState) {
    // TODO: implement updateAssignmentState
    throw UnimplementedError();
  }

  @override
  void updateLevelState(List<LevelState> levelStack) {
    // TODO: implement updateLevelState
  }
}

class AnnotatorStateFunctionName implements AnnotatorState {
  @override
  List<AnnotatorStateLabel> possibleNext(LevelState levelState) {
    return [];
  }

  @override
  AssignmentState updateAssignmentState(AssignmentState assignmentState) {
    // TODO: implement updateAssignmentState
    throw UnimplementedError();
  }

  @override
  void updateLevelState(List<LevelState> levelStack) {
    // TODO: implement updateLevelState
  }
}

class AnnotatorStateOperator implements AnnotatorState {
  @override
  List<AnnotatorStateLabel> possibleNext(LevelState levelState) {
    return [];
  }

  @override
  AssignmentState updateAssignmentState(AssignmentState assignmentState) {
    // TODO: implement updateAssignmentState
    throw UnimplementedError();
  }

  @override
  void updateLevelState(List<LevelState> levelStack) {
    // TODO: implement updateLevelState
  }
}

class AnnotatorStateAssignment implements AnnotatorState {
  @override
  List<AnnotatorStateLabel> possibleNext(LevelState levelState) {
    return [];
  }

  @override
  AssignmentState updateAssignmentState(AssignmentState assignmentState) {
    // TODO: implement updateAssignmentState
    throw UnimplementedError();
  }

  @override
  void updateLevelState(List<LevelState> levelStack) {
    // TODO: implement updateLevelState
  }
}

class AnnotatorStateEndStatement implements AnnotatorState {
  @override
  List<AnnotatorStateLabel> possibleNext(LevelState levelState) {
    return [];
  }

  @override
  AssignmentState updateAssignmentState(AssignmentState assignmentState) {
    // TODO: implement updateAssignmentState
    throw UnimplementedError();
  }

  @override
  void updateLevelState(List<LevelState> levelStack) {
    // TODO: implement updateLevelState
  }
}

class AnnotatorStateLiteral implements AnnotatorState {
  @override
  List<AnnotatorStateLabel> possibleNext(LevelState levelState) {
    var out = [];
    if (levelState != LevelStateLabel.NONE) {
      out.addAll([]);
    }
  }

  @override
  AssignmentState updateAssignmentState(AssignmentState assignmentState) {
    // TODO: implement updateAssignmentState
    throw UnimplementedError();
  }

  @override
  void updateLevelState(List<LevelState> levelStack) {
    // TODO: implement updateLevelState
  }
}
*/

void annotate(List<Token> tokens, Evaluator evaluator) {
  var levelState = <LevelState>[LevelState()];
  var mapState = <MapState>[MapState.NONE];
  var assignmentState = <AssignmentState>[AssignmentState.CLEAR];

  //levelState.last
  var stateMapNext = <AnnotatorStateLabel, List<AnnotatorStateLabel>>{
    AnnotatorStateLabel.SEPERATOR: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      AnnotatorStateLabel.UNEXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS,
      AnnotatorStateLabel.OPEN_ARRAY_BRACKETS,
      AnnotatorStateLabel.OPEN_MAP_BRACKETS
    ],
    AnnotatorStateLabel.MATRIX_LINE_SEPERATOR: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      AnnotatorStateLabel.UNEXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS,
      AnnotatorStateLabel.OPEN_ARRAY_BRACKETS,
      AnnotatorStateLabel.OPEN_MAP_BRACKETS
    ],
    AnnotatorStateLabel.STATEMENT_END: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      AnnotatorStateLabel.UNEXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS,
      AnnotatorStateLabel.OPEN_ARRAY_BRACKETS,
      AnnotatorStateLabel.OPEN_MAP_BRACKETS
    ],
    AnnotatorStateLabel.EXIST_VARIABLE_NAME: [
      AnnotatorStateLabel.SEPERATOR, //not always possible
      AnnotatorStateLabel.MAP_MATCH, //not always possible
      AnnotatorStateLabel.MATRIX_LINE_SEPERATOR, //not always possible
      AnnotatorStateLabel.STATEMENT_END, //not always possible
      AnnotatorStateLabel.RIGHT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_ACCESS_BRACKETS,
      AnnotatorStateLabel.CLOSE_BRACKETS, //not always possible
      AnnotatorStateLabel.BINARY_OPERATOR,
    ],
    AnnotatorStateLabel.UNEXIST_VARIABLE_NAME: [
      AnnotatorStateLabel.ASSIGNMENT, //not always possible
    ],
    AnnotatorStateLabel.LITERAL: [
      AnnotatorStateLabel.SEPERATOR, //not always possible
      AnnotatorStateLabel.MAP_MATCH, //not always possible
      AnnotatorStateLabel.MATRIX_LINE_SEPERATOR, //not always possible
      AnnotatorStateLabel.STATEMENT_END, //not always possible
      AnnotatorStateLabel.RIGHT_UNARY_OPERATOR,
      AnnotatorStateLabel.CLOSE_BRACKETS, //not always possible
      AnnotatorStateLabel.BINARY_OPERATOR,
    ],
    AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      AnnotatorStateLabel.UNEXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS,
      AnnotatorStateLabel.OPEN_ARRAY_BRACKETS,
      AnnotatorStateLabel.OPEN_MAP_BRACKETS
    ],
    AnnotatorStateLabel.OPEN_ARRAY_BRACKETS: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      AnnotatorStateLabel.UNEXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS,
      AnnotatorStateLabel.OPEN_ARRAY_BRACKETS,
      AnnotatorStateLabel.OPEN_MAP_BRACKETS
    ],
    AnnotatorStateLabel.OPEN_MAP_BRACKETS: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS
    ],
    AnnotatorStateLabel.BINARY_OPERATOR: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS,
      AnnotatorStateLabel.OPEN_ARRAY_BRACKETS,
      AnnotatorStateLabel.OPEN_MAP_BRACKETS
    ],
    AnnotatorStateLabel.LEFT_UNARY_OPERATOR: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS,
      AnnotatorStateLabel.OPEN_ARRAY_BRACKETS,
      AnnotatorStateLabel.OPEN_MAP_BRACKETS,
    ],
    AnnotatorStateLabel.RIGHT_UNARY_OPERATOR: [
      AnnotatorStateLabel.SEPERATOR, //not always possible
      AnnotatorStateLabel.MAP_MATCH, //not always possible
      AnnotatorStateLabel.MATRIX_LINE_SEPERATOR, //not always possible
      AnnotatorStateLabel.STATEMENT_END, //not always possible
      AnnotatorStateLabel.RIGHT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_ACCESS_BRACKETS,
      AnnotatorStateLabel.CLOSE_BRACKETS, //not always possible
      AnnotatorStateLabel.BINARY_OPERATOR,
    ],
    AnnotatorStateLabel.OPEN_ACCESS_BRACKETS: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS
    ],
    AnnotatorStateLabel.CLOSE_BRACKETS: [
      AnnotatorStateLabel.ASSIGNMENT, //not always possible
      AnnotatorStateLabel.SEPERATOR, //not always possible
      AnnotatorStateLabel.MAP_MATCH, //not always possible
      AnnotatorStateLabel.MATRIX_LINE_SEPERATOR, //not always possible
      AnnotatorStateLabel.STATEMENT_END, //not always possible
      AnnotatorStateLabel.RIGHT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_ACCESS_BRACKETS,
      AnnotatorStateLabel.CLOSE_BRACKETS, //not always possible
      AnnotatorStateLabel.BINARY_OPERATOR,
    ],
    AnnotatorStateLabel.FUNCTION: [
      AnnotatorStateLabel.OPEN_FUNCTION_BRACKETS,
    ],
    AnnotatorStateLabel.OPEN_FUNCTION_BRACKETS: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      //AnnotatorStateLabel.UNEXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS,
      AnnotatorStateLabel.OPEN_ARRAY_BRACKETS,
      AnnotatorStateLabel.OPEN_MAP_BRACKETS,
    ],
    AnnotatorStateLabel.ASSIGNMENT: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS,
      AnnotatorStateLabel.OPEN_ARRAY_BRACKETS,
      AnnotatorStateLabel.OPEN_MAP_BRACKETS,
    ],
    AnnotatorStateLabel.MAP_MATCH: [
      AnnotatorStateLabel.LITERAL,
      AnnotatorStateLabel.EXIST_VARIABLE_NAME,
      AnnotatorStateLabel.FUNCTION,
      AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
      AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS,
      AnnotatorStateLabel.OPEN_ARRAY_BRACKETS,
      AnnotatorStateLabel.OPEN_MAP_BRACKETS,
    ]
  };
  var currentState = AnnotatorStateLabel.STATEMENT_END;
  var stateIsValidNow = {
    AnnotatorStateLabel.SEPERATOR: () =>
        (levelState.last.label == LevelStateLabel.MAP_OR_SET_BRACKETS) ||
        (levelState.last.label == LevelStateLabel.MAP_BRACKETS &&
            mapState.last == MapState.VALUE) ||
        (levelState.last.label == LevelStateLabel.ARRAY_BRACKETS) ||
        (levelState.last.label == LevelStateLabel.ARRAY_OR_MATRIX_BRACKETS) ||
        (levelState.last.label == LevelStateLabel.EXPRESSION_BRACKETS &&
            false) ||
        (levelState.last.label == LevelStateLabel.FUNCTION_BRACKETS &&
            levelState.last.current + 1 < levelState.last.func.maxArgs) ||
        (levelState.last.label == LevelStateLabel.SET_BRACKETS) ||
        (levelState.last.label == LevelStateLabel.MATRIX_BRACKETS &&
            ((levelState.last.current + 1) % levelState.last.matrixLine) != 0),

    AnnotatorStateLabel.MATRIX_LINE_SEPERATOR: () =>
        (levelState.last.label == LevelStateLabel.ARRAY_OR_MATRIX_BRACKETS) ||
        (levelState.last.label == LevelStateLabel.MATRIX_BRACKETS &&
            ((levelState.last.current + 1) % levelState.last.matrixLine) == 0),
    AnnotatorStateLabel.STATEMENT_END: () =>
        levelState.last.label == LevelStateLabel.NONE,
    AnnotatorStateLabel.OPEN_ACCESS_BRACKETS: () =>
        (levelState.last.label != LevelStateLabel.SET_BRACKETS),
    AnnotatorStateLabel.LITERAL: () => true,
    AnnotatorStateLabel.EXIST_VARIABLE_NAME: () => true,
    AnnotatorStateLabel.UNEXIST_VARIABLE_NAME: () =>
        assignmentState.last == AssignmentState.CLEAR,
    AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS: () => true,
    AnnotatorStateLabel.OPEN_ARRAY_BRACKETS: () => true,
    AnnotatorStateLabel.OPEN_MAP_BRACKETS: () => true,
    AnnotatorStateLabel.LEFT_UNARY_OPERATOR: () => true,
    AnnotatorStateLabel.RIGHT_UNARY_OPERATOR: () => true,
    AnnotatorStateLabel.BINARY_OPERATOR: () => true,
    AnnotatorStateLabel.CLOSE_BRACKETS: () =>
        (levelState.last.label == LevelStateLabel.FUNCTION_BRACKETS &&
            levelState.last.current + 1 >= levelState.last.func.minArgs) ||
        (levelState.last.label == LevelStateLabel.MATRIX_BRACKETS &&
            ((levelState.last.current + 1) % levelState.last.matrixLine) ==
                0) ||
        (levelState.last.label != LevelStateLabel.FUNCTION_BRACKETS &&
            levelState.last.label != LevelStateLabel.MATRIX_BRACKETS &&
            levelState.last.label != LevelStateLabel.NONE),
    AnnotatorStateLabel.FUNCTION: () => true,
    AnnotatorStateLabel.OPEN_FUNCTION_BRACKETS: () => true,
    AnnotatorStateLabel.ASSIGNMENT: () =>
        assignmentState.last == AssignmentState.AFTER_WRITABLE_VARIABLE &&
        mapState.last !=
            MapState.KEY, //ONLY after first literal that is not read only
    AnnotatorStateLabel.MAP_MATCH: () =>
        (levelState.last.label == LevelStateLabel.MAP_OR_SET_BRACKETS ||
            levelState.last.label == LevelStateLabel.MAP_BRACKETS) &&
        mapState.last == MapState.KEY,
  };
  var newVariables = <String>[];
  var newFunctions = <String>[];
  var tokenFit = {
    AnnotatorStateLabel.SEPERATOR: (Token token) => [
          evaluator.arraySeperator,
          evaluator.functionSeperator,
          evaluator.mapSeperator
        ].contains(token.token),
    AnnotatorStateLabel.STATEMENT_END: (Token token) =>
        (token.token == evaluator.statementEnding),
    AnnotatorStateLabel.LITERAL: (Token token) => [
          TokenType.NUMERIC_COMPLEX_LITERAL,
          TokenType.NUMERIC_LITERAL,
          TokenType.STRING_LITERAL
        ].contains(token.type),
    AnnotatorStateLabel.EXIST_VARIABLE_NAME: (Token token) =>
        evaluator.caseSensitive
            ? newVariables.contains(token.token) ||
                evaluator.variables.containsKey(token.token)
            : newVariables.any((element) =>
                    element.toLowerCase() == token.token.toLowerCase()) ||
                evaluator.variables.keys.any((element) =>
                    element.toLowerCase() == token.token.toLowerCase()),
    AnnotatorStateLabel.UNEXIST_VARIABLE_NAME: (Token token) {
      var match = Tokenizer.alphanumPattern.matchAsPrefix(token.token);
      if (match!=null &&  match.group(0)== token.token) {
        return evaluator.caseSensitive
            ? !newVariables.contains(token.token) &&
                !evaluator.variables.containsKey(token.token)
            : !newVariables.any((element) =>
                    element.toLowerCase() == token.token.toLowerCase()) &&
                !evaluator.variables.keys.any((element) =>
                    element.toLowerCase() == token.token.toLowerCase());
      }
      return false;
    },
    AnnotatorStateLabel.OPEN_ACCESS_BRACKETS: (Token token) =>
        token.token == bracketNyms[evaluator.accessBrackets][0],
    AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS: (Token token) =>
        token.token == bracketNyms[evaluator.expressionBrackets][0],
    AnnotatorStateLabel.OPEN_ARRAY_BRACKETS: (Token token) =>
        token.token == bracketNyms[evaluator.arrayBrackets][0],
    AnnotatorStateLabel.OPEN_MAP_BRACKETS: (Token token) =>
        token.token == bracketNyms[evaluator.mapBrackets][0],
    AnnotatorStateLabel.LEFT_UNARY_OPERATOR: (Token token) =>
        evaluator.operators.firstWhere(
            (op) =>
                op.operatorType == OperatorType.UNARY &&
                op.associativity == Associativity.RIGHT &&
                op.nym == token.token,
            orElse: () => null),
    AnnotatorStateLabel.RIGHT_UNARY_OPERATOR: (Token token) =>
        evaluator.operators.firstWhere(
            (op) =>
                op.operatorType == OperatorType.UNARY &&
                op.associativity == Associativity.LEFT &&
                op.nym == token.token,
            orElse: () => null),
    AnnotatorStateLabel.BINARY_OPERATOR: (Token token) => evaluator.operators
        .firstWhere(
            (op) =>
                op.operatorType == OperatorType.BINARY && op.nym == token.token,
            orElse: () => null),
    AnnotatorStateLabel.CLOSE_BRACKETS: (Token token) =>
        (levelState.last.label == LevelStateLabel.FUNCTION_BRACKETS &&
            token.token == bracketNyms[evaluator.functionBrackets][1]) ||
        (levelState.last.label == LevelStateLabel.EXPRESSION_BRACKETS &&
            token.token == bracketNyms[evaluator.expressionBrackets][1]) ||
        ((levelState.last.label == LevelStateLabel.ARRAY_OR_MATRIX_BRACKETS ||
                levelState.last.label == LevelStateLabel.ARRAY_BRACKETS ||
                levelState.last.label == LevelStateLabel.MATRIX_BRACKETS) &&
            token.token == bracketNyms[evaluator.arrayBrackets][1]) ||
        ((levelState.last.label == LevelStateLabel.MAP_OR_SET_BRACKETS ||
                levelState.last.label == LevelStateLabel.MAP_BRACKETS ||
                levelState.last.label == LevelStateLabel.SET_BRACKETS) &&
            token.token == bracketNyms[evaluator.mapBrackets][1]) ||
        (levelState.last.label == LevelStateLabel.ACCESS_BRACKETS &&
            token.token == bracketNyms[evaluator.accessBrackets][1]),
    AnnotatorStateLabel.FUNCTION: (Token token) => evaluator.caseSensitive
        ? newFunctions.contains(token.token) ||
            evaluator.functions.containsKey(token.token)
        : newFunctions.any((element) =>
                element.toLowerCase() == token.token.toLowerCase()) ||
            evaluator.functions.keys.any((element) =>
                element.toLowerCase() == token.token.toLowerCase()),
    AnnotatorStateLabel.OPEN_FUNCTION_BRACKETS: (Token token) =>
        token.token == bracketNyms[evaluator.functionBrackets][0],
    AnnotatorStateLabel.ASSIGNMENT: (Token token) => evaluator.operators.any(
        (op) =>
            op.isAssignment &&
            op.nym ==
                token.token), //ONLY after first literal that is not read only
    AnnotatorStateLabel.MAP_MATCH: (Token token) =>
        token.token == evaluator.mapMatches,
    AnnotatorStateLabel.MATRIX_LINE_SEPERATOR: (Token token) =>
        token.token == evaluator.matrixLineSeperator,
  };

  var changeState = {
    AnnotatorStateLabel.SEPERATOR: (Token token) {
      levelState.last.current++;
      if (levelState.last.label == LevelStateLabel.MAP_OR_SET_BRACKETS &&
          mapState.last == MapState.KEY) {
        levelState.last.label = LevelStateLabel.SET_BRACKETS;
        mapState.removeLast();
      }
      if (levelState.last.label == LevelStateLabel.MAP_BRACKETS &&
          mapState.last == MapState.VALUE) {
        mapState.last = MapState.KEY;
      }
      assignmentState.last = AssignmentState.CLEAR;
    },
    AnnotatorStateLabel.STATEMENT_END: (Token token) =>
        assignmentState.last = AssignmentState.CLEAR,
    AnnotatorStateLabel.LITERAL: (Token token) {
      if (assignmentState.last != AssignmentState.AFTER_ASSIGNMENT_OPERATOR) {
        assignmentState.last = AssignmentState.AFTER_UNASSIGNABLE;
      }
    },
    AnnotatorStateLabel.EXIST_VARIABLE_NAME: (Token token) {
      if (assignmentState.last == AssignmentState.CLEAR) {
        assignmentState.last = AssignmentState.AFTER_WRITABLE_VARIABLE;
      } else {
        assignmentState.last = AssignmentState.AFTER_UNASSIGNABLE;
      }
    },
    AnnotatorStateLabel.UNEXIST_VARIABLE_NAME: (Token token) {
      assignmentState.last = AssignmentState.AFTER_WRITABLE_VARIABLE;
    },
    AnnotatorStateLabel.OPEN_EXPRESSION_BRACKETS: (Token token) {
      levelState.add(
          LevelState(label: LevelStateLabel.EXPRESSION_BRACKETS, token: token));
      assignmentState.add(AssignmentState.CLEAR);
    },
    AnnotatorStateLabel.OPEN_ARRAY_BRACKETS: (Token token) {
      levelState.add(LevelState(
          label: evaluator.allowMatrices
              ? LevelStateLabel.ARRAY_OR_MATRIX_BRACKETS
              : LevelStateLabel.ARRAY_BRACKETS,
          token: token));
      assignmentState.add(AssignmentState.CLEAR);
    },
    AnnotatorStateLabel.OPEN_MAP_BRACKETS: (Token token) {
      levelState.add(
          LevelState(label: LevelStateLabel.MAP_OR_SET_BRACKETS, token: token));
      mapState.add(MapState.KEY);
      assignmentState.add(AssignmentState.CLEAR);
    },
    AnnotatorStateLabel.OPEN_ACCESS_BRACKETS: (Token token) {
      levelState.add(
          LevelState(label: LevelStateLabel.ACCESS_BRACKETS, token: token));
      assignmentState.add(AssignmentState.CLEAR);
    },
    AnnotatorStateLabel.LEFT_UNARY_OPERATOR: (Token token) {
      if (assignmentState.last != AssignmentState.AFTER_ASSIGNMENT_OPERATOR) {
        assignmentState.last = AssignmentState.AFTER_UNASSIGNABLE;
      }
    },
    AnnotatorStateLabel.RIGHT_UNARY_OPERATOR: (Token token) {
      if (assignmentState.last != AssignmentState.AFTER_ASSIGNMENT_OPERATOR) {
        assignmentState.last = AssignmentState.AFTER_UNASSIGNABLE;
      }
    },
    AnnotatorStateLabel.BINARY_OPERATOR: (Token token) {
      if (assignmentState.last != AssignmentState.AFTER_ASSIGNMENT_OPERATOR) {
        assignmentState.last = AssignmentState.AFTER_UNASSIGNABLE;
      }
    },
    AnnotatorStateLabel.CLOSE_BRACKETS: (Token token) {
      if (levelState.last.label == LevelStateLabel.ARRAY_OR_MATRIX_BRACKETS) {
        levelState.last.label = LevelStateLabel.ARRAY_BRACKETS;
        levelState.last.token.type = TokenType.ARRAY_BRACKET;
      }
      if (levelState.last.label == LevelStateLabel.MAP_OR_SET_BRACKETS ||
          levelState.last.label == LevelStateLabel.MAP_BRACKETS) {
        mapState.removeLast();
      }
      assignmentState.removeLast();
      var lastLevelState = levelState.removeLast();
      if (lastLevelState.label != LevelStateLabel.ACCESS_BRACKETS) {
        assignmentState.last = AssignmentState.AFTER_UNASSIGNABLE;
      }
    },
    AnnotatorStateLabel.FUNCTION: (Token token) => null,
    AnnotatorStateLabel.OPEN_FUNCTION_BRACKETS: (Token token) {
      levelState.add(
          LevelState(label: LevelStateLabel.FUNCTION_BRACKETS, token: token));
      assignmentState.add(AssignmentState.CLEAR);
    },
    AnnotatorStateLabel.ASSIGNMENT: (Token token) {
      assignmentState.last = AssignmentState.AFTER_ASSIGNMENT_OPERATOR;
    }, //ONLY after first literal that is not read only
    AnnotatorStateLabel.MAP_MATCH: (Token token) {
      levelState.last.current++;
      if (levelState.last.label == LevelStateLabel.MAP_OR_SET_BRACKETS) {
        levelState.last.label = LevelStateLabel.MAP_BRACKETS;
      }
      if (levelState.last.label == LevelStateLabel.MAP_BRACKETS &&
          mapState.last == MapState.KEY) {
        mapState.last = MapState.VALUE;
      }
    },
    AnnotatorStateLabel.MATRIX_LINE_SEPERATOR: (Token token) {
      levelState.last.current++;
      if (levelState.last.matrixLine == 0) {
        levelState.last.matrixLine = levelState.last.current;
      }
      if (levelState.last.label == LevelStateLabel.ARRAY_OR_MATRIX_BRACKETS) {
        levelState.last.label = LevelStateLabel.MATRIX_BRACKETS;
        levelState.last.token.type = TokenType.MATRIX_BRACKET;
      }
      if (levelState.last.label == LevelStateLabel.MAP_BRACKETS &&
          mapState.last == MapState.VALUE) {
        mapState.last = MapState.KEY;
      }
    },
  };

  var forbiddenStates = <AnnotatorStateLabel>[];
  if (!evaluator.allowAssignment) {
    forbiddenStates.add(AnnotatorStateLabel.UNEXIST_VARIABLE_NAME);
    forbiddenStates.add(AnnotatorStateLabel.ASSIGNMENT);
  }
  if (!evaluator.allowMatrices) {
    forbiddenStates.add(AnnotatorStateLabel.MATRIX_LINE_SEPERATOR);
  }
  if (!evaluator.allowMaps) {
    forbiddenStates.add(AnnotatorStateLabel.MAP_MATCH);
  }
  if (!evaluator.allowMaps && !evaluator.allowSets) {
    forbiddenStates.add(AnnotatorStateLabel.OPEN_MAP_BRACKETS);
  }
  if (!evaluator.allowArrays && !evaluator.allowMatrices) {
    forbiddenStates.add(AnnotatorStateLabel.OPEN_ARRAY_BRACKETS);
  }
  if (!evaluator.allowArrays &&
      !evaluator.allowMatrices &&
      !evaluator.allowMaps) {
    forbiddenStates.add(AnnotatorStateLabel.OPEN_ACCESS_BRACKETS);
  }
  for (var t in tokens) {
    var possibleStates = stateMapNext[currentState];
    var found = false;
    for (var newState in possibleStates) {
      if (!forbiddenStates.contains(newState) && stateIsValidNow[newState]()) {
        var fit = tokenFit[newState](t);
        if ((fit != null && !(fit is bool)) || fit == true) {
          changeState[newState](t);
          print(newState);
          currentState = newState;
          if ([
            AnnotatorStateLabel.BINARY_OPERATOR,
            AnnotatorStateLabel.LEFT_UNARY_OPERATOR,
            AnnotatorStateLabel.RIGHT_UNARY_OPERATOR,
          ].contains(newState)) {
            t.op = fit; // fill-in the operator of token with what we found
          }
          found = true;
          break;
        }
      }
    }
    if (!found) {
      print('no match for: ${t.token}');
      break;
    }
  }
}
