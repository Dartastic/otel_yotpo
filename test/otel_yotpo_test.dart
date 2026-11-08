// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_yotpo/otel_yotpo.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_yotpo-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('reviews.list records score + verified buyer + sentiment', () async {
    await tracedYotpo<String>(
      operation: 'reviews.list',
      invoke: () async => const YotpoCallResult(
        value: 'ok',
        result: YotpoResult(
          appKey: 'ak_1',
          productLine: 'reviews',
          productId: 'prod_42',
          reviewId: 'rev_1',
          reviewScore: 4,
          reviewVerifiedBuyer: true,
          reviewSentiment: 'positive',
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('yotpo reviews.list')!);
    expect(a['yotpo.review.score'], 4);
    expect(a['yotpo.review.verified_buyer'], true);
    expect(a['yotpo.review.sentiment'], 'positive');
  });

  test('loyalty.action.record records points + tier', () async {
    await tracedYotpo<String>(
      operation: 'loyalty.action.record',
      invoke: () async => const YotpoCallResult(
        value: 'ok',
        result: YotpoResult(
          productLine: 'loyalty',
          customerId: 'cust_1',
          loyaltyAction: 'place_order',
          loyaltyPointsDelta: 250,
          loyaltyTier: 'Gold',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('yotpo loyalty.action.record')!);
    expect(a['yotpo.loyalty.action'], 'place_order');
    expect(a['yotpo.loyalty.points_delta'], 250);
    expect(a['yotpo.loyalty.tier'], 'Gold');
  });

  test('sms.send failed delivery sets span error', () async {
    await tracedYotpo<String>(
      operation: 'sms.send',
      invoke: () async => const YotpoCallResult(
        value: 'ok',
        result: YotpoResult(
          productLine: 'sms_bump',
          smsCampaignId: 'camp_1',
          smsDeliveryStatus: 'failed',
        ),
      ),
    );
    expect(
      spans.findSpanByName('yotpo sms.send')!.status,
      SpanStatusCode.Error,
    );
  });

  test('image rejected does NOT set span error', () async {
    await tracedYotpo<String>(
      operation: 'images.moderate',
      invoke: () async => const YotpoCallResult(
        value: 'ok',
        result: YotpoResult(
          productLine: 'ugc',
          imageId: 'img_1',
          imageStatus: 'rejected',
        ),
      ),
    );
    expect(
      spans.findSpanByName('yotpo images.moderate')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutYotpoInstrumentationAsync(() async {
      await tracedYotpo<String>(
        operation: 'qa.list',
        invoke: () async => const YotpoCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('yotpo '), isEmpty);
  });
}
