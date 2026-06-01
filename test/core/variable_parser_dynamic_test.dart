import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/core/utils/variable_parser.dart';

void main() {
  test('dynamic isoDate', () {
    final result = VariableParser.parse(r'{{$isoDate}}', {});
    expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
  });

  test('randomEmail', () {
    final result = VariableParser.parse(r'{{$randomEmail}}', {});
    expect(result, contains('@xolo.test'));
  });

  test('randomIntRange', () {
    final result = VariableParser.parse(r'{{$randomIntRange:10:20}}', {});
    final value = int.parse(result);
    expect(value, inInclusiveRange(10, 20));
  });
}
