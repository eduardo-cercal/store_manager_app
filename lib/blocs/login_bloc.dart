import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gerente_loja/validators/login_validator.dart';
import 'package:rxdart/rxdart.dart';

enum LoginState { IDLE, LOADING, SUCCESS, FAIL }

class LoginBlock extends BlocBase with LoginValidator {
  final emailController = BehaviorSubject<String>();
  final passController = BehaviorSubject<String>();
  final stateController = BehaviorSubject<LoginState>();

  Stream<String> get outEmail =>
      emailController.stream.transform(validateEmail);

  Stream<String> get outPass => passController.stream.transform(validatePass);

  Stream<LoginState> get outState => stateController.stream;

  Stream<bool> get outSubmitValid =>
      Rx.combineLatest2(outEmail, outPass, (a, b) => true);

  Function(String) get changeEmail => emailController.sink.add;

  Function(String) get changePass => passController.sink.add;

  late StreamSubscription subscription;

  LoginBlock() {
    subscription =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        if (await verifyPrivileges(user)) {
          stateController.add(LoginState.SUCCESS);
        } else {
          FirebaseAuth.instance.signOut();
          stateController.add(LoginState.FAIL);
        }
      } else {
        stateController.add(LoginState.IDLE);
      }
    });
  }

  Future<bool> verifyPrivileges(User user) async {
    return await FirebaseFirestore.instance
        .collection("admins")
        .doc(user.uid)
        .get()
        .then((doc) {
      return doc.data() != null ? true : false;
    }).catchError((e) {
      return false;
    });
  }

  void submit() {
    final email = emailController.value;
    final pass = passController.value;

    stateController.add(LoginState.LOADING);

    FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: pass,
    )
        .catchError((e) {
      stateController.add(LoginState.FAIL);
    });
  }

  @override
  void dispose() {
    super.dispose();
    emailController.close();
    passController.close();
    stateController.close();
    subscription.cancel();
  }
}
