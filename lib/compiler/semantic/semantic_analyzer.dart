import 'package:dry/compiler/errors/semantic_error.dart';
import 'package:dry/compiler/library/condition/if.dart';
import 'package:dry/compiler/library/generic/eq.dart';
import 'package:dry/compiler/library/numbers/add.dart';
import 'package:dry/compiler/library/numbers/gt.dart';
import 'package:dry/compiler/library/numbers/mul.dart';
import 'package:dry/compiler/library/numbers/sub.dart';
import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/compiler/warnings/generic_warning.dart';
import 'package:dry/compiler/warnings/semantic_warning.dart';

class SemanticAnalyzer
    extends Analyzer<List<FunctionDefinition>, IntermediateCode> {
  const SemanticAnalyzer(super.input);

  @override
  IntermediateCode analyze() {
    final List<GenericWarning> warnings = [];
    final List<FunctionPrototype> functions = getPrototypes(input);
    addNativeFunctions(functions);

    checkDuplicatedFunctions(functions);
    checkDuplicatedParameters(functions);

    final List<CustomFunctionPrototype> customFunctions =
        functions.whereType<CustomFunctionPrototype>().toList();
    checkReducibles(
      customFunctions: customFunctions,
      allFunctions: functions,
      warnings: warnings,
    );

    // TODO(momo): check mismatched types

    final Map<String, FunctionPrototype> prototypes = {};

    for (final FunctionPrototype function in functions) {
      prototypes[function.name] = function;
    }

    return IntermediateCode(
      functions: prototypes,
      warnings: warnings,
    );
  }

  List<FunctionPrototype> getPrototypes(List<FunctionDefinition> functions) {
    final List<FunctionPrototype> result = [];

    for (final FunctionDefinition function in functions) {
      result.add(CustomFunctionPrototype(
        name: function.name,
        parameters: function.parameters.map(Parameter.any).toList(),
        reducible: function.expression.toReducible(),
      ));
    }

    return result;
  }

  void addNativeFunctions(List<FunctionPrototype> functions) {
    // Generic
    functions.add(Eq());

    // Condition
    functions.add(If());

    // Numbers
    functions.add(Add());
    functions.add(Sub());
    functions.add(Mul());
    functions.add(Gt());
  }

  void checkDuplicatedFunctions(List<FunctionPrototype> functions) {
    for (int i = 0; i < functions.length - 1; i++) {
      final FunctionPrototype function1 = functions[i];

      for (int j = i + 1; j < functions.length; j++) {
        final FunctionPrototype function2 = functions[j];

        if (function1.equalSignature(function2)) {
          throw DuplicatedFunctionError(
            function1: function1,
            function2: function2,
          );
        }
      }
    }
  }

  void checkDuplicatedParameters(List<FunctionPrototype> functions) {
    for (final FunctionPrototype function in functions) {
      final Map<String, int> parameters = parametersCount(function);

      for (final MapEntry<String, int> entry in parameters.entries) {
        if (entry.value > 1) {
          throw DuplicatedParameterError(
            function: function.name,
            parameter: entry.key,
          );
        }
      }
    }
  }

  Map<String, int> parametersCount(FunctionPrototype function) {
    final Map<String, int> result = {};

    for (final Parameter parameter in function.parameters) {
      if (result.containsKey(parameter.name)) {
        result[parameter.name] = result[parameter.name]! + 1;
      } else {
        result[parameter.name] = 1;
      }
    }

    return result;
  }

  void checkReducibles({
    required List<CustomFunctionPrototype> customFunctions,
    required List<FunctionPrototype> allFunctions,
    required List<GenericWarning> warnings,
  }) {
    for (final CustomFunctionPrototype function in customFunctions) {
      final Set<String> usedParameters = {};
      checkReducible(
        reducible: function.reducible,
        availableParameters: function.parameters.map((e) => e.name).toList(),
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );

      for (final Parameter parameter in function.parameters) {
        if (!usedParameters.contains(parameter.name)) {
          warnings.add(UnusedParameterWarning(
            function: function.name,
            parameter: parameter.name,
          ));
        }
      }
    }
  }

  void checkReducible({
    required Reducible reducible,
    required List<String> availableParameters,
    required Set<String> usedParameters,
    required List<FunctionPrototype> allFunctions,
  }) {
    if (reducible is SymbolReducible) {
      if (availableParameters.contains(reducible.value)) {
        usedParameters.add(reducible.value);
      } else if (!allFunctions.any((f) => f.name == reducible.value)) {
        throw UndefinedSymbolError(
          symbol: reducible.value,
          location: reducible.location,
        );
      }
    } else if (reducible is ExpressionReducible) {
      final FunctionPrototype? function = getFunctionByName(
        name: reducible.name,
        functions: allFunctions,
      );

      if (function == null) {
        throw UndefinedFunctionError(
          function: reducible.name,
          location: reducible.location,
        );
      } else {
        if (function.parameters.length != reducible.arguments.length) {
          throw InvalidNumberOfArgumentsError(
            function: reducible.name,
            location: reducible.location,
          );
        }
      }

      for (final Reducible reducible in reducible.arguments) {
        checkReducible(
          reducible: reducible,
          availableParameters: availableParameters,
          usedParameters: usedParameters,
          allFunctions: allFunctions,
        );
      }
    }
  }

  FunctionPrototype? getFunctionByName({
    required String name,
    required List<FunctionPrototype> functions,
  }) {
    try {
      return functions.firstWhere((f) => f.name == name);
    } catch (e) {
      return null;
    }
  }
}
