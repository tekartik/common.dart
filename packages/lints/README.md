# tekartik_lints

Tekartik common lints

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_lints:
    git:
      url: git://github.com/tekartik/common.dart
      ref: null_safety
      path: packages/lints
    version: '>=0.1.0'
```

## Usage

In `analysis_options.yaml`:

```yaml
# tekartik recommended lints (extension over google lints and pedantic)
include: package:tekartik_lints/recommended.yaml
```