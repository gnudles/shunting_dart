enum ValueType { BOOL, STRING, VALUE, ARRAY, MAP, ANY, VOID }

abstract class Value {
  bool isBool();
  bool isString();
}

abstract class ValueFactory {
  Value parseValue(String token);
}

class DoubleValue implements Value {
  double value;
  @override
  bool isBool() => false;
  @override
  bool isString() => true;
  DoubleValue(this.value);
  @override
  String toString() {
    return value.toString();
  }
}

class DoubleValueFactory implements ValueFactory {
  @override
  Value parseValue(String token) {
    return DoubleValue(double.parse(token));
  }
}

class ComplexDoubleValue implements Value {
  double real;
  double imag;
  @override
  bool isBool() => false;
  @override
  bool isString() => true;
  ComplexDoubleValue(this.real, this.imag);
  @override
  String toString() {
    return ((real != 0) ? '$real' : '') +
        ((real != 0 && imag != 0) ? '+' : '') +
        ((imag != 0) ? '${imag}i' : '') +
        ((imag == 0 && real == 0) ? '0' : '');
  }
}

class ComplexDoubleValueFactory implements ValueFactory {
  @override
  Value parseValue(String token) {
    if (token == 'i') {
      token = '1i';
    }
    if (token.endsWith('i')) {
      return ComplexDoubleValue(
          0, double.parse(token.substring(0, token.length - 1)));
    }
    return ComplexDoubleValue(double.parse(token), 0);
  }
}
