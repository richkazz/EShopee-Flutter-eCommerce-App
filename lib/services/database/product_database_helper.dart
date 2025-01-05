import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/models/Review.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:enum_to_string/enum_to_string.dart';

class ProductDatabaseHelper {
  static const String PRODUCTS_COLLECTION_NAME = "products";
  static const String REVIEWS_COLLECTOIN_NAME = "reviews";

  ProductDatabaseHelper._privateConstructor();
  static ProductDatabaseHelper _instance =
      ProductDatabaseHelper._privateConstructor();
  factory ProductDatabaseHelper() {
    return _instance;
  }

  // Fake data storage
  Map<String, Product> _products = {}; // Product ID -> Product
  Map<String, List<Review>> _reviews = {}; // Product ID -> List of Reviews

  Future<List<String>> searchInProducts(String query,
      {ProductType? productType}) async {
    query = query.toLowerCase();
    Set<String> productsId = Set<String>();

    for (var productEntry in _products.entries) {
      final product = productEntry.value;
      if (productType != null && product.productType != productType) {
        continue;
      }

      bool match = false;
      if (product.searchTags.contains(query)) {
        match = true;
      } else if (product.title.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.highlights.toString().toLowerCase().contains(query) ||
          product.variant.toString().toLowerCase().contains(query) ||
          product.seller.toLowerCase().contains(query)) {
        match = true;
      }
      if (match) {
        productsId.add(productEntry.key);
      }
    }
    return productsId.toList();
  }

  Future<bool> addProductReview(String productId, Review review) async {
    if (_products.containsKey(productId)) {
      if (!_reviews.containsKey(productId)) {
        _reviews[productId] = [];
      }

      // Check if review by this user already exists
      int oldRating = 0;
      bool reviewExists = false;
      for (int i = 0; i < _reviews[productId]!.length; i++) {
        if (_reviews[productId]![i].reviewerUid == review.reviewerUid) {
          oldRating = _reviews[productId]![i].rating;
          _reviews[productId]![i] = review; // Update existing review
          reviewExists = true;
          break;
        }
      }

      if (!reviewExists) {
        _reviews[productId]!.add(review);
      }

      return await addUsersRatingForProduct(productId, review.rating,
          oldRating: oldRating);
    } else {
      throw Exception("Product not found");
    }
  }

  Future<bool> addUsersRatingForProduct(String productId, int rating,
      {int oldRating = 0}) async {
    if (_products.containsKey(productId)) {
      final ratingsCount = _reviews[productId]?.length ?? 0;
      final prevRating = _products[productId]!.rating;
      double newRating;

      if (ratingsCount == 0) {
        newRating = rating.toDouble();
      } else {
        newRating =
            (prevRating * ratingsCount + rating - oldRating) / ratingsCount;
      }

      final newRatingRounded = double.parse(newRating.toStringAsFixed(1));
      _products[productId] =
          _products[productId]!.copyWith(rating: newRatingRounded);
      return true;
    } else {
      throw Exception("Product not found");
    }
  }

  Future<Review?> getProductReviewWithID(
      String productId, String reviewId) async {
    if (_reviews.containsKey(productId)) {
      for (final review in _reviews[productId]!) {
        if (review.id == reviewId) {
          return review;
        }
      }
    }
    return null;
  }

  Stream<List<Review>> getAllReviewsStreamForProductId(
      String productId) async* {
    if (_reviews.containsKey(productId)) {
      yield _reviews[productId]!; // Yield initial reviews
      // In a real application with a database listener, you would yield new data
      // whenever the reviews for the product change in the database.
      // Here, we just yield the data once for simplicity.
    } else {
      yield [];
    }
  }

  Future<Product?> getProductWithID(String productId) async {
    return _products[productId];
  }

  Future<String> addUsersProduct(Product product) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    product = product.copyWith(owner: uid);
    String productId = DateTime.now().millisecondsSinceEpoch.toString();
    _products[productId] = product;

    // Update search tags
    List<String> searchTags = List.from(product.searchTags);
    searchTags
        .add(EnumToString.convertToString(product.productType).toLowerCase());
    _products[productId] = product.copyWith(searchTags: searchTags);
    return productId;
  }

  Future<bool> deleteUserProduct(String productId) async {
    if (_products.containsKey(productId)) {
      _products.remove(productId);
      _reviews.remove(productId); // Also remove reviews for the product
      return true;
    } else {
      throw Exception("Product not found");
    }
  }

  Future<String> updateUsersProduct(Product product) async {
    if (_products.containsKey(product.id)) {
      // Keep existing images if not provided
      List<String> images = product.images.isNotEmpty
          ? product.images
          : _products[product.id]!.images;

      // Keep existing rating if not provided
      double rating = product.rating.toDouble() != 0.0
          ? product.rating.toDouble()
          : _products[product.id]!.rating.toDouble();

      _products[product.id] = product.copyWith(images: images, rating: rating);

      // Update search tags
      List<String> searchTags = List.from(product.searchTags);
      searchTags
          .add(EnumToString.convertToString(product.productType).toLowerCase());
      _products[product.id] =
          _products[product.id]!.copyWith(searchTags: searchTags);

      return product.id;
    } else {
      throw Exception("Product not found");
    }
  }

  Future<List<String>> getCategoryProductsList(ProductType productType) async {
    List<String> productsId = [];
    for (var entry in _products.entries) {
      if (entry.value.productType == productType) {
        productsId.add(entry.key);
      }
    }
    return productsId;
  }

  Future<List<String>> get usersProductsList async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    List<String> usersProducts = [];
    for (var entry in _products.entries) {
      if (entry.value.owner == uid) {
        usersProducts.add(entry.key);
      }
    }
    return usersProducts;
  }

  Future<List<String>> get allProductsList async {
    return _products.keys.toList();
  }

  Future<bool> updateProductsImages(
      String productId, List<String> imgUrl) async {
    if (_products.containsKey(productId)) {
      _products[productId] = _products[productId]!.copyWith(images: imgUrl);
      return true;
    } else {
      throw Exception("Product not found");
    }
  }

  // For the fake implementation, we don't need a real path
  String getPathForProductImage(String id, int index) {
    return "fake_image_path/$id\_$index";
  }
}
