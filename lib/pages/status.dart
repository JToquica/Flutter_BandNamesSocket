import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_names/services/socket_services.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketServices = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Text("Estado Servidor: ${socketServices.serverStatus}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => socketServices.socket.emit("emitir-mensaje",
            {"nombre": "Flutter", "mensaje": "Hola desde Flutter"}),
        child: const Icon(Icons.send),
      ),
    );
  }
}
