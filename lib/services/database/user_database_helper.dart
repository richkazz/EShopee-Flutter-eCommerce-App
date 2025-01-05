import 'package:e_commerce_app_flutter/models/Address.dart';
import 'package:e_commerce_app_flutter/models/CartItem.dart';
import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';

class UserDatabaseHelper {
  static const String USERS_COLLECTION_NAME = "users";
  static const String ADDRESSES_COLLECTION_NAME = "addresses";
  static const String CART_COLLECTION_NAME = "cart";
  static const String ORDERED_PRODUCTS_COLLECTION_NAME = "ordered_products";

  static const String PHONE_KEY = 'phone';
  static const String DP_KEY = "display_picture";
  static const String FAV_PRODUCTS_KEY = "favourite_products";

  UserDatabaseHelper._privateConstructor();
  static UserDatabaseHelper _instance =
      UserDatabaseHelper._privateConstructor();
  factory UserDatabaseHelper() {
    return _instance;
  }

  // Fake data storage
  Map<String, Map<String, dynamic>> _users = {}; // UID -> User Data
  Map<String, List<Address>> _addresses = {}; // UID -> List of Addresses
  Map<String, List<String>> _userFavProducts =
      {}; // UID -> List of Favorite Product IDs
  Map<String, List<CartItem>> _cart =
      {}; // UID -> List of Cart Items (simplified to just hold product IDs and counts)
  Map<String, List<OrderedProduct>> _orderedProducts =
      {}; // UID -> List of Ordered Products

  Future<void> createNewUser(String uid) async {
    _users[uid] = {
      DP_KEY: null,
      PHONE_KEY: null,
      FAV_PRODUCTS_KEY: <String>[],
    };
    _addresses[uid] = [];
    _cart[uid] = [];
    _orderedProducts[uid] = [];
    _userFavProducts[uid] = [];
  }

  Future<void> deleteCurrentUserData() async {
    final uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    _cart.remove(uid);
    _addresses.remove(uid);
    _orderedProducts.remove(uid);
    _userFavProducts.remove(uid);
    _users.remove(uid);
  }

  Future<bool> isProductFavourite(String productId) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    final favList = _users[uid]![FAV_PRODUCTS_KEY].cast<String>();
    return favList.contains(productId);
  }

  Future<List<String>> get usersFavouriteProductsList async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    return _userFavProducts[uid] ?? [];
  }

  Future<bool> switchProductFavouriteStatus(
      String productId, bool newState) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    if (newState) {
      if (_userFavProducts[uid] == null) {
        _userFavProducts[uid] = [];
      }
      if (!_userFavProducts[uid]!.contains(productId)) {
        _userFavProducts[uid]!.add(productId);
      }
    } else {
      _userFavProducts[uid]?.remove(productId);
    }
    return true;
  }

  Future<List<String>> get addressesList async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    final addresses = _addresses[uid] ?? [];
    final addressesId =
        List<String>.generate(addresses.length, (index) => index.toString());

    return addressesId;
  }

  Future<Address> getAddressFromId(String id) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    final addresses = _addresses[uid] ?? [];
    if (id.isNotEmpty && addresses.length > int.parse(id)) {
      return addresses[int.parse(id)];
    } else {
      throw Exception("Address not found");
    }
  }

  Future<bool> addAddressForCurrentUser(Address address) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    if (_addresses[uid] == null) {
      _addresses[uid] = [];
    }
    _addresses[uid]!.add(address);
    return true;
  }

  Future<bool> deleteAddressForCurrentUser(String id) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    if (id.isNotEmpty &&
        _addresses[uid] != null &&
        _addresses[uid]!.length > int.parse(id)) {
      _addresses[uid]!.removeAt(int.parse(id));
      return true;
    } else {
      throw Exception("invalid id");
    }
  }

  Future<bool> updateAddressForCurrentUser(Address address) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    if (address.id != null &&
        _addresses[uid] != null &&
        _addresses[uid]!.length > int.parse(address.id!)) {
      _addresses[uid]![int.parse(address.id!)] = address;
      return true;
    } else {
      throw Exception("invalid id");
    }
  }

  Future<CartItem> getCartItemFromId(String id) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    final cartItems = _cart[uid] ?? [];
    if (id.isNotEmpty && cartItems.length > int.parse(id)) {
      return cartItems[int.parse(id)];
    } else {
      throw Exception("CartItem not found");
    }
  }

  Future<bool> addProductToCart(String productId) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    if (_cart[uid] == null) {
      _cart[uid] = [];
    }

    // Check if product already exists in cart
    bool found = false;
    for (int i = 0; i < _cart[uid]!.length; i++) {
      if (_cart[uid]![i].id == productId) {
        // Increase item count if found
        _cart[uid]![i] =
            _cart[uid]![i].copyWith(itemCount: _cart[uid]![i].itemCount + 1);
        found = true;
        break;
      }
    }

    if (!found) {
      // Add new CartItem if not found
      _cart[uid]!.add(CartItem(id: productId, itemCount: 1));
    }

    return true;
  }

  Future<List<String>> emptyCart() async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    List<String> orderedProductsUid = [];
    if (_cart[uid] != null) {
      for (final cartItem in _cart[uid]!) {
        orderedProductsUid.add(cartItem.id);
      }
      _cart[uid]!.clear();
    }

    return orderedProductsUid;
  }

  Future<num> get cartTotal async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    num total = 0.0;
    if (_cart[uid] != null) {
      for (final cartItem in _cart[uid]!) {
        final product =
            await ProductDatabaseHelper().getProductWithID(cartItem.id);
        if (product != null) {
          total += (cartItem.itemCount * product.discountPrice);
        }
      }
    }

    return total;
  }

  Future<bool> removeProductFromCart(String cartItemID) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    if (_cart[uid] != null) {
      if (cartItemID.isNotEmpty && _cart[uid]!.length > int.parse(cartItemID)) {
        _cart[uid]!.removeAt(int.parse(cartItemID));
      }
    }

    return true;
  }

  Future<bool> increaseCartItemCount(String cartItemID) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    if (_cart[uid] != null) {
      if (cartItemID.isNotEmpty && _cart[uid]!.length > int.parse(cartItemID)) {
        _cart[uid]![int.parse(cartItemID)] = _cart[uid]![int.parse(cartItemID)]
            .copyWith(
                itemCount: _cart[uid]![int.parse(cartItemID)].itemCount + 1);
      }
    }

    return true;
  }

  Future<bool> decreaseCartItemCount(String cartItemID) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    if (_cart[uid] != null) {
      if (cartItemID.isNotEmpty && _cart[uid]!.length > int.parse(cartItemID)) {
        final currentCount = _cart[uid]![int.parse(cartItemID)].itemCount;
        if (currentCount <= 1) {
          return removeProductFromCart(cartItemID);
        } else {
          _cart[uid]![int.parse(cartItemID)] =
              _cart[uid]![int.parse(cartItemID)].copyWith(
                  itemCount: _cart[uid]![int.parse(cartItemID)].itemCount - 1);
        }
      }
    }

    return true;
  }

  Future<List<String>> get allCartItemsList async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    List<String> itemsId = [];
    if (_cart[uid] != null) {
      for (int i = 0; i < _cart[uid]!.length; i++) {
        itemsId.add(i.toString());
      }
    }

    return itemsId;
  }

  Future<List<String>> get orderedProductsList async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    List<String> orderedProductsId = [];
    if (_orderedProducts[uid] != null) {
      for (int i = 0; i < _orderedProducts[uid]!.length; i++) {
        orderedProductsId.add(i.toString());
      }
    }

    return orderedProductsId;
  }

  Future<bool> addToMyOrders(List<OrderedProduct> orders) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    if (_orderedProducts[uid] == null) {
      _orderedProducts[uid] = [];
    }
    _orderedProducts[uid]!.addAll(orders);

    return true;
  }

  Future<OrderedProduct> getOrderedProductFromId(String id) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    if (_orderedProducts[uid] != null &&
        id.isNotEmpty &&
        _orderedProducts[uid]!.length > int.parse(id)) {
      return _orderedProducts[uid]![int.parse(id)];
    } else {
      throw Exception("Ordered product not found");
    }
  }

  // For simplicity, we'll just emit a value whenever we think the user data might have changed.
  // In a real app with listeners, you would emit specific changes.
  Stream<Map<String, dynamic>> get currentUserDataStream async* {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    // Emit the current user data
    yield _users[uid] ?? {};

    // You can add more logic here to emit new data when something changes,
    // but for this fake implementation, we'll keep it simple.
  }

  Future<bool> updatePhoneForCurrentUser(String phone) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    _users[uid]![PHONE_KEY] = phone;
    return true;
  }

  // We'll just return a fake path for the display picture
  String getPathForCurrentUserDisplayPicture() {
    final String? currentUserUid = AuthentificationService().currentUser?.uid;
    if (currentUserUid == null) {
      throw Exception("User not logged in");
    }

    return "fake_user/display_picture/$currentUserUid";
  }

  Future<bool> uploadDisplayPictureForCurrentUser(String url) async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    _users[uid]![DP_KEY] = url;
    return true;
  }

  Future<bool> removeDisplayPictureForCurrentUser() async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    _users[uid]![DP_KEY] = null;
    return true;
  }

  Future<String?> get displayPictureForCurrentUser async {
    String? uid = AuthentificationService().currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    return _users[uid]![DP_KEY];
  }
}
