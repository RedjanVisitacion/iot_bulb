import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RelayControlPage(),
    );
  }
}

class RelayControlPage extends StatefulWidget {
  const RelayControlPage({super.key});

  @override
  State<RelayControlPage> createState() => _RelayControlPageState();
}

class _RelayControlPageState extends State<RelayControlPage> {
  // Connection to your MacBook Air FastAPI server
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.0.141:8000/ws/flutter_ui'),
  );

  // We send the command to the server.
  // We DON'T update the UI locally here. We wait for the server to tell us.
  void _toggleRelay(bool currentState) {
    String command = currentState ? "OFF" : "ON";
    _channel.sink.add(command);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IoT Relay Controller"),
        centerTitle: true,
        elevation: 2,
      ),
      body: StreamBuilder(
        stream: _channel.stream,
        builder: (context, snapshot) {
          // Check what the server is currently saying
          // Default to 'false' (OFF) if no data yet
          bool isServerOn = snapshot.data == "ON";

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bulb Icon updates based on Server Stream
                Icon(
                  Icons.lightbulb_rounded,
                  size: 160,
                  color: isServerOn
                      ? Colors.yellow.shade700
                      : Colors.grey.shade400,
                ),
                const SizedBox(height: 20),

                Text(
                  isServerOn ? "LIGHT IS ON" : "LIGHT IS OFF",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isServerOn ? Colors.orange : Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () => _toggleRelay(isServerOn),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                    backgroundColor: isServerOn
                        ? Colors.redAccent
                        : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    isServerOn ? "TURN OFF" : "TURN ON",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Connection Status Helper
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    snapshot.hasError
                        ? "Connection Error!"
                        : (snapshot.hasData
                              ? "Synced with Server"
                              : "Connecting to 192.168.0.141..."),
                    style: TextStyle(
                      color: snapshot.hasError ? Colors.red : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
