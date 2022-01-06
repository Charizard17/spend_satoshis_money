import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/cart.dart';
import '../provider/currencies.dart';

class Recipe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final currency = Provider.of<Currencies>(context, listen: true);
    final _totalAmount = cart.totalAmount;
    var _cartItems = cart.items;
    bool _isDollar = currency.isDollar;
    double _bitcoinPrice = currency.bitcoinPrice;

    var rows = <TableRow>[];
    _cartItems.forEach(((key, value) {
      if (value.quantity != 0) {
        rows.add(TableRow(
          children: [
            Text(
              '${value.title}',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'Raleway',
              ),
            ),
            Text(
              'x${value.quantity}',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'Raleway',
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _isDollar == true
                    ? '\$ ${(value.quantity * value.price).toStringAsFixed(2)}'
                    : '₿ ${(value.quantity * value.price / _bitcoinPrice).toStringAsFixed(8)}',
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
          ],
        ));
      }
    }));

    return Container(
      height: 400,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(
            'Your Receipt',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              fontFamily: 'Raleway',
            ),
          ),
          SizedBox(height: 10),
          Table(
            columnWidths: {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(3),
            },
            children: [
              for (var row in rows) row,
            ],
          ),
          Divider(thickness: 1, color: Colors.black),
          Table(
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Raleway',
                    ),
                  ),
                  Text(
                    _isDollar == true
                        ? '\$ ${_totalAmount}'
                        : '₿ ${(_totalAmount / _bitcoinPrice).toStringAsFixed(8)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
