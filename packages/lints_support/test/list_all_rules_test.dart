@TestOn('vm')
library;

import 'package:test/test.dart';

import '../tool/list_all_rules.dart' as tool;

Future<List<String>> _enabledRuleNames(String path) async => [
  for (var rule in (await tool.supportFileRules(path)).rules)
    if (rule.enabled) rule.name,
];

void main() {
  test('support files list their upstream lint set', () async {
    var veryGood = await _enabledRuleNames('lib/very_good_analysis.yaml');
    var team = await _enabledRuleNames('lib/dart_flutter_team_lints.yaml');
    // From package:lints/recommended.yaml, included by both upstream sets.
    expect(veryGood, contains('avoid_empty_else'));
    expect(team, contains('avoid_empty_else'));
    // very_good_analysis enables it, the dart/flutter team set does not.
    expect(veryGood, contains('public_member_api_docs'));
    expect(team, isNot(contains('public_member_api_docs')));
  }, timeout: const Timeout(Duration(minutes: 2)));
}
