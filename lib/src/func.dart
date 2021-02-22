import 'value.dart';

class Func {
  ValueType returnType = ValueType.ANY;
  List<ValueType> firstArgsTypes = [];
  ValueType optionalsType = ValueType.ANY;
  int numOptionalArgs;
  int get minArgs => firstArgsTypes.length;
  int get maxArgs => firstArgsTypes.length + numOptionalArgs;
  dynamic Function(List<dynamic>) function;
  Func(this.function,{this.firstArgsTypes,this.optionalsType,this.returnType,this.numOptionalArgs});
}
