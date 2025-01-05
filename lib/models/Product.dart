// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:enum_to_string/enum_to_string.dart';

import 'package:e_commerce_app_flutter/models/Model.dart';

enum ProductType {
  Electronics,
  Books,
  Fashion,
  Groceries,
  Art,
  Others,
}

class Product extends Model {
  static const String IMAGES_KEY = "images";
  static const String TITLE_KEY = "title";
  static const String VARIANT_KEY = "variant";
  static const String DISCOUNT_PRICE_KEY = "discount_price";
  static const String ORIGINAL_PRICE_KEY = "original_price";
  static const String RATING_KEY = "rating";
  static const String HIGHLIGHTS_KEY = "highlights";
  static const String DESCRIPTION_KEY = "description";
  static const String SELLER_KEY = "seller";
  static const String OWNER_KEY = "owner";
  static const String PRODUCT_TYPE_KEY = "product_type";
  static const String SEARCH_TAGS_KEY = "search_tags";

  List<String> images;
  String title;
  String variant;
  num discountPrice;
  num originalPrice;
  num rating;
  String highlights;
  String description;
  String seller;
  bool? favourite;
  String owner;
  ProductType? productType;
  List<String> searchTags;

  Product(
    String id, {
    required this.images,
    required this.title,
    required this.variant,
    this.productType,
    required this.discountPrice,
    required this.originalPrice,
    this.rating = 0.0,
    required this.highlights,
    required this.description,
    required this.seller,
    required this.owner,
    required this.searchTags,
  }) : super(id);

  int calculatePercentageDiscount() {
    int discount =
        (((originalPrice - discountPrice) * 100) / originalPrice).round();
    return discount;
  }

  factory Product.fromMap(Map<String, dynamic> map, {required String id}) {
    if (map[SEARCH_TAGS_KEY] == null) {
      map[SEARCH_TAGS_KEY] = [];
    }
    return Product(
      id,
      images: (map[IMAGES_KEY] ?? []).cast<String>(),
      title: map[TITLE_KEY],
      variant: map[VARIANT_KEY],
      productType:
          EnumToString.fromString(ProductType.values, map[PRODUCT_TYPE_KEY]),
      discountPrice: map[DISCOUNT_PRICE_KEY],
      originalPrice: map[ORIGINAL_PRICE_KEY],
      rating: map[RATING_KEY],
      highlights: map[HIGHLIGHTS_KEY],
      description: map[DESCRIPTION_KEY],
      seller: map[SELLER_KEY],
      owner: map[OWNER_KEY],
      searchTags: map[SEARCH_TAGS_KEY].cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      IMAGES_KEY: images,
      TITLE_KEY: title,
      VARIANT_KEY: variant,
      PRODUCT_TYPE_KEY: EnumToString.convertToString(productType),
      DISCOUNT_PRICE_KEY: discountPrice,
      ORIGINAL_PRICE_KEY: originalPrice,
      RATING_KEY: rating,
      HIGHLIGHTS_KEY: highlights,
      DESCRIPTION_KEY: description,
      SELLER_KEY: seller,
      OWNER_KEY: owner,
      SEARCH_TAGS_KEY: searchTags,
    };

    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    map[IMAGES_KEY] = images;
    map[TITLE_KEY] = title;
    map[VARIANT_KEY] = variant;
    map[DISCOUNT_PRICE_KEY] = discountPrice;
    map[ORIGINAL_PRICE_KEY] = originalPrice;
    map[RATING_KEY] = rating;
    map[HIGHLIGHTS_KEY] = highlights;
    map[DESCRIPTION_KEY] = description;
    map[SELLER_KEY] = seller;
    map[PRODUCT_TYPE_KEY] = EnumToString.convertToString(productType);
    map[OWNER_KEY] = owner;
    map[SEARCH_TAGS_KEY] = searchTags;

    return map;
  }

  Product copyWith({
    List<String>? images,
    String? id,
    String? title,
    String? variant,
    num? discountPrice,
    num? originalPrice,
    num? rating,
    String? highlights,
    String? description,
    String? seller,
    bool? favourite,
    String? owner,
    List<String>? searchTags,
  }) {
    return Product(
      id ?? this.id,
      images: images ?? this.images,
      title: title ?? this.title,
      variant: variant ?? this.variant,
      discountPrice: discountPrice ?? this.discountPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      highlights: highlights ?? this.highlights,
      description: description ?? this.description,
      seller: seller ?? this.seller,
      owner: owner ?? this.owner,
      searchTags: searchTags ?? this.searchTags,
    );
  }
}
