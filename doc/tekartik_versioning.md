## Dart package versioning

Package versioning is based on git ref which should be the same for all tekartik public packages.

> * Latest ref version: `dart2_3` (dart2 package revision 3)
> * Previous versions: `null_safety`, `dart2`
>
> Public package should use a `https://` url. Previously they were documented as `git://` which causes recent issues.
>
> Mibration, before:
> ```yaml
> <packages>:
>   # Bad usage or git scheme here, should be https
>   url: git://github.com/tekartik/<path>
>   # earlier version
>   ref: null_safety (or dart2 or a previous version)
> ```
> After:
> ```yaml
> <packages>:
>   # New https scheme used
>   url: https://github.com/tekartik/<path>
>   # current version!
>   ref: dart2_3
> ```

Example:

```yaml
dependencies:
  tekartik_lints:
    git:
      url: https://github.com/tekartik/common.dart
      ref: dart2_3
      path: packages/lints
    version: '>=0.1.0'
```

Tekartik maintains a number of open source packages that are not published to https://pub.dev. Publishing is a hard
commitment and it is really frustrating when published package are not maintained anymore. Tekartik does not garantuee
neither its package to be maintained however:

- public packages on Github uses weekly actions and analyze and test on all platforms (win, mac, linux) on 3 versions of
  the sdk (stable, beta, dev) being flutter or dart
- versioning should ensure almost forever compatibility or deprecate at least during 2 major version before removing.
- upper versioning limit is discouraged (although mandatory for published package) for dependencies. Trust all
  dependencies by default!
- New version (dart2, dart2_3) are created with SDK or global dependencies conflicts. Hopefully a version should last a
  full year and updating should just be a matter of doing a global replace:

```dart
replaceAll('ref: null_safety', 'ref: dart2_3');
```
- In the worst case, you could always fork a package you need and submit PR!
