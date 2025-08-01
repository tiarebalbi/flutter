// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_tools/src/widget_preview/dependency_graph.dart';
import 'package:flutter_tools/src/widget_preview/preview_details.dart';
import 'package:test/test.dart';

typedef _PreviewDetailsMatcherMismatchPair = ({Object? expected, Object? actual});

/// A [Matcher] that verifies each property of a `@Preview` declaration matches an expected value.
class PreviewDetailsMatcher extends Matcher {
  PreviewDetailsMatcher({
    required this.packageName,
    required this.functionName,
    required this.isBuilder,
    this.name,
    this.size,
    this.textScaleFactor,
    this.wrapper,
    this.theme,
    this.brightness,
    this.localizations,
  });

  final String functionName;
  final bool isBuilder;
  final String packageName;

  final String? name;
  final String? size;
  final double? textScaleFactor;
  final String? wrapper;
  final String? theme;
  final String? brightness;
  final String? localizations;

  @override
  Description describe(Description description) {
    description.add('PreviewDetailsMatcher');
    return description;
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<Object?, Object?> matchState,
    bool verbose,
  ) {
    mismatchDescription.add('has the following mismatches:\n\n');
    for (final MapEntry<String, _PreviewDetailsMatcherMismatchPair>(
          :String key,
          value: _PreviewDetailsMatcherMismatchPair(:Object? actual, :Object? expected),
        )
        in matchState.cast<String, _PreviewDetailsMatcherMismatchPair>().entries) {
      mismatchDescription.add("- $key = '$actual' differs from the expected value '$expected'\n");
    }
    return mismatchDescription;
  }

  @override
  bool matches(Object? item, Map<Object?, Object?> matchState) {
    if (item is! PreviewDetails) {
      return false;
    }

    var matches = true;
    void checkPropertyMatch({
      required String name,
      required Object? actual,
      required Object? expected,
    }) {
      if (actual != expected) {
        matchState[name] = (actual: actual, expected: expected);
        matches = false;
      }
    }

    checkPropertyMatch(name: 'packageName', actual: item.packageName, expected: packageName);
    checkPropertyMatch(name: 'functionName', actual: item.functionName, expected: functionName);
    checkPropertyMatch(name: 'isBuilder', actual: item.isBuilder, expected: isBuilder);
    checkPropertyMatch(
      name: PreviewDetails.kName,
      actual: item.name.toStringValue(),
      expected: name,
    );
    checkPropertyMatch(
      name: PreviewDetails.kSize,
      actual: item.size.isNull ? null : item.size.toString(),
      expected: size,
    );
    checkPropertyMatch(
      name: PreviewDetails.kTextScaleFactor,
      actual: item.textScaleFactor.toDoubleValue(),
      expected: textScaleFactor,
    );
    checkPropertyMatch(
      name: PreviewDetails.kWrapper,
      actual: item.wrapper.toFunctionValue2()?.displayName,
      expected: wrapper,
    );
    checkPropertyMatch(
      name: PreviewDetails.kTheme,
      actual: item.theme.toFunctionValue2()?.displayName,
      expected: theme,
    );
    checkPropertyMatch(
      name: PreviewDetails.kBrightness,
      actual: item.brightness.isNull ? null : item.brightness.variable2!.toString(),
      expected: brightness,
    );
    checkPropertyMatch(
      name: PreviewDetails.kLocalizations,
      actual: item.localizations.toFunctionValue2()?.displayName,
      expected: localizations,
    );
    return matches;
  }
}

void expectContainsPreviews(
  Map<PreviewPath, LibraryPreviewNode> actual,
  Map<PreviewPath, List<PreviewDetailsMatcher>> expected,
) {
  for (final MapEntry<PreviewPath, List<PreviewDetailsMatcher>>(
        key: PreviewPath previewPath,
        value: List<PreviewDetailsMatcher> filePreviews,
      )
      in expected.entries) {
    expect(actual.containsKey(previewPath), true);
    expect(actual[previewPath]!.previews, filePreviews);
  }
}
