// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:e_commerce_app_flutter/models/Model.dart';

class CartItem extends Model {
  static const String PRODUCT_ID_KEY = "product_id";
  static const String ITEM_COUNT_KEY = "item_count";

  int itemCount;
  CartItem({
    required String id,
    this.itemCount = 0,
  }) : super(id);

  factory CartItem.fromMap(Map<String, dynamic> map, {required String id}) {
    return CartItem(
      id: id,
      itemCount: map[ITEM_COUNT_KEY],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ITEM_COUNT_KEY: itemCount,
    };
    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    map[ITEM_COUNT_KEY] = itemCount;
    return map;
  }

  CartItem copyWith({
    String? id,
    int? itemCount,
  }) {
    return CartItem(
      id: id ?? this.id,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}
