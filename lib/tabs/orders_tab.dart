import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerente_loja/blocs/order_bloc.dart';
import 'package:gerente_loja/widgets/order_tile.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderBloc = BlocProvider.getBloc<OrderBloc>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: StreamBuilder<List>(
          stream: orderBloc.outOrder,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
            } else if (snapshot.data!.isNotEmpty) {
              return Center(
                child: Text(
                  "Nenhum pedido encontrado!",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return OrderTile(order: snapshot.data![index],);
                },
              );
            }
          }),
    );
  }
}
