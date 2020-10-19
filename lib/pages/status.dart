import 'package:band_names/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketServices  = Provider.of<SocketServices>(context);
    return Scaffold(
      body: Center(
        child:Text('ServerStatus ${ socketServices.serverStatus}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          print('Entrando');
          socketServices.emit('emitir-mensaje',{'name':'Samuel','description':'Este es un test'});
        },
        child: Icon(Icons.message),
        ),
    );
  }
}