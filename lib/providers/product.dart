import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });
  void toggleFavouriteStatus(String id) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url = Uri.parse(
        'https://shop-app-22c27-default-rtdb.firebaseio.com/products/$id.json');
    try {
      final response = await http.patch(
        url,
        body: jsonEncode({
          'isFavourite': isFavourite,
        }),
      );
      if (response.statusCode >= 400) {
        isFavourite =oldStatus;
        notifyListeners();
      }
    } catch (e) {
      isFavourite = oldStatus;
      notifyListeners();
    }
  }
}
