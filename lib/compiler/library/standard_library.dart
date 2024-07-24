import 'package:dry/compiler/library/condition/if.dart';
import 'package:dry/compiler/library/generic/eq.dart';
import 'package:dry/compiler/library/numbers/abs.dart';
import 'package:dry/compiler/library/numbers/ceil.dart';
import 'package:dry/compiler/library/numbers/dec.dart';
import 'package:dry/compiler/library/numbers/div.dart';
import 'package:dry/compiler/library/numbers/floor.dart';
import 'package:dry/compiler/library/numbers/gt.dart';
import 'package:dry/compiler/library/numbers/inc.dart';
import 'package:dry/compiler/library/numbers/max.dart';
import 'package:dry/compiler/library/numbers/min.dart';
import 'package:dry/compiler/library/numbers/mod.dart';
import 'package:dry/compiler/library/numbers/mul.dart';
import 'package:dry/compiler/library/numbers/pow.dart';
import 'package:dry/compiler/library/numbers/round.dart';
import 'package:dry/compiler/library/numbers/sqrt.dart';
import 'package:dry/compiler/library/numbers/sub.dart';
import 'package:dry/compiler/library/numbers/sum.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class StandardLibrary {
  static List<FunctionPrototype> get() => [
        // Generic
        Eq(),

        // Condition
        If(),

        // Numbers
        Abs(),
        Inc(),
        Dec(),
        Sum(),
        Sub(),
        Mul(),
        Div(),
        Mod(),
        Min(),
        Max(),
        Pow(),
        Sqrt(),
        Round(),
        Floor(),
        Ceil(),

        Gt(),
      ];
}
