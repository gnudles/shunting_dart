import 'package:shunting_dart/shunting_dart.dart';
import 'package:shunting_dart/src/annotator.dart';
import 'package:shunting_dart/src/func.dart';
import 'package:shunting_dart/src/operator.dart';
import 'package:shunting_dart/src/token.dart';
import 'package:shunting_dart/src/tokenizer.dart';
import 'package:shunting_dart/src/value.dart';
import 'package:shunting_dart/src/variable.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    List<Token> out;
    Evaluator ev;
    setUp(() {
      var input = '6+7 -\t3* aaa~/[4.2 *]|6#hello in comment 5 % ...\n5+4i-4e6';
      var nyms = ['+', '-', '^', '*', '%', '/', '~/', '~', '[', ']', '|'];
      Tokenizer tokenizer = Tokenizer(nyms,
          handleStrings: false, lineComment: '#', enableComplexNumbers: true);
      out = tokenizer.tokenize(input);
      print(out.map((e) => '"${e.token.replaceAll('\n', r'\n')}"').toList());

      ev = Evaluator([
        Operator('+', associativity: Associativity.LEFT, precedence: 8),
        Operator('-', associativity: Associativity.LEFT, precedence: 8),
        Operator('-',
            associativity: Associativity.RIGHT,
            precedence: 2,
            operatorType: OperatorType.UNARY),
        Operator('*', associativity: Associativity.LEFT, precedence: 7),
        Operator('/', associativity: Associativity.LEFT, precedence: 7),
        Operator('^', associativity: Associativity.LEFT, precedence: 5),
        Operator.assignment(':='),
      ], {
        'pi': Variable.constant(DoubleValue(3.14))
      }, {
        'sum': Func((args) => args.reduce((value, element) =>
            (value as DoubleValue).value + (element as DoubleValue).value))
      }, DoubleValueFactory(),
          allowArrays: true, allowMaps: true, allowSets: true, allowMatrices: true, allowStringLiteral: true);
      var tokenizer2 = ev.createTokenizer();
      var input2 = '6+7 -\t3* -pi-4e6+{"hi":"hello"}["hi"]+[5,5,3]+[6,9;2,12;3,6]';
      annotate(tokenizer2.tokenize(input2), ev);
    });

    test('First Test', () {
      expect(out[0].token, '6');
      expect(out[1].token, '+');
      expect(out[2].token, '7');
      expect(out[3].token, '-');
      expect(out[4].token, '3');
      expect(out[5].token, '*');
      expect(out[6].token, 'aaa');
      expect(out[7].token, '~/');
    });
  });
}
