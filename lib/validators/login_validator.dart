import 'dart:async';

class LoginValidator {
  final validateEmail =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    email.contains("@")
        ? sink.add(email)
        : sink.addError("Insira um e-mail válido");
  });
  final validatePass =
      StreamTransformer<String, String>.fromHandlers(handleData: (pass, sink) {
    pass.length > 4
        ? sink.add(pass)
        : sink.addError("A senha deve conter pelo menos 4 caracteres");
  });
}
