import 'package:flutter_test/flutter_test.dart';
import 'package:xolo/data/services/postman_assertion_mapper.dart';
import 'package:xolo/domain/entities/assertion_rule_entity.dart';

void main() {
  test('maps pm.response.to.have.status', () {
    final rules = PostmanAssertionMapper.fromPostmanEvents([
      {
        'listen': 'test',
        'script': {
          'exec': ['pm.response.to.have.status(201);'],
        },
      },
    ]);
    expect(rules.single.type, AssertionType.statusCode);
    expect(rules.single.expected, '201');
  });
}
