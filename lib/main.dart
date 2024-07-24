import 'package:dry/compiler/compiler.dart';
import 'package:dry/compiler/runtime/runtime.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/warnings/generic_warning.dart';
import 'package:dry/utils/console.dart';
import 'package:dry/utils/file_reader.dart';

void main(List<String> args) {
  final Console console = Console();

  try {
    const Compiler compiler = Compiler();
    final IntermediateCode intermediateCode = args.isNotEmpty
        ? compiler.compile(FileReader.read(args[0]))
        : IntermediateCode.empty();

    for (final GenericWarning warning in intermediateCode.warnings) {
      console.warning(warning);
    }

    final Runtime runtime = Runtime(intermediateCode);

    if (runtime.hasMain) {
      final String result = runtime.executeMain();
      console.print(result);
    } else {
      while (true) {
        try {
          final String input = console.prompt();

          if (input.isNotEmpty) {
            final Expression expression = compiler.expression(input);
            console.print(runtime.evaluate(expression));
          }
        } catch (e) {
          console.error(e);
        }
      }
    }
  } catch (e) {
    console.error(e);
  }
}
