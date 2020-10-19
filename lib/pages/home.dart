import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    // TODO: implement initState
    final serverSocket = Provider.of<SocketServices>(context, listen: false);
    serverSocket.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final serverSocket = Provider.of<SocketServices>(context, listen: false);
    serverSocket.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverSocket = Provider.of<SocketServices>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (serverSocket.serverStatus == ServerStatus.Online)
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : Icon(
                    Icons.offline_bolt,
                    color: Colors.red,
                  ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          (bands.isNotEmpty)?
          _showGraph():
          Center(child: Text('No hay bandas disponibles')),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) =>
                  _bandTile(bands[index]),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.add),
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketServices = Provider.of<SocketServices>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        socketServices.emit('delete-band', {'id': band.id});
      },
      background: Container(
          padding: EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  Text(
                    'Delete Band',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ))),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.red[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () {
          print(band.id);
          socketServices.emit('vote-band', {'id': band.id});
        },
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New band name:'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                      child: Text('Add'),
                      elevation: 5,
                      textColor: Colors.blue,
                      onPressed: (() => addBandToList(textController.text)))
                ],
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text('New band name:'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Add'),
                onPressed: () => addBandToList(textController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Dismiss'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketServices =
          Provider.of<SocketServices>(context, listen: false);
      socketServices.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
     });

    final List<Color> colorList=[
      Colors.blue[50],
      Colors.blue[200],
      Colors.pink[50],
      Colors.pink[200],
      Colors.yellow[50],
      Colors.yellow[200],
    ];
    return Container(
        width: double.infinity, height: 150, padding:EdgeInsets.only(top: 10), child: 
        PieChart(
      dataMap: dataMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      centerText: "Bands",
      legendOptions: LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: false,
      ),
    )
        );
  }
}
