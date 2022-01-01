import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/currencies.dart';
import '../provider/cart.dart';

class ProductItem extends StatefulWidget {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  ProductItem(this.id, this.title, this.price, this.imageUrl);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  int _itemQuantity = 0;
  int _quantity = 0;

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<Currencies>(context, listen: true);
    bool _isDollar = currency.isDollar;
    double _bitcoinPrice = currency.bitcoinPrice;
    final cart = Provider.of<Cart>(context, listen: true);

    cart.items.forEach((key, item) {
      if (item.productId == widget.id) {
        setState(() {
          _quantity = item.quantity;
        });
      }
    });

    _sellItem() {
      cart.sellItem(widget.id, widget.price, widget.title);
    }

    return Container(
      width: double.infinity,
      height: 140,
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).backgroundColor,
        border: Border.all(
          width: 3,
          color: Colors.orange,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image(
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                image: AssetImage(widget.imageUrl),
              ),
              Column(
                children: [
                  SizedBox(height: 10),
                  Text(widget.title),
                  SizedBox(height: 10),
                  _isDollar == true
                      ? Text('Price: \$${widget.price}')
                      : Text(
                          'Price: ₿${(widget.price / _bitcoinPrice).toStringAsFixed(8)}'),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).disabledColor,
                    onSurface: Theme.of(context).disabledColor,
                    fixedSize: Size(110, 30),
                  ),
                  child: Text(
                    'Sell',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onPressed: _quantity > 0
                      ? () {
                          cart.sellItem(widget.id, widget.price, widget.title);
                        }
                      : null,
                ),
                Container(
                  height: 35,
                  width: 110,
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${_quantity > 0 ? _quantity : _itemQuantity}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    fixedSize: Size(110, 30),
                  ),
                  child: Text(
                    'Buy',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    cart.buyItem(widget.id, widget.price, widget.title);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
