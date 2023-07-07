import 'dart:convert';
import 'package:crud/edi.dart';
import 'package:intl/intl.dart';
import 'package:crud/product.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  bool inProgress = false;
  @override
  void initState() {
    super.initState();

    getProducts();
  }

  void getProducts() async {
    inProgress = true;
    setState(() {});
    Response response =
        await get(Uri.parse('https://crud.teamrabbil.com/api/v1/ReadProduct'));
    final Map<String, dynamic> decodeResponse = jsonDecode(response.body);
    if (response.statusCode == 200 && decodeResponse['status'] == 'success') {
      for (var pFJ in decodeResponse['data']) {
        products.add(Product.toJson(pFJ));
      }
    }
    inProgress = false;
    setState(() {});
  }

  void refreshProducts() {
    setState(() {
      inProgress = true;
      //products.clear();
    });
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        title: Text('C R U D'),
        actions: [
          IconButton(
              onPressed: refreshProducts, icon: Icon(FontAwesomeIcons.plus)),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
                onPressed: refreshProducts,
                icon: Icon(FontAwesomeIcons.arrowRotateRight)),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: const Icon(Icons.add),
      // ),
      body: inProgress
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.separated(
              itemCount: products.length,
              itemBuilder: ((context, index) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ListTile(
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return buildBottomSheetContent(context);
                        },
                      );
                    },
                    title: Text(products[index].productName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product id: ${products[index].id}'),
                        Text('Product Code: ${products[index].productCode}'),
                        Text(
                            'Added Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(products[index].createdDate))}'),
                      ],
                    ),
                    leading: Image.network(
                      products[index].image,
                      width: 50,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.photo,
                          size: 30,
                        );
                      },
                    ),
                    trailing: Column(children: [
                      Text('Quantity: ${products[index].quantity}'),
                      Text('Unit Price: ${products[index].unitPrice}/p'),
                      Text('Total Price: ${products[index].totalPrice}'),
                    ]),
                  ),
                );
              }),
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              }),
    );
  }
}
