import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool obscure;
  final Stream<String> stream;
  final Function(String) onChanged;

  const InputField(
      {required this.hint,
      required this.obscure,
      required this.icon,
      required this.stream,
      required this.onChanged,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: stream,
        builder: (context, snapshot) {
          return TextField(
            onChanged: onChanged,
            cursorColor: Theme.of(context).primaryColor,
            obscureText: obscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                left: 5,
                right: 30,
                bottom: 30,
                top: 30,
              ),
              hintText: hint,
              icon: Icon(
                icon,
                color: Colors.white,
              ),
              hintStyle: const TextStyle(color: Colors.white),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              errorText: snapshot.hasError ? snapshot.error.toString() : null,
            ),
          );
        });
  }
}
