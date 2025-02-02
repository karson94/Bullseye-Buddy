import 'package:flutter/material.dart';
import 'game.dart'; // Import the game page

class CreateNewGame extends StatelessWidget {
  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();

  CreateNewGame({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Game'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: SizedBox(
              width: screenWidth * 0.8,
              child: TextField(
                controller: player1Controller, // Assign controller
                decoration: const InputDecoration(
                  labelText: 'Enter Player 1 Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: screenWidth * 0.8,
              child: TextField(
                controller: player2Controller, // Assign controller
                decoration: const InputDecoration(
                  labelText: 'Enter Player 2 Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // Navigate to the Game page with names
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Game(
                    player1Name: player1Controller.text,
                    player2Name: player2Controller.text,
                  ),
                ),
              );
            },
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }
}