## Dart package versioning

[This file source](https://github.com/tekartik/common.dart/blob/main/doc/tekartik_versioning.md)

Tekartik maintains a number of open source packages that are not published to https://pub.dev. Publishing is a hard
commitment and it is really frustrating when published package are not maintained anymore. Tekartik does not garantuee
neither its package to be maintained however:

- public packages on Github uses weekly actions and analyze and test on all platforms (win, mac, linux) on 3 versions of
  the sdk (stable, beta, dev) being flutter or dart
- versioning should ensure almost forever compatibility or deprecate at least during 2 major version before removing.
- upper versioning limit is discouraged (although mandatory for published package) for dependencies. Trust all
  dependencies by default!
- New version (dart3a, dart2_3, dart2) are created with SDK or global dependencies conflicts. Hopefully a version should last a
  full year and updating should just be a matter of doing a global replace of the branch name in the pubspect.yaml file

Package versioning is based on git ref which should be the same for all tekartik public packages.

* Latest ref version: `dart3a` (dart3 package revision `a`, it supports dart3)
* Previous versions:
  * `dart2_3` (dart2 package revision 3, it supports dart2 and dart3 - it works on dart 3.0)
  * `dart2`
  * `null_safety`

Future ref should be `dart3b`,`dart3c`...`dart4a`...

```yaml
dependencies:
  tekartik_lints:
    git:
      url: https://github.com/tekartik/common.dart
      ref: dart3a
      path: packages/lints
    version: '>=0.1.0'
```

## Migration from previous version

If some tekartik git package dependency ref is not at latest ref.

## Mgigration from `null_safety`

Public package should use a `https://` url. Previously they were documented as `git://` which causes recent issues.

Migration, before:
```yaml
<packages>:
  # Bad usage or git scheme here, should be https
  url: git://github.com/tekartik/<path>
  # earlier version
  ref: null_safety (or dart2 or a previous version)
  # optional sub path
  path: ...
```
After:
```yaml
<packages>:
  # New https scheme used
  url: https://github.com/tekartik/<path>
  # current version!
  ref: dart3a
  # optional sub path
  path: ...
```

Example:

```yaml
dependencies:
  tekartik_lints:
    git:
      url: https://github.com/tekartik/common.dart
      ref: dart3a
      path: packages/lints
    version: '>=0.1.0'
```

- In the worst case, you could always fork a package you need and submit PR!
