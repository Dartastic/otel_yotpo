// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_yotpo/otel_yotpo.dart';

/// Traces Yotpo calls with OpenTelemetry.
///
/// `otel_yotpo` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Yotpo call in
/// [tracedYotpo]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'yotpo-example');

  // Wraps a Yotpo API call in a CLIENT span.
  final yotpoId = await tracedYotpo<String>(
    operation: 'reviews.create',
    invoke: () async {
      // Make the Yotpo call here, then report what it returned.
      const id = 'yotpo_8f3a2c';
      return const YotpoCallResult(
          value: id,
          result: YotpoResult(
              appKey: 'orders/2026/inv-1042.pdf',
              productLine: 'reviews',
              productId: 'product_8f3a2c',
              reviewId: 'review_8f3a2c',
              reviewScore: 1,
              reviewVerifiedBuyer: true,
              reviewSentiment: 'positive',
              questionId: 'question_8f3a2c',
              questionAnswered: true,
              imageId: 'image_8f3a2c',
              imageStatus: 'pending',
              customerId: 'customer_8f3a2c',
              loyaltyAction: 'place_order',
              loyaltyPointsDelta: 1,
              loyaltyTier: 'Bronze',
              referralCode: 'example',
              smsCampaignId: 'smscampaign_8f3a2c',
              smsDeliveryStatus: 'delivered',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedYotpo reviews.create returned $yotpoId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutYotpoInstrumentationAsync.
  await runWithoutYotpoInstrumentationAsync(
    () => tracedYotpo<String>(
      operation: 'reviews.create',
      invoke: () async {
        const id = 'yotpo_8f3a2c';
        return const YotpoCallResult(
            value: id,
            result: YotpoResult(
                appKey: 'orders/2026/inv-1042.pdf',
                productLine: 'reviews',
                productId: 'product_8f3a2c',
                reviewId: 'review_8f3a2c',
                reviewScore: 1,
                reviewVerifiedBuyer: true,
                reviewSentiment: 'positive',
                questionId: 'question_8f3a2c',
                questionAnswered: true,
                imageId: 'image_8f3a2c',
                imageStatus: 'pending',
                customerId: 'customer_8f3a2c',
                loyaltyAction: 'place_order',
                loyaltyPointsDelta: 1,
                loyaltyTier: 'Bronze',
                referralCode: 'example',
                smsCampaignId: 'smscampaign_8f3a2c',
                smsDeliveryStatus: 'delivered',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
