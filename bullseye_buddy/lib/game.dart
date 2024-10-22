import 'package:flutter/material.dart';

class Game extends StatefulWidget {
  final String player1Name;
  final String player2Name;

  const Game({super.key, required this.player1Name, required this.player2Name});

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int roundCounter = 1; // Initialize round counter

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Rules'),
          content: const Text(
            '1. Stand behind black line.\n'
            '2. Each person throws 3 darts per turn.\n'
            '3. Sum of all throws per turn is added to score.\n'
            '4. First to 301 wins. After a player reaches exactly 301, the game ends.\n'
            '5. If a player goes over 301 during their turn, their turn is over and their score remains what it was entering the round.\n',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _incrementRound() {
    roundCounter++; // Increment the round counter
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00703C),
        title: const Text('Tracker'), // Title of the app
      ),
      body: Center(
        child: Column( // Main layout for the screen
          mainAxisAlignment: MainAxisAlignment.start, // Align children to the start
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Align button to the right
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0), // Padding around the button
                  child: ElevatedButton(
                    onPressed: () => _showRules(context), // Show game rules when pressed
                    child: const Text('Show Rules'), // Button text
                  ),
                ),
              ],
            ),
            Text('Round: $roundCounter', style: const TextStyle(fontSize: 48)), // Display round counter
            const SizedBox(height: 20),
            Expanded( // Allow the Row to take full height
              child: Row( // Row to hold player columns
                children: [
                  Expanded( // Player 1 Column
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start, // Center content vertically
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                          children: [
                            Text(widget.player1Name, style: const TextStyle(fontSize: 24)), // Display Player 1 name
                          ], 
                        ),  
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1), // Divider between player columns
                  Expanded( // Player 2 Column
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start, // Center content vertically
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                          children: [
                            Text(widget.player2Name, style: const TextStyle(fontSize: 24)), // Display Player 2 name
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}