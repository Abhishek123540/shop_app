import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  //var _showFavouritesOnly = false;

  List<Product> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  List<Product> get items {
    // if (_showFavouritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavourite).toList();
    // }
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProduct() async {
    final url = Uri.parse(
        'https://shop-app-22c27-default-rtdb.firebaseio.com/products.json');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavourite: prodData['isFavourite']));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      throw (e);
    }
  }

  // void showFavouritesOnly() {
  //   _showFavouritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavouritesOnly = false;
  //   notifyListeners();
  // }

  // Future<void> addProduct(Product product) {
  //   final url = Uri.parse(
  //       'https://shop-app-22c27-default-rtdb.firebaseio.com/products.json');
  //   return http
  //       .post(
  //     url,
  //     body: jsonEncode(
  //       {
  //         'title': product.title,
  //         'description': product.description,
  //         'imageUrl': product.imageUrl,
  //         'price': product.price,
  //         'isFavourite': product.isFavourite,
  //       },
  //     ),
  //   )
  //       .then(
  //     (response) {
  //       final newProduct = Product(
  //         title: product.title,
  //         description: product.description,
  //         price: product.price,
  //         imageUrl: product.imageUrl,
  //         //id: jsonDecode(response.body)['name'],
  //         id: json.decode(response.body)['name'],
  //       );
  //       _items.add(newProduct);
  //       //_items.insert(0, newProduct); // To add at the start of the list
  //       notifyListeners();
  //     },
  //   ).catchError((error) {
  //     print(error);
  //     throw error;
  //   });
  // }
  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-22c27-default-rtdb.firebaseio.com/products.json');
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavourite': product.isFavourite,
          },
        ),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://shop-app-22c27-default-rtdb.firebaseio.com/products/$id.json');
      await http.patch(url,
          body: jsonEncode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shop-app-22c27-default-rtdb.firebaseio.com/products/$id.json');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    // _items.removeWhere((prod) => prod.id == id);
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
    // _items.removeAt(existingProductIndex);
  }
}
//  Future deleteProduct(String id) async {
//     final url = Uri.parse(
//         'https://shop-app-22c27-default-rtdb.firebaseio.com/products/$id.j');
//     final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
//     var existingProduct = _items[existingProductIndex];
//     _items.removeAt(existingProductIndex);
//     // _items.removeWhere((prod) => prod.id == id);
//    await http.delete(url).then((response) {
//       if (response.statusCode >= 400) {
//         throw HttpException('Could not delete product.');
//       }
//       existingProduct = null;
//     }).catchError((_) {
//       _items.insert(existingProductIndex, existingProduct);
//       notifyListeners();
//     });
//     // _items.removeAt(existingProductIndex);
//     notifyListeners();
//   }
