import 'package:e_commerce_app_flutter/models/AppReview.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';

class AppReviewDatabaseHelper {
  static const String APP_REVIEW_COLLECTION_NAME = "app_reviews";

  AppReviewDatabaseHelper._privateConstructor();
  static AppReviewDatabaseHelper _instance =
      AppReviewDatabaseHelper._privateConstructor();
  factory AppReviewDatabaseHelper() {
    return _instance;
  }

  // Fake data storage (in-memory map)
  Map<String, AppReview> _appReviews = {};

  Future<bool> editAppReview(AppReview appReview) async {
    final uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    _appReviews[uid] = appReview;
    return true;
  }

  Future<AppReview> getAppReviewOfCurrentUser() async {
    final uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    if (_appReviews.containsKey(uid)) {
      return _appReviews[uid]!;
    } else {
      final appReview = AppReview(uid, liked: true, feedback: "");
      _appReviews[uid] = appReview;
      return appReview;
    }
  }
}
