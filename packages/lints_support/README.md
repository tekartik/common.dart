# tekartik_lints_support

Maintenance tools of
[tekartik_lints](https://github.com/tekartik/common.dart/tree/main/packages/lints)
(not a package to depend on). Run them from this folder after `dart pub get`
at the repository root.

| Tool | What it does |
|---|---|
| `dart run tool/list_all_rules.dart` | Writes the full rule list (includes resolved) of each `tekartik_lints` lint file to `doc/all_rules_<file>.yaml`, and of the upstream sets this package includes (`lib/very_good_analysis.yaml`, `lib/dart_flutter_team_lints.yaml`) to `doc/support/all_rules_<file>.yaml`; also `.local/all_rules_any_<file>.yaml` through `tklint list-rules --force-any` (`tklint` from `tekartik_prj_tktools`, activated globally) |
| `dart run tool/fix_all_rules.dart` | Rewrites the `linter: rules:` of each `tekartik_lints` lint file with only the rules that differ from its include, without obsolete rules (it edits `packages/lints/lib/*.yaml`) |

The `doc/support/` lists follow the upstream versions resolved by
`dart pub get`: run `list_all_rules.dart` again after an upgrade of
`very_good_analysis` or `dart_flutter_team_lints`.
