import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/category_bloc.dart';
import 'package:gerente_loja/widgets/image_source_sheet.dart';

class EditCategoryDialog extends StatefulWidget {
  final DocumentSnapshot? category;

  const EditCategoryDialog({this.category, Key? key}) : super(key: key);

  @override
  State<EditCategoryDialog> createState() =>
      _EditCategoryDialogState(category: category);
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final CategoryBloc categoryBloc;
  final TextEditingController controller;

  _EditCategoryDialogState({DocumentSnapshot? category})
      : categoryBloc = CategoryBloc(category: category),
        controller = TextEditingController(
            text: category != null ? category.get("title") : "");

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) => ImageSourceSheet(
                            onImageSelected: (image) {
                              Navigator.of(context).pop();
                              categoryBloc.setImage(image);
                            },
                          ));
                },
                child: StreamBuilder(
                    stream: categoryBloc.outImage,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: snapshot.data is File
                              ? Image.file(
                                  snapshot.data,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  snapshot.data,
                                  fit: BoxFit.cover,
                                ),
                        );
                      } else {
                        return const Icon(Icons.image);
                      }
                    }),
              ),
              title: StreamBuilder<String>(
                  stream: categoryBloc.outTitle,
                  builder: (context, snapshot) {
                    return TextField(
                      onChanged: categoryBloc.setTitle,
                      controller: controller,
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: InputDecoration(
                          errorText: snapshot.hasError
                              ? snapshot.error.toString()
                              : null),
                    );
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StreamBuilder<bool>(
                    stream: categoryBloc.outDelete,
                    builder: (context, snapshot) {
                      return TextButton(
                          onPressed: snapshot.data == true ? () {
                            categoryBloc.delete();
                          } : null,
                          child: Text(
                            "Exlcuir",
                            style: TextStyle(
                                color: snapshot.data == true
                                    ? Colors.red
                                    : Colors.grey),
                          ));
                    }),
                StreamBuilder<bool>(
                    stream: categoryBloc.submitValid,
                    builder: (context, snapshot) {
                      return TextButton(
                        onPressed: snapshot.hasData ? () async{
                          await categoryBloc.saveData();
                          Navigator.of(context).pop();
                        } : null,
                        child: Text(
                          "Salvar",
                          style:
                              TextStyle(color: snapshot.hasData ?Theme.of(context).primaryColor:Colors.grey),
                        ),
                      );
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
