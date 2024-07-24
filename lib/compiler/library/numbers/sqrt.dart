import 'dart:math';
import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class Sqrt extends NativeFunctionPrototype {
  Sqrt()
      : super(
          name: 'sqrt',
          parameters: [
            Parameter.number('x'),
          ],
        );

  @override
  Reducible bind(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').evaluate();

    if (x is NumberReducibleValue) {
      final num value = sqrt(x.value);
      final num result = (value == value.toInt()) ? value.toInt() : value;
      return NumberReducibleValue(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameters.map((e) => e.type.toString()).toList(),
        actual: [x.type],
      );
    }
  }
}
