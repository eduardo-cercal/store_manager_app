import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/product_bloc.dart';
import 'package:gerente_loja/validators/product_validator.dart';
import 'package:gerente_loja/widgets/image_widget.dart';
import 'package:gerente_loja/widgets/product_size.dart';

class ProductScreen extends StatefulWidget {
  final String categoryId;
  final DocumentSnapshot? product;

  const ProductScreen({required this.categoryId, this.product, Key? key})
      : super(key: key);

  @override
  State<ProductScreen> createState() =>
      _ProductScreenState(categoryId, product);
}

class _ProductScreenState extends State<ProductScreen> with ProductValidator {
  final formKey = GlobalKey<FormState>();
  final ProductBloc productBloc;

  _ProductScreenState(String categoryId, DocumentSnapshot? product)
      : productBloc = ProductBloc(product: product, categoryId: categoryId);

  @override
  Widget build(BuildContext context) {
    InputDecoration buildDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
      );
    }

    const fieldStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
    );
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        elevation: 0,
        title: StreamBuilder<bool>(
            stream: productBloc.outCreate,
            initialData: false,
            builder: (context, snapshot) {
              return Text(
                  snapshot.data == true ? "Ediatar produto" : "Criar Produto");
            }),
        actions: [
          StreamBuilder<bool>(
            stream: productBloc.outCreate,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return StreamBuilder<bool>(
                    stream: productBloc.outLoading,
                    initialData: false,
                    builder: (context, snapshot) {
                      return IconButton(
                        onPressed: snapshot.data == true
                            ? () {
                                productBloc.deleteProduct();
                                Navigator.of(context).pop();
                              }
                            : null,
                        icon: const Icon(Icons.remove),
                      );
                    });
              } else {
                return Container();
              }
            },
          ),
          StreamBuilder<bool>(
              stream: productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IconButton(
                  onPressed: snapshot.data == true
                      ? () {
                          productBloc.saveProduct();
                          Navigator.of(context).pop();
                        }
                      : null,
                  icon: const Icon(Icons.save),
                );
              }),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: StreamBuilder<Map>(
                stream: productBloc.outData,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          "Images",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        ImagesWidget(
                          context: context,
                          onSaved: productBloc.saveImage,
                          validator: validateImages,
                          initialValue: snapshot.data!["images"],
                        ),
                        TextFormField(
                          initialValue: snapshot.data!["title"],
                          style: fieldStyle,
                          decoration: buildDecoration("Título"),
                          onSaved: productBloc.saveTitle,
                          validator: validateTitle,
                        ),
                        TextFormField(
                          initialValue: snapshot.data!["description"],
                          style: fieldStyle,
                          maxLines: 6,
                          decoration: buildDecoration("Descrição"),
                          onSaved: productBloc.saveDescription,
                          validator: validateDescription,
                        ),
                        TextFormField(
                          initialValue:
                              snapshot.data!["price"]?.toStringAsFixed(2),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: fieldStyle,
                          decoration: buildDecoration("Preço"),
                          onSaved: productBloc.savePrice,
                          validator: validatePrice,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          "Tamanhos",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        ProductSize(
                            context: context,
                            initalValue: snapshot.data!["sizes"],
                            onSaved: productBloc.saveSize,
                            validator: (l) {
                              if (l == null) {
                                return "Adicione um tamanho";
                              }
                            }),
                      ],
                    );
                  }
                }),
          ),
          StreamBuilder<bool>(
              stream: productBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IgnorePointer(
                  ignoring: !snapshot.hasData,
                  child: Container(
                    color:
                        snapshot.hasData ? Colors.black54 : Colors.transparent,
                  ),
                );
              }),
        ],
      ),
    );
  }

  void saveProduct() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: const Text(
            "Savando produto...",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          duration: const Duration(minutes: 1),
        ),
      );
      bool succes = await productBloc.saveProduct();
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: succes ? Theme.of(context).primaryColor : Colors.red,
          content: Text(
            succes ? "Produto salvo!" : "Erro ao salvar o produto",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }
}
