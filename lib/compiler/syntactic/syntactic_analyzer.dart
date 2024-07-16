import 'package:dry/compiler/errors/syntactic_error.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/models/state.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/utils/list_iterator.dart';

class SyntacticAnalyzer
    extends Analyzer<List<Token>, List<FunctionDefinition>> {
  const SyntacticAnalyzer(super.tokens);

  @override
  List<FunctionDefinition> analyze() {
    final List<FunctionDefinition> result = [];
    final ListIterator<Token> iterator = ListIterator(input);
    State state = InitState.empty();

    while (iterator.hasNext) {
      state = state.process(iterator.next);

      if (state is ResultState) {
        result.addAll(state.output);
        state = InitState.empty();
      }
    }

    return result;
  }
}

class InitState extends State<Token, void> {
  const InitState(super.output);

  factory InitState.empty() => const InitState(null);

  @override
  State process(Token input) {
    if (input.type.isSymbol) {
      return FunctionNameState(FunctionDefinition.fromName(input.asString));
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class FunctionNameState extends State<Token, FunctionDefinition> {
  const FunctionNameState(super.output);

  @override
  State process(Token input) {
    if (input.type.isEquals) {
      return FunctionEqualsState(output);
    } else if (input.type.isOpenParenthesis) {
      return FunctionWithParametersState(output);
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class FunctionWithParametersState extends State<Token, FunctionDefinition> {
  const FunctionWithParametersState(super.output);

  @override
  State process(Token input) {
    if (input.type.isSymbol) {
      return FunctionWithNextParametersState(
          output.withParameter(input.asString));
    } else if (input.type.isCloseParenthesis) {
      if (output.parameters.isEmpty) {
        throw SyntacticError.invalidToken(input);
      }

      return FunctionParametrizedState(output);
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class FunctionWithNextParametersState extends State<Token, FunctionDefinition> {
  const FunctionWithNextParametersState(super.output);

  @override
  State process(Token input) {
    if (input.type.isComma) {
      return FunctionWithParametersState(output);
    } else if (input.type.isCloseParenthesis) {
      return FunctionParametrizedState(output);
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class FunctionParametrizedState extends State<Token, FunctionDefinition> {
  const FunctionParametrizedState(super.output);

  @override
  State process(Token input) {
    if (input.type.isEquals) {
      return FunctionEqualsState(output);
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class FunctionEqualsState extends State<Token, FunctionDefinition> {
  const FunctionEqualsState(super.output);

  @override
  State process(Token input) {
    if (input.type.isString) {
      return ResultState(
          [output.withExpression(LiteralExpression.string(input.asString))]);
    } else if (input.type.isNumber) {
      return ResultState(
          [output.withExpression(LiteralExpression.number(input.asNumber))]);
    } else if (input.type.isBoolean) {
      return ResultState(
          [output.withExpression(LiteralExpression.boolean(input.asBoolean))]);
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class ResultState extends State<void, List<FunctionDefinition>> {
  const ResultState(super.output);
}
