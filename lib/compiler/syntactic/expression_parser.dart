import 'package:dry/compiler/errors/syntactic_error.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/utils/list_iterator.dart';

class ExpressionParser {
  final ListIterator<Token> iterator;

  const ExpressionParser(this.iterator);

  Expression get expression => getExpression(iterator);

  Expression getExpression(ListIterator<Token> iterator) {
    final Token input = iterator.next;

    if (input.type.isString) {
      return LiteralExpression.string(input.asString);
    } else if (input.type.isNumber) {
      return LiteralExpression.number(input.asNumber);
    } else if (input.type.isBoolean) {
      return LiteralExpression.boolean(input.asBoolean);
    } else if (input.type.isSymbol) {
      final Token next = iterator.peek;

      if (next.type.isOpenParenthesis) {
        iterator.consume();

        return FunctionCallExpression(
          name: input.asString,
          arguments: getFunctionArguments(iterator),
        );
      } else {
        return LiteralExpression.symbol(input.asString);
      }
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }

  List<Expression> getFunctionArguments(ListIterator<Token> iterator) {
    final List<Expression> result = [getExpression(iterator)];

    while (!iterator.peek.type.isCloseParenthesis) {
      final Token next = iterator.next;

      if (!next.type.isComma) {
        throw SyntacticError.invalidToken(next);
      }

      final Expression expression = getExpression(iterator);
      result.add(expression);
    }

    return result;
  }
}