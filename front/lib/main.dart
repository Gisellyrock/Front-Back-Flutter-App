import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  int? id;
  String? product_name;
  String? category;
  String? description;
  String? image;
  double? price;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink,
        ),
      ),
      home: const Pagina(),
    );
  }
}

class Pagina extends StatefulWidget {
  const Pagina({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ConteudoPagina();
  }
}

Future<void> cadastrarProduct(int? id, String? productName, String? category,
    String? description, String? image, double? price) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/products'),
      headers: <String, String>{
        'Content-type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'id': id,
        'product_name': productName,
        'category': category,
        'description': description,
        'image': image,
        'price': price,
      }),
    );

    if (response.statusCode == 200) {
      // Produto cadastrado com sucesso
      print('Produto cadastrado com sucesso');
    } else {
      // Tratar erro, se necessário
      print('Erro ao cadastrar produto: ${response.statusCode}');
    }
  } catch (e) {
    // Tratar erro, se necessário
    print('Erro ao cadastrar produto: $e');
  }
}

Future<List<Product>> selecionarProducts() async {
  try {
    final response =
        await http.get(Uri.parse('http://localhost:3000/products'));

    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(response.body);

      List<Product> products = [];

      for (var obj in dados) {
        Product p = Product();
        p.id = obj["id"];
        p.product_name = obj["product_name"];
        p.category = obj["category"];
        p.description = obj["description"];
        p.image = obj["image"];
        p.price = obj["price"].toDouble();

        products.add(p);
      }

      return products;
    } else {
      // Tratar erro, se necessário
      print('Erro ao buscar produtos: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    // Tratar erro, se necessário
    print('Erro ao buscar produtos: $e');
    return [];
  }
}

class ConteudoPagina extends State<Pagina> {
  int? id;
  String? product_name;
  String? category;
  String? description;
  String? image;
  double? price;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consumindo API"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  TextField(
                    onChanged: (valor) {
                      setState(() {
                        id = valor as int?;
                      });
                    },
                    decoration: InputDecoration(labelText: 'ID'),
                  ),
                  TextField(
                    onChanged: (valor) {
                      setState(() {
                        product_name = valor;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Product Name'),
                  ),
                  TextField(
                    onChanged: (valor) {
                      setState(() {
                        category = valor;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                  TextField(
                    onChanged: (valor) {
                      setState(() {
                        description = valor;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    onChanged: (valor) {
                      setState(() {
                        image = valor;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Image'),
                  ),
                  TextField(
                    onChanged: (valor) {
                      setState(() {
                        price = double.tryParse(valor);
                      });
                    },
                    decoration: InputDecoration(labelText: 'Price'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        cadastrarProduct(id, product_name, category,
                            description, image, price);
                      });
                    },
                    child: const Text("Cadastrar"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Product>?>(
                future: selecionarProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  } else if (!snapshot.hasData ||
                      snapshot.data?.isEmpty == true) {
                    return Text('Nenhum produto encontrado.');
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Column(
                            children: [
                              Text("ID: ${snapshot.data![index].id ?? 'N/A'}"),
                              Text(
                                  "Product Name: ${snapshot.data![index].product_name ?? 'N/A'}"),
                              Text(
                                  "Category: ${snapshot.data![index].category ?? 'N/A'}"),
                              Text(
                                  "Description: ${snapshot.data![index].description ?? 'N/A'}"),
                              Text(
                                  "Image: ${snapshot.data![index].image ?? 'N/A'}"),
                              Text(
                                  "Price: ${snapshot.data![index].price ?? 'N/A'}"),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
