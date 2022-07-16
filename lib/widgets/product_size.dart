import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/widgets/add_size_dialog.dart';

class ProductSize extends FormField<List> {
  ProductSize({
    Key? key,
    required BuildContext context,
    required List initalValue,
    required FormFieldSetter<List> onSaved,
    required FormFieldValidator<List> validator,
  }) : super(
            key: key,
            initialValue: initalValue,
            onSaved: onSaved,
            validator: validator,
            builder: (state) {
              return SizedBox(
                height: 34,
                child: GridView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.5,
                  ),
                  children: state.value!.map<Widget>((s) {
                    return GestureDetector(
                      onLongPress: () {
                        state.didChange(state.value!..remove(s));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            border: Border.all(
                              width: 3,
                              color: Theme.of(context).primaryColor,
                            )),
                        alignment: Alignment.center,
                        child: Text(
                          s,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList()
                    ..add(
                      GestureDetector(
                        onTap: () async {
                          String? size = await showDialog(
                              context: context,
                              builder: (context) => AddSizeDialog());
                          if (size != null) {
                            state.didChange(state.value!..add(size));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              border: Border.all(
                                width: 3,
                                color: state.hasError
                                    ? Colors.red
                                    : Theme.of(context).primaryColor,
                              )),
                          alignment: Alignment.center,
                          child: const Text(
                            "+",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ),
              );
            });
}
