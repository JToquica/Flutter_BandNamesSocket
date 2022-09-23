import 'dart:io';

import 'package:band_names/services/socket_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on("active-bands", _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off("active-bands");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Band Names",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 15),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? Icon(Icons.check_circle, color: Colors.green[300])
                : Icon(Icons.offline_bolt_rounded, color: Colors.red[300]),
          ),
        ],
        elevation: 1,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _ShowGraphic(bands: bands),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int idx) {
                return _BandTile(band: bands[idx]);
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Nueva nombre banda:"),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              // ignore: sort_child_properties_last
              child: const Text("Agregar"),
              elevation: 5,
              onPressed: () => addBandToList(textController.text),
              textColor: Colors.blue,
            ),
          ],
        ),
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text(
          "Nuevo nombre banda:",
        ),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Agregar"),
            onPressed: () => addBandToList(textController.text),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {"name": name});
    }

    Navigator.pop(context);
  }
}

class _ShowGraphic extends StatelessWidget {
  final List<Band> bands;
  const _ShowGraphic({Key? key, required this.bands}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {};

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final Size size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height * 0.3,
      child: dataMap.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(15),
              child: PieChart(
                chartType: ChartType.ring,
                dataMap: dataMap,
                chartValuesOptions: const ChartValuesOptions(
                    decimalPlaces: 0,
                    showChartValueBackground: false,
                    showChartValuesInPercentage: true),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "No hay datos.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    "Intenta agregando una banda :)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ),
    );
  }
}

class _BandTile extends StatelessWidget {
  final Band band;
  const _BandTile({Key? key, required this.band}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        if (direction.toString() == "DismissDirection.startToEnd") {
          socketService.socket.emit("delete-band", {"id": band.id});
        }
      },
      key: Key(band.id),
      background: Container(
        padding: const EdgeInsets.only(left: 10),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Eliminar banda",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          band.votes.toString(),
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          socketService.socket.emit("vote-band", {"id": band.id});
        },
      ),
    );
  }
}
