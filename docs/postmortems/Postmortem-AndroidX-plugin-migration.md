# Flutter postmortem: AndroidX Plugin Migration

Status: draft

Owners: @mklim, @amirh, @dnfield, @hixie

## Summary

Description: The flutter/plugins repo was updated with a breaking change to
resolve
[flutter/flutter#23995](https://github.com/flutter/flutter/issues/23995). The
change migrated and deprecated Android dependencies in the plugins'
`build.gradle` files and required any apps using the plugins to also have Gradle
files that were either migrated or compatible with the AndroidX. Gradle errors
in hard-to-debug ways on Flutter apps broken by the change, without surfacing a
clear explanation or migration path to affected users. In addition this was a
known breaking change but originally incorrectly incremented the minor semantic
version number in 6/32 of the affected packages.

Component: `flutter/plugins`

Date/time: 2019-01-24 13:24 -0800

Duration: 4 days for the semantic versioning problem. 2 weeks for the confusing
Gradle error.

User impact: Users pinned to the major version of firebase_analytics,
firebase_database, firebase_messaging, firebase_storage, google_sign_in, and
url_launcher were broken by pub despite deliberately trying to avoid any
breaking changes. All other first party plugin users that try to use the latest
major version are affected by the confusing Gradle error.

## Timeline (all times in PST/PDT)

### 2019-01-24

* 13:24 - First breaking change with incorrect versioning merged,
  [flutter/plugins#1103](https://github.com/flutter/plugins/pull/1103).
* 14:20 - [flutter/plugins#1103](https://github.com/flutter/plugins/pull/1103)
  uploaded to pub. **&lt;START OF OUTAGE&gt;**

### 2019-01-25

* 09:44 - [flutter/plugins#1115](https://github.com/flutter/plugins/pull/1115),
  the final commit with breaking changes and incorrect semver, is merged to
  master.
* 10:55 - Final batch of incorrectly versioned plugins is published to pub.
* 13:53 - @hixie files
  [flutter/flutter#27106](https://github.com/flutter/flutter/issues/27106) for
  the obscure Gradle error following a fresh run of `flutter create` on the
  `stable` channel. Links the error to the AndroidX migration and tags @mklim,
  @amirh, and @dnfield.
* 14:03 - @mklim confirms the root cause of the error as an incompatibility
  between the app and plugin's Gradle files. *(The semantic versioning issue is
  not known at this point.)*
* 14:45 - @dnfield, @mklim, and @amirh discuss mitigating the user unfriendly
  `flutter create` error on `stable` offline. Decide to republish the AndroidX
  migration with a constraint so that users are on a version of flutter that
  produces AndroidX-compatible Gradle files. [pub](http://pub.dartlang.org)
  maintainers are contacted to remove the broken packages.

### 2019-01-26

* 00:30 - Email back and forth begins with pub maintainers.
* 08:07 -
  [flutter/flutter#27128](https://github.com/flutter/flutter/issues/27128) filed
  about upgrading a >= 1.0.0 plugin's minor version number.
* 12:33 - @mklim briefly explains the problem in
  [flutter/flutter#27128](https://github.com/flutter/flutter/issues/27128) and
  recommends to downgrade plugin versions since a revert for `flutter stable` is
  incoming. However his comment doesn't have details on all of the plugins to
  downgrade and what versions to downgrade them to. User discussion continues on
  this bug over the next 48 hours.
* 14:00 - Discussion with pub maintainers concludes. The affected packages can't
  be replaced because pub has safeguards against removing a "stable" package
  version. Decided to replace the packages with a patch+1 revert, and then a
  patch+2 migration with the minimum Flutter SDK constraint.

### 2019-01-28

* 09:00 - *Semantic versioning issue discovered.* Offline discussion scheduled
  with @mklim, @amirh, @kevmoo, @hixie, and @dnfield to re-assess a fix.
* 11:00 - @mklim, @amirh, @kevmoo, @hixie, and @dnfield re-review the issue with
  the semantic versioning issue also in mind. Decide that the minimum Flutter
  constraint is useless to address the problem since it really has to do with
  the app's `build.gradle`, which could have been generated by any Flutter
  version including the current one and which also could have been manually
  edited. Decide that the semver problem should be fixed by patching the 6
  affected plugins with a revert and then incrementing them with a major bump
  and the migration.
* 11:45 - @mklim updates
  [flutter/flutter#27128](https://github.com/flutter/flutter/issues/27128) with
  a detailed description of the bug, root cause, way to fix via migration or
  downgrade, and plan to fix the semantic versioning for the affected plugins.
* 14:28 - [flutter/plugins#1127](https://github.com/flutter/plugins/pull/1127)
  (the patch revert) is merged to master.
* 15:05 - [flutter/plugins#1128](https://github.com/flutter/plugins/pull/1128)
  (the correct forward roll) is merged to master.
* 15:08 - @dnfield alerts users following the AndroidX migration
  ([flutter/flutter#23995](https://github.com/flutter/flutter/issues/23995)) of
  the semantic version issues and that there's going to be a major version bump.
* 15:46 - The last affected package is updated on pub with both the patch revert
  and the forward roll with correct semver bump. **&lt;END OF SEMVER
  OUTAGE&gt;**
* 15:58 - @mklim updates
  [flutter/flutter#27128](https://github.com/flutter/flutter/issues/27128) and
  [flutter/flutter#23995](https://github.com/flutter/flutter/issues/23995) with
  info on the 6 packages that have had their semantic versions updated.
* 17:09 - @mklim updates
  [flutter/flutter#27106](https://github.com/flutter/flutter/issues/27106) with
  more details on the bug and the fixed semantic versioning problem.

### 2019-01-30

* 10:27 - @mklim updates the Flutter website via
  [flutter/website#2310](https://github.com/flutter/website/pull/2310) to
  explain how to import a Flutter app into the Android Studio IDE for automatic
  migration.
* 11:28 - @mklim opens
  [flutter/plugins#1138](https://github.com/flutter/plugins/pull/1138) so that
  the plugins warn about the AndroidX migration when Gradle fails to compile.

### 2019-02-05

* 13:41- @mklim opens
  [flutter/flutter#27566](https://github.com/flutter/flutter/pull/27566) to
  detect gradle error messages and link to a Flutter AndroidX migration guide on
  the Flutter website in Flutter itself.
* 17:35 - @mklim opens
  [flutter/website#2349](https://github.com/flutter/website/pull/2349) to add a
  migration guide to AndroidX for Flutter apps and plugins.

### 2019-02-07

* 13:23 - [flutter/website#2349](https://github.com/flutter/website/pull/2349)
  is merged.
* 17:30 - [flutter/plugins#1138](https://github.com/flutter/plugins/pull/1138)
  and [flutter/flutter#27566](https://github.com/flutter/flutter/pull/27566) are
  merged. Plugins are uploaded with the change. **&lt;END OF GRADLE ERROR
  OUTAGE&gt;**

## Impact

### Some first party plugin users were broken in a minor version upgrade

It looks like the only issue filed for this directly has been
[flutter/flutter#27128](https://github.com/flutter/flutter/issues/27128).

### All first party plugin users were broken in a confusing way

An explanation and migration path exists in the CHANGELOG.md of each plugin, but
this information is hard to find and the actual Gradle error is not helpful.
Several bugs on GitHub have been filed from affected users.

* [flutter/flutter#27106](https://github.com/flutter/flutter/issues/27106)
* [flutter/flutter#27226](https://github.com/flutter/flutter/issues/27226)
* [flutter/flutter#27146](https://github.com/flutter/flutter/issues/27146)
* [flutter/flutter#27156](https://github.com/flutter/flutter/issues/27156)

## Root causes

[flutter/plugins#1103](https://github.com/flutter/plugins/pull/1103),
[flutter/plugins#1115](https://github.com/flutter/plugins/pull/1115) migrated
the plugins to support AndroidX instead of the original Android support
libraries. See #23995 for more details, but in short the original support
libraries are deprecated and not recommended for Android app development
anymore.

This was a known breaking change and the changelog links to the official
[migration steps](https://developer.android.com/jetpack/androidx/migrate). BUT
plugins that were greater than or equal to `1.0.0` weren't updated according to
[pubspec's semantic versioning
philosophy](https://www.dartlang.org/tools/pub/versioning#semantic-versions). On
pub for packages < `1.0.0` the versioning is `0.major.minor+patch`, and for >=
1.0.0 it's `major.minor.patch`. The AndroidX PRs universally incremented the
middle number, so any plugin that was already at or above `1.0.0` is being
incorrectly treated as non-breaking by pub. This caused the semantic versioning
issue.

In addition the breaking change was only surfaced in the CHANGELOG.md of each
plugin, but resulted in breaking Gradle errors at runtime. These Gradle errors
did not provide any obvious ways to debug the incompatibility.

## Lessons learned

### What worked

* The plugins were migrated to AndroidX!

### Where we got lucky

* @hixie diagnosed the problem with standard `flutter create` templates
  relatively quickly and cc'ed the relevant devs.

### What didn't work

* We understood that the AndroidX migration was breaking, but underestimated the
  scale of the breakage. We didn't realize that it applied to all untouched
  `build.gradle` files produced by released versions of `flutter create`. Also
  failed to verify that the Gradle errors mentioned AndroidX or were otherwise
  easily understandable.
* The `flutter/plugins` CI failed to verify that the new plugins could be used
  with the template from `flutter create` on stable.
* No manual sanity checks were recommended and insufficient ones were performed
  before publishing the packages to pub. There could have been manual checks to
  catch the `flutter create` and semantic versioning issues.
* The packages were pushed Thursday/Friday (24-25) and remained broken over the
  weekend until a fix was decided communally when everyone was in the office
  Monday morning (28).
* The breaking change and suggested migration were only surfaced in the
  CHANGELOG of the plugins, not in the actual Gradle compile error. The
  changelogs are not very findable and the Gradle error is confusing.
* There was no way to mark the incorrect semver packages as broken in pub, so we
  needed to push a breaking revert along with a forward migration.

## Action items

### Prevention

* [flutter/flutter#27110](https://github.com/flutter/flutter/issues/27110) -
  Test the plugins from a blank, stable `flutter create` template on the plugins
  CI

### Detection

* [flutter/flutter#27258](https://github.com/flutter/flutter/issues/27258) - The
  plugins releasing process should be improved to help detect regressions.

### Mitigation

* [flutter/flutter#14818](https://github.com/flutter/flutter/issues/14818) -
  Translate Gradle errors into actionable steps for our users when possible.
* [dart-lang/pub#2038](https://github.com/dart-lang/pub/issues/2038) - Show a
  migration prompt and ask for confirmation on updating a breaking change in
  pub.
* [dart-lang/pub-dartlang-dart#378](https://github.com/dart-lang/pub-dartlang-dart/issues/378) - Tag
  specific pub releases as broken.

### Process

* [flutter/flutter#27258](https://github.com/flutter/flutter/issues/) - Have a
  better/more formalized releasing process for flutter/plugins.

### Fixes

* [flutter/plugins#1127](https://github.com/flutter/plugins/pull/1127)
* [flutter/plugins#1128](https://github.com/flutter/plugins/pull/1128)
* [flutter/website#2310](https://github.com/flutter/website/pull/2310)
* [flutter/plugins#1138](https://github.com/flutter/plugins/pull/1138)
* [flutter/flutter#27566](https://github.com/flutter/flutter/pull/27566)
* [flutter/website#2349](https://github.com/flutter/website/pull/2349)