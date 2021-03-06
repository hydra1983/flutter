// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui show Image;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Verify Image resets its RenderImage when changing providers', (WidgetTester tester) async {
    final GlobalKey key = new GlobalKey();
    final TestImageProvider imageProvider1 = new TestImageProvider();
    await tester.pumpWidget(
      new Container(
        key: key,
        child: new Image(
          image: imageProvider1
        )
      ),
      null,
      EnginePhase.layout
    );
    RenderImage renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNull);

    imageProvider1.complete();
    await tester.idle(); // resolve the future from the image provider
    await tester.pump(null, EnginePhase.layout);

    renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNotNull);

    final TestImageProvider imageProvider2 = new TestImageProvider();
    await tester.pumpWidget(
      new Container(
        key: key,
        child: new Image(
          image: imageProvider2
        )
      ),
      null,
      EnginePhase.layout
    );

    renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNull);
  });

  testWidgets('Verify Image doesn\'t reset its RenderImage when changing providers if it has gaplessPlayback set', (WidgetTester tester) async {
    final GlobalKey key = new GlobalKey();
    final TestImageProvider imageProvider1 = new TestImageProvider();
    await tester.pumpWidget(
      new Container(
        key: key,
        child: new Image(
          gaplessPlayback: true,
          image: imageProvider1
        )
      ),
      null,
      EnginePhase.layout
    );
    RenderImage renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNull);

    imageProvider1.complete();
    await tester.idle(); // resolve the future from the image provider
    await tester.pump(null, EnginePhase.layout);

    renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNotNull);

    final TestImageProvider imageProvider2 = new TestImageProvider();
    await tester.pumpWidget(
      new Container(
        key: key,
        child: new Image(
          gaplessPlayback: true,
          image: imageProvider2
        )
      ),
      null,
      EnginePhase.layout
    );

    renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNotNull);
  });

  testWidgets('Verify Image resets its RenderImage when changing providers if it has a key', (WidgetTester tester) async {
    final GlobalKey key = new GlobalKey();
    final TestImageProvider imageProvider1 = new TestImageProvider();
    await tester.pumpWidget(
      new Image(
        key: key,
        image: imageProvider1
      ),
      null,
      EnginePhase.layout
    );
    RenderImage renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNull);

    imageProvider1.complete();
    await tester.idle(); // resolve the future from the image provider
    await tester.pump(null, EnginePhase.layout);

    renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNotNull);

    final TestImageProvider imageProvider2 = new TestImageProvider();
    await tester.pumpWidget(
      new Image(
        key: key,
        image: imageProvider2
      ),
      null,
      EnginePhase.layout
    );

    renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNull);
  });

  testWidgets('Verify Image doesn\'t reset its RenderImage when changing providers if it has gaplessPlayback set', (WidgetTester tester) async {
    final GlobalKey key = new GlobalKey();
    final TestImageProvider imageProvider1 = new TestImageProvider();
    await tester.pumpWidget(
      new Image(
        key: key,
        gaplessPlayback: true,
        image: imageProvider1
      ),
      null,
      EnginePhase.layout
    );
    RenderImage renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNull);

    imageProvider1.complete();
    await tester.idle(); // resolve the future from the image provider
    await tester.pump(null, EnginePhase.layout);

    renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNotNull);

    final TestImageProvider imageProvider2 = new TestImageProvider();
    await tester.pumpWidget(
      new Image(
        key: key,
        gaplessPlayback: true,
        image: imageProvider2
      ),
      null,
      EnginePhase.layout
    );

    renderImage = key.currentContext.findRenderObject();
    expect(renderImage.image, isNotNull);
  });

  testWidgets('Verify ImageProvider configuration inheritance', (WidgetTester tester) async {
    final GlobalKey mediaQueryKey1 = new GlobalKey(debugLabel: 'mediaQueryKey1');
    final GlobalKey mediaQueryKey2 = new GlobalKey(debugLabel: 'mediaQueryKey2');
    final GlobalKey imageKey = new GlobalKey(debugLabel: 'image');
    final TestImageProvider imageProvider = new TestImageProvider();

    // Of the two nested MediaQuery objects, the innermost one,
    // mediaQuery2, should define the configuration of the imageProvider.
    await tester.pumpWidget(
      new MediaQuery(
        key: mediaQueryKey1,
        data: const MediaQueryData(
          devicePixelRatio: 10.0,
          padding: EdgeInsets.zero,
        ),
        child: new MediaQuery(
          key: mediaQueryKey2,
          data: const MediaQueryData(
            devicePixelRatio: 5.0,
            padding: EdgeInsets.zero,
          ),
          child: new Image(
            key: imageKey,
            image: imageProvider
          ),
        )
      )
    );

    expect(imageProvider._configuration.devicePixelRatio, 5.0);

    // This is the same widget hierarchy as before except that the
    // two MediaQuery objects have exchanged places. The imageProvider
    // should be resolved again, with the new innermost MediaQuery.
    await tester.pumpWidget(
      new MediaQuery(
        key: mediaQueryKey2,
        data: const MediaQueryData(
          devicePixelRatio: 5.0,
          padding: EdgeInsets.zero,
        ),
        child: new MediaQuery(
          key: mediaQueryKey1,
          data: const MediaQueryData(
            devicePixelRatio: 10.0,
            padding: EdgeInsets.zero,
          ),
          child: new Image(
            key: imageKey,
            image: imageProvider
          ),
        )
      )
    );

    expect(imageProvider._configuration.devicePixelRatio, 10.0);
  });

  testWidgets('Verify ImageProvider configuration inheritance again', (WidgetTester tester) async {
    final GlobalKey mediaQueryKey1 = new GlobalKey(debugLabel: 'mediaQueryKey1');
    final GlobalKey mediaQueryKey2 = new GlobalKey(debugLabel: 'mediaQueryKey2');
    final GlobalKey imageKey = new GlobalKey(debugLabel: 'image');
    final TestImageProvider imageProvider = new TestImageProvider();

    // This is just a variation on the previous test.  In this version the location
    // of the Image changes and the MediaQuery widgets do not.
    await tester.pumpWidget(
      new Row(
        children: <Widget> [
          new MediaQuery(
            key: mediaQueryKey2,
            data: const MediaQueryData(
              devicePixelRatio: 5.0,
              padding: EdgeInsets.zero,
            ),
            child: new Image(
              key: imageKey,
              image: imageProvider
            )
          ),
          new MediaQuery(
            key: mediaQueryKey1,
            data: const MediaQueryData(
              devicePixelRatio: 10.0,
              padding: EdgeInsets.zero,
            ),
            child: new Container(width: 100.0)
          )
        ]
      )
    );

    expect(imageProvider._configuration.devicePixelRatio, 5.0);

    await tester.pumpWidget(
      new Row(
        children: <Widget> [
          new MediaQuery(
            key: mediaQueryKey2,
            data: const MediaQueryData(
              devicePixelRatio: 5.0,
              padding: EdgeInsets.zero,
            ),
            child: new Container(width: 100.0)
          ),
          new MediaQuery(
            key: mediaQueryKey1,
            data: const MediaQueryData(
              devicePixelRatio: 10.0,
              padding: EdgeInsets.zero,
            ),
            child: new Image(
              key: imageKey,
              image: imageProvider
            )
          )
        ]
      )
    );

    expect(imageProvider._configuration.devicePixelRatio, 10.0);
  });

  testWidgets('Verify Image stops listening to ImageStream', (WidgetTester tester) async {
    final TestImageProvider imageProvider = new TestImageProvider();
    await tester.pumpWidget(new Image(image: imageProvider));
    final State<Image> image = tester.state/*State<Image>*/(find.byType(Image));
    expect(image.toString(), matches(new RegExp(r'_ImageState#[0-9]+\(stream: ImageStream\(OneFrameImageStreamCompleter; unresolved; 1 listener\); pixels: null\)')));
    imageProvider.complete();
    await tester.pump();
    expect(image.toString(), matches(new RegExp(r'_ImageState#[0-9]+\(stream: ImageStream\(OneFrameImageStreamCompleter; \[100×100\] @ 1\.0x; 1 listener\); pixels: \[100×100\] @ 1\.0x\)')));
    await tester.pumpWidget(new Container());
    expect(image.toString(), matches(new RegExp(r'_ImageState#[0-9]+\(_StateLifecycle.defunct; not mounted; stream: ImageStream\(OneFrameImageStreamCompleter; \[100×100\] @ 1\.0x; 0 listeners\); pixels: \[100×100\] @ 1\.0x\)')));
  });

}

class TestImageProvider extends ImageProvider<TestImageProvider> {
  final Completer<ImageInfo> _completer = new Completer<ImageInfo>();
  ImageConfiguration _configuration;

  @override
  Future<TestImageProvider> obtainKey(ImageConfiguration configuration) {
    return new SynchronousFuture<TestImageProvider>(this);
  }

  @override
  ImageStream resolve(ImageConfiguration configuration) {
    _configuration = configuration;
    return super.resolve(configuration);
  }

  @override
  ImageStreamCompleter load(TestImageProvider key) => new OneFrameImageStreamCompleter(_completer.future);

  void complete() {
    _completer.complete(new ImageInfo(image: new TestImage()));
  }

  @override
  String toString() => '$runtimeType#$hashCode()';
}

class TestImage extends ui.Image {
  @override
  int get width => 100;

  @override
  int get height => 100;

  @override
  void dispose() { }
}
