import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gerente_loja/blocs/order_bloc.dart';
import 'package:gerente_loja/blocs/user_bloc.dart';
import 'package:gerente_loja/tabs/orders_tab.dart';
import 'package:gerente_loja/tabs/product_tab.dart';
import 'package:gerente_loja/tabs/user_tab.dart';
import 'package:gerente_loja/widgets/edit_category_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController pageController;
  int page = 0;
  late UserBloc userBloc;
  late OrderBloc orderBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
    userBloc = UserBloc();
    orderBloc = OrderBloc();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: page,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        onTap: (p) {
          pageController.animateToPage(
            p,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Clientes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Pedidos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Produtos",
          ),
        ],
      ),
      body: SafeArea(
        child: BlocProvider(
          blocs: [
            Bloc((i) => UserBloc()),
            Bloc((i) => OrderBloc()),
          ],
          dependencies: const [],
          child: PageView(
            onPageChanged: (p) {
              setState(() {
                page = p;
              });
            },
            controller: pageController,
            children: const [
              UserTab(),
              OrdersTab(),
              ProductTab(),
            ],
          ),
        ),
      ),
      floatingActionButton: buildFloating(),
    );
  }

  Widget buildFloating() {
    switch (page) {
      case 0:
        return Container();
      case 1:
        return SpeedDial(
          child: const Icon(Icons.sort),
          backgroundColor: Theme.of(context).primaryColor,
          overlayOpacity: 0.4,
          overlayColor: Colors.black,
          children: [
            SpeedDialChild(
                child: Icon(
                  Icons.arrow_downward,
                  color: Theme.of(context).primaryColor,
                ),
                backgroundColor: Colors.white,
                label: "Concluidos Abaixo",
                labelStyle: const TextStyle(fontSize: 14),
                onTap: () {
                  orderBloc.setOrderCriteria(SortCriteria.READY_LAST);
                }),
            SpeedDialChild(
                child: Icon(
                  Icons.arrow_upward,
                  color: Theme.of(context).primaryColor,
                ),
                backgroundColor: Colors.white,
                label: "Concluidos Acima",
                labelStyle: const TextStyle(fontSize: 14),
                onTap: () {
                  orderBloc.setOrderCriteria(SortCriteria.READY_FIRST);
                })
          ],
        );
      case 2:
        return FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context, builder: (context) => EditCategoryDialog());
          },
          child: const Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
        );
      default:
        return Container();
    }
  }
}
