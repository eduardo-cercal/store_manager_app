import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/login_bloc.dart';
import 'package:gerente_loja/screens/home.dart';
import 'package:gerente_loja/widgets/input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final loginBloc = LoginBlock();

  @override
  void initState() {
    super.initState();
    loginBloc.outState.listen((state) {
      switch (state) {
        case LoginState.SUCCESS:
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()));
          break;
        case LoginState.FAIL:
          showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                    title: Text("Erro"),
                    content: Text("Você não possui os privilegios necessários"),
                  ));
          break;
        case LoginState.LOADING:
        case LoginState.IDLE:
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    loginBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: StreamBuilder<LoginState>(
          stream: loginBloc.outState,
          initialData: LoginState.LOADING,
          builder: (context, snapshot) {
            switch (snapshot.data) {
              case LoginState.LOADING:
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              case LoginState.FAIL:
              case LoginState.SUCCESS:
              case LoginState.IDLE:
                return Stack(alignment: Alignment.center, children: [
                  Container(),
                  SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.store_mall_directory,
                            color: Theme.of(context).primaryColor,
                            size: 160,
                          ),
                          InputField(
                            hint: "Usuário",
                            obscure: false,
                            icon: Icons.person_outline,
                            stream: loginBloc.outEmail,
                            onChanged: loginBloc.changeEmail,
                          ),
                          InputField(
                            hint: "Senha",
                            obscure: true,
                            icon: Icons.lock_outlined,
                            stream: loginBloc.outPass,
                            onChanged: loginBloc.changePass,
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          StreamBuilder<bool>(
                              stream: loginBloc.outSubmitValid,
                              builder: (context, snapshot) {
                                return SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                              (Set<MaterialState> states) {
                                        return snapshot.hasData
                                            ? Theme.of(context).primaryColor
                                            : Colors.deepPurple[300];
                                      }),
                                    ),
                                    onPressed: snapshot.hasData
                                        ? loginBloc.submit
                                        : null,
                                    child: const Text(
                                      "Entrar",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ]);
              default:
                return Container();
            }
          }),
    );
  }
}
