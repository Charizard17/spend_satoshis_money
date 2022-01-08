import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../provider/cart.dart';
import '../provider/currencies.dart';

class Receipt extends StatefulWidget {
  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  final controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final currency = Provider.of<Currencies>(context, listen: true);
    final _totalAmount = cart.totalAmount;
    var _cartItems = cart.items;
    double _satoshisBitcoins = cart.satoshisBitcoins;
    bool _isDollar = currency.isDollar;
    double _bitcoinPrice = currency.bitcoinPrice;
    final dollarFormat = currency.dollarFormat;
    final bitcoinFormat = currency.bitcoinFormat;

    var rows = <TableRow>[];
    _cartItems.forEach(((key, value) {
      if (value.quantity != 0) {
        rows.add(TableRow(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${value.title}',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Raleway',
                  color: Colors.black,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  'x${value.quantity}',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Raleway',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _isDollar == true
                    ? '\$ ${dollarFormat.format(value.quantity * value.price)}'
                    : '₿ ${bitcoinFormat.format(value.quantity * value.price / _bitcoinPrice)}',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Raleway',
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ));
      }
    }));

    return Column(
      children: [
        Text(
          'Your Receipt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Raleway',
          ),
        ),
        SizedBox(height: 5),
        Container(
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
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
              ],
            ),
          ),
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
                      ? '\$ ${dollarFormat.format(_totalAmount)}'
                      : '₿ ${bitcoinFormat.format(_totalAmount / _bitcoinPrice)}',
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
        Row(
          children: [
            ElevatedButton(
              child: Text('Save to Gallery'),
              onPressed: () async {
                final image = await controller.captureFromWidget(
                  widgetToScreenshot(
                    rows,
                    _isDollar,
                    dollarFormat,
                    bitcoinFormat,
                    _totalAmount,
                    _bitcoinPrice,
                    _satoshisBitcoins,
                  ),
                );
                if (image == null) return;

                await saveImage(image);
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();

    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'screenshot_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    return result['filePath'];
  }

  Widget widgetToScreenshot(rows, _isDollar, dollarFormat, bitcoinFormat,
          _totalAmount, _bitcoinPrice, _satoshisBitcoins) =>
      MaterialApp(
        home: Scaffold(
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white,
                  Colors.grey,
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 350,
                  margin: const EdgeInsets.all(5.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    border: Border.all(
                        width: 2, color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: AssetImage(
                            'assets/images/satoshi-nakamoto-reverse.png'),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                'Satoshi Nakamoto\'s Bitcoins',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Revamped',
                                ),
                              ),
                            ),
                            Text(
                              _isDollar == true
                                  ? '\$ ${dollarFormat.format(_satoshisBitcoins * _bitcoinPrice)}'
                                  : '₿ ${bitcoinFormat.format(_satoshisBitcoins)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Raleway',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Your Receipt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway',
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 400,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
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
                      ],
                    ),
                  ),
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
                            fontSize: 16,
                            fontFamily: 'Raleway',
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _isDollar == true
                              ? '\$ ${dollarFormat.format(_totalAmount)}'
                              : '₿ ${bitcoinFormat.format(_totalAmount / _bitcoinPrice)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Raleway',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
