# tekartik_lints

Tekartik common lints

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_lints:
    git:
      url: https://github.com/tekartik/common.dart
      path: packages/lints
      # optional
      # tag_pattern: "tekartik_lints/v{{version}}"
    version: ^1.0.0
```

## Usage

In `analysis_options.yaml`:

```yaml
# tekartik recommended lints (extension over google lints and pedantic)
include: package:tekartik_lints/recommended.yaml
```

Stricter:
`analysis_options.yaml`:

```yaml
# tekartik strict lints (extension over google lints and pedantic)
include: package:tekartik_lints/strict.yaml
```

Stricter for package (api docs and no print):
`analysis_options.yaml`:

```yaml
# tekartik strict lints (extension over google lints and pedantic)
include: package:tekartik_lints/package.yaml
```

Dart team:
```yaml
include: package:dart_flutter_team_lints/analysis_options.yaml
```

Very good analysis options:
```yaml
include: package:very_good_analysis/analysis_options.yaml
```