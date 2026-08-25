# Tekartik published package versioning

How Tekartik versions the packages it publishes on [pub.dev](https://pub.dev), and how those
packages constrain their own dependencies.

Most Tekartik packages are *not* published and are consumed as git dependencies - those follow
[tekartik_versioning.md](https://github.com/tekartik/common.dart/blob/main/doc/tekartik_versioning.md).
Publishing is a much harder commitment: consumers cannot pin a ref, cannot patch through a fork
without republishing, and an unmaintained published package with tight constraints blocks the whole
dependency graph of everyone using it. The rules below exist to keep that blast radius small.

## Principles

- **Trust dependencies by default.** Upper bounds are pure liability for consumers. They are only
  used because pub.dev makes them mandatory - so use the loosest one that is defensible.
- **Compatibility should last almost forever.** A consumer should never be forced to migrate for a
  reason that is not an actual API break.
- **Deprecate before removing**, over at least 2 major versions.

## Dependency constraints

Upper bound is **major + 2**, i.e. two majors of headroom above the version being developed against.
Lower bound is the minimum version actually tested against.

```yaml
dependencies:
  path: '>=1.9.0 <3.0.0'
  args: '>=2.7.0 <4.0.0'
  synchronized: '>=3.4.1 <5.0.0'
```

The rule is uniform: for a dependency currently at `X.y.z`, the constraint is `>=X.y.z <(X+2).0.0`.

For `0.x` dependencies the same rule gives `<2.0.0` - which accepts the rest of the `0.x` line and
the eventual `1.0`:

```yaml
  test_api: '>=0.7.10 <2.0.0'
  matcher: '>=0.12.16 <2.0.0'
```

This is deliberate. `0.x` minors are technically breaking, but a package stuck below a dependency's
`1.0` release is worse than the occasional breakage, and the CI matrix catches it early.

Note: `^X.y.z` is *never* used for dependencies of published packages - it is the tight bound this
policy is arguing against.

### dev_dependencies

Dev dependencies are not part of the published contract and never constrain a consumer, so they get
a lower bound only:

```yaml
dev_dependencies:
  test: '>=1.31.1'
  lints: '>=6.1.0'
```

### Dart/Flutter SDK constraint

The SDK constraint uses the caret form, matching the SDK the package is developed against:

```yaml
environment:
  sdk: ^3.12.0
```

## When a loose upper bound turns out to be wrong

A `+2` upper bound is a bet, and sometimes it loses: a dependency ships a new major that genuinely
breaks the package, and the loose bound already allows consumers to resolve into that combination.
This is the cost of trusting dependencies by default, and it is repaired in **two published
releases**, not one.

Say `foo 1.4.0` depends on `bar: '>=1.2.0 <3.0.0'`, and `bar 2.0.0` comes out and breaks it.

**First**, publish a minor bump that lowers the upper bound to exclude the breaking major:

```yaml
# foo 1.5.0
dependencies:
  bar: '>=1.2.0 <2.0.0'
```

This stops the bleeding immediately. Anyone resolving `foo` now lands back on a `bar 1.x` that works,
without waiting for the migration to be written. Note that no code changed - only the constraint.

**Then**, once the package is actually migrated to the new major, publish the next minor bump with a
new lower bound (and a fresh `+2` upper bound from there):

```yaml
# foo 1.6.0
dependencies:
  bar: '>=2.0.0 <4.0.0'
```

Pub now sorts consumers automatically: still on `bar 1.x` resolves to `foo 1.5.0`, moved to
`bar 2.x` resolves to `foo 1.6.0`. Both are working versions.

Two things worth noting:

- Neither release is a major bump of `foo` itself. `foo`'s own API never broke - only the range of
  dependency versions it accepts changed, and a major bump would force every consumer to edit a
  constraint for a break that was not in this package.
- A consumer left behind on `foo 1.5.0` is in exactly the situation described in the next section:
  parked on a perfectly fine version, missing later features, not broken.

Do not skip the first release and go straight to the migration. Between the moment `bar 2.0.0`
appears and the moment the migrated version is published, every consumer resolving `foo` gets a
broken build - and that window is as long as the migration takes.

## Raising the minimum SDK is not a breaking change

Bumping the minimum Dart (or Flutter) SDK does **not** require a major version bump.

The reasoning: SDK minimums move constantly. Treating each bump as breaking would walk a package from
`1.0.0` to `13.0.0` on SDK churn alone, and every consumer on `^12.0.0` or `^11.0.0` would have to
migrate their constraint for a release that broke no API they use. The cost lands entirely on
consumers, for no signal.

Nothing breaks, for a library or for an app. Pub simply resolves a consumer on an older SDK to the
last published version whose `environment` constraint that SDK satisfies. That version is a perfectly
fine version - it is the exact code that was working the day before, it still compiles, it still
passes its tests, and no source change is required anywhere. The consumer is not stuck on something
broken; they are staying on something good.

The only consequence of not upgrading the SDK is not getting access to what came after: new features,
new APIs, and fixes released above that line. That is a missed improvement, not a breakage - and it
is exactly what a consumer choosing to stay on an old SDK is already opting into.

Contrast that with a real breaking change, which forces every consumer to edit their own code to keep
building. That is the cost a major bump is meant to signal, and an SDK bump does not carry it. So a
minimum SDK bump ships as a minor (or patch) release.

## A major bump is a burden on every package below

The reason major bumps are treated as expensive is that their cost is not paid by the package doing
the bumping. It is paid by everyone depending on it, and it is much heavier for a *package* than for
an app.

An app that wants the new major edits its own code, adjusts its constraint, and it is done - the cost
stops there, on its own schedule.

A published package cannot stop there. To accept the new major it has to migrate its code, publish
that as a new version of itself, with the version bump, the changelog, the CI run and the pub.dev
release that entails. And now its own consumers are in the same position, one level further down. A
single major release upstream turns into a wave of releases through everything that depends on it,
which has to happen roughly in dependency order.

Until the middle of that chain publishes, the packages below it are simply stuck: their intermediate
dependency still carries an upper bound that excludes the new major, so they cannot take it at all,
however ready their own code is. Worse, a consumer depending on two packages that have not converged
on the same major of a shared dependency gets an unresolvable graph - no version selection satisfies
both, and there is nothing to do but wait.

That is also where an unmaintained package becomes fatal rather than merely inconvenient. If nobody
republishes the intermediate one, everything underneath it is blocked permanently, and the only exits
are a fork or a dependency_override.

So a major bump is not a local decision, and none of it is recovered by the fact that the migration
itself was small. This is what the rest of this document is protecting against: the `+2` upper bound
avoids being the package that forces the wave, and the "not major" list below keeps releases out of
the category that starts one.

## What is a major version bump

Major:

- removing an API that has been deprecated for at least 2 major versions
- changing the signature or the observable behaviour of an existing API in a non-additive way
- removing or renaming a package export

Not major:

- raising the minimum Dart/Flutter SDK (see above)
- adding a new API, class, or optional parameter
- widening a dependency's upper bound
- raising a dependency's lower bound

## Deprecation

Mark, do not remove:

```dart
@Deprecated('Use newThing() instead')
void oldThing() => newThing();
```

The deprecated member stays for at least 2 major versions before removal, so a consumer skipping a
major release still gets a compile-time warning rather than a compile error.

## Checklist before publishing

- [ ] every `dependencies` entry is `>=X.y.z <(X+2).0.0`
- [ ] every `dev_dependencies` entry is a lower bound only
- [ ] nothing removed that has not been deprecated for 2 majors
- [ ] version bump reflects the rules above - an SDK bump alone is not a major
- [ ] lower bounds verified with a `pub downgrade` + analyze pass (see below)
- [ ] CI green on stable/beta/dev, on win/mac/linux

## Verifying the lower bounds

Loose upper bounds are cheap to get right; **lower** bounds are the ones that silently rot. A
constraint like `>=1.9.0` is a claim that the package still compiles against `path 1.9.0` - and that
claim quietly becomes false as soon as some code starts using a newer API, because normal resolution
always picks the latest version.

Check it by resolving to the minimum instead:

```
dart pub global activate dev_build
dart pub global run dev_build:run_ci --pub-downgrade --analyze --no-override --recursive
```

This recursively runs `dart/flutter pub downgrade` and `dart analyze` on every project. Any analysis
error means a lower bound is too low - raise it to the version that actually provides the API being
used, rather than removing the bound.
