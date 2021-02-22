import 'value.dart';

class Variable {
  bool readOnly = true;
  
  bool isConstant ; // for pi & e. not for x,y
  dynamic value; //either Value or Map<Value,Value> or List<Value>
  Variable.constant(this.value){isConstant = true; readOnly = true;}
  Variable(this.value){isConstant = false; readOnly = true;}
  Variable.writeable(this.value){isConstant = false; readOnly = false;}
  
}
