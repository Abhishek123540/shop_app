import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/cart.dart' show Cart;
import 'package:shopping_app/providers/orders.dart';
import 'package:shopping_app/widgets/app_drawer.dart';

import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const rountName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      //drawer: AppDrawer(),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                    onPressed: () {
                      Provider.of<Orders>(context, listen: false).addOrders(
                        cart.item.values.toList(),
                        cart.totalAmount,
                      );
                      cart.clear();
                    },
                    child: Text('ORDER NOW'),
                    style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(
                          Theme.of(context).primaryColor),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (ctx, i) => CartItem(
                cart.item.values.toList()[i].id,
                cart.item.keys.toList()[i],
                cart.item.values.toList()[i].price,
                cart.item.values.toList()[i].quantity,
                cart.item.values.toList()[i].title,
              ),
            ),
          )
        ],
      ),
    );
  }
}
