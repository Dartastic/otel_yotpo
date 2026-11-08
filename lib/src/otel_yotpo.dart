// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_yotpo_suppression.dart';

const _tracerName = 'dartastic_otel_libs_yotpo';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class YotpoResult {
  /// Creates a result.
  const YotpoResult({
    this.appKey,
    this.productLine,
    this.productId,
    this.reviewId,
    this.reviewScore,
    this.reviewVerifiedBuyer,
    this.reviewSentiment,
    this.questionId,
    this.questionAnswered,
    this.imageId,
    this.imageStatus,
    this.customerId,
    this.loyaltyAction,
    this.loyaltyPointsDelta,
    this.loyaltyTier,
    this.referralCode,
    this.smsCampaignId,
    this.smsDeliveryStatus,
    this.statusCode,
  });

  /// Yotpo app key (one per merchant store).
  final String? appKey;

  /// `reviews` / `ugc` / `loyalty` / `referrals` / `sms_bump` /
  /// `subscriptions` — which Yotpo product the call hit.
  final String? productLine;

  final String? productId;

  final String? reviewId;

  /// 1 through 5.
  final int? reviewScore;

  /// `true` when Yotpo confirmed the reviewer bought the product
  /// (Verified Buyer badge).
  final bool? reviewVerifiedBuyer;

  /// `positive` / `neutral` / `negative` — Yotpo sentiment analysis
  /// when enabled.
  final String? reviewSentiment;

  final String? questionId;

  /// `true` when a Q&A question has at least one answer.
  final bool? questionAnswered;

  /// UGC image id (gallery).
  final String? imageId;

  /// `pending` / `approved` / `rejected`.
  final String? imageStatus;

  final String? customerId;

  /// Loyalty action — `place_order` / `signup` / `referral` /
  /// `review` / `birthday` / `social_share`.
  final String? loyaltyAction;

  /// Positive = earned, negative = redeemed.
  final int? loyaltyPointsDelta;

  /// VIP tier (`Bronze`/`Silver`/`Gold`/`Platinum` — merchant-defined).
  final String? loyaltyTier;

  /// Yotpo referral code.
  final String? referralCode;

  final String? smsCampaignId;

  /// `delivered` / `failed` / `undelivered` / `queued` / `sent`.
  final String? smsDeliveryStatus;

  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class YotpoCallResult<T> {
  /// Creates a call result.
  const YotpoCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final YotpoResult? result;
}

/// Wraps a Yotpo API call in a CLIENT span. [operation] is one of
/// `reviews.list`, `reviews.create`, `reviews.reply`, `qa.list`,
/// `qa.create`, `images.list`, `images.moderate`,
/// `loyalty.customer.get`, `loyalty.action.record`,
/// `loyalty.redemption.create`, `referrals.share`, `sms.send`,
/// `sms.optin`, `subscriptions.create`.
Future<T> tracedYotpo<T>({
  required String operation,
  required Future<YotpoCallResult<T>> Function() invoke,
}) async {
  if (yotpoInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'yotpo',
    'rpc.method': operation,
    'yotpo.operation': operation,
  };

  final span = _tracer().startSpan(
    'yotpo $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.appKey != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.app.key',
          r.result!.appKey!,
        ));
      }
      if (r.result!.productLine != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.product_line',
          r.result!.productLine!,
        ));
      }
      if (r.result!.productId != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.product.id',
          r.result!.productId!,
        ));
      }
      if (r.result!.reviewId != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.review.id',
          r.result!.reviewId!,
        ));
      }
      if (r.result!.reviewScore != null) {
        extras.add(OTelAPI.attributeInt(
          'yotpo.review.score',
          r.result!.reviewScore!,
        ));
      }
      if (r.result!.reviewVerifiedBuyer != null) {
        extras.add(OTelAPI.attributeBool(
          'yotpo.review.verified_buyer',
          r.result!.reviewVerifiedBuyer!,
        ));
      }
      if (r.result!.reviewSentiment != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.review.sentiment',
          r.result!.reviewSentiment!,
        ));
      }
      if (r.result!.questionId != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.question.id',
          r.result!.questionId!,
        ));
      }
      if (r.result!.questionAnswered != null) {
        extras.add(OTelAPI.attributeBool(
          'yotpo.question.answered',
          r.result!.questionAnswered!,
        ));
      }
      if (r.result!.imageId != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.image.id',
          r.result!.imageId!,
        ));
      }
      if (r.result!.imageStatus != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.image.status',
          r.result!.imageStatus!,
        ));
      }
      if (r.result!.customerId != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.customer.id',
          r.result!.customerId!,
        ));
      }
      if (r.result!.loyaltyAction != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.loyalty.action',
          r.result!.loyaltyAction!,
        ));
      }
      if (r.result!.loyaltyPointsDelta != null) {
        extras.add(OTelAPI.attributeInt(
          'yotpo.loyalty.points_delta',
          r.result!.loyaltyPointsDelta!,
        ));
      }
      if (r.result!.loyaltyTier != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.loyalty.tier',
          r.result!.loyaltyTier!,
        ));
      }
      if (r.result!.referralCode != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.referral.code',
          r.result!.referralCode!,
        ));
      }
      if (r.result!.smsCampaignId != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.sms.campaign_id',
          r.result!.smsCampaignId!,
        ));
      }
      if (r.result!.smsDeliveryStatus != null) {
        extras.add(OTelAPI.attributeString(
          'yotpo.sms.delivery_status',
          r.result!.smsDeliveryStatus!,
        ));
        if (r.result!.smsDeliveryStatus == 'failed' ||
            r.result!.smsDeliveryStatus == 'undelivered') {
          span.setStatus(
            SpanStatusCode.Error,
            'Yotpo SMS ${r.result!.smsDeliveryStatus}',
          );
        }
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Yotpo HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
