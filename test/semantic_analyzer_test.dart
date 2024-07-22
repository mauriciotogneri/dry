import 'package:dry/compiler/errors/semantic_error.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  test('Repeated parameter', () {
    try {
      getIntermediateCode('isBiggerThan10(x, x) = gt(x, 10)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<SemanticError>());
    }
  });

  test('Duplicated functions', () {
    try {
      getIntermediateCode(
          'function1(x, y) = gt(x, 10)\nfunction1(a, b) = gt(a, 10)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<SemanticError>());
    }
  });

  test('Undecleared symbol 1', () {
    try {
      getIntermediateCode('isBiggerThan10 = gt(z, 10)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<SemanticError>());
    }
  });

  test('Undecleared symbol 2', () {
    try {
      getIntermediateCode('isBiggerThan10 = x');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<SemanticError>());
    }
  });

  test('Unused parameter', () {
    try {
      getIntermediateCode('isBiggerThan10(x, y) = gt(x, 10)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<SemanticError>());
    }
  });

  /*test('Invalid number of parameters', () {
    try {
      getIntermediateCode('isBiggerThan10(x) = gt(x, 10, 20)');
      fail('Should fail');
    } catch (e) {
      expect(e, isA<SemanticError>());
    }
  });*/

  /*test('Check result', () {
    final IntermediateCode code = getIntermediateCode('main = abs(-10)');
    checkCode(code, 10);
  });*/
}
