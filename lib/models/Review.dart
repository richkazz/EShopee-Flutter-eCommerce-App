import 'package:e_commerce_app_flutter/models/Model.dart';

class Review extends Model {
  static const String REVIEWER_UID_KEY = "reviewer_uid";
  static const String RATING_KEY = "rating";
  static const String FEEDBACK_KEY = "review";

  String reviewerUid;
  int rating;
  String feedback;
  Review(
    String id, {
    required this.reviewerUid,
    this.rating = 3,
    required this.feedback,
  }) : super(id);

  factory Review.fromMap(Map<String, dynamic> map, {required String id}) {
    return Review(
      id,
      reviewerUid: map[REVIEWER_UID_KEY],
      rating: map[RATING_KEY],
      feedback: map[FEEDBACK_KEY],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      REVIEWER_UID_KEY: reviewerUid,
      RATING_KEY: rating,
      FEEDBACK_KEY: feedback,
    };
    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    map[REVIEWER_UID_KEY] = reviewerUid;
    map[RATING_KEY] = rating;
    map[FEEDBACK_KEY] = feedback;
    return map;
  }
}
