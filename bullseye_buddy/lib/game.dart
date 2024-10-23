import 'package:flutter/material.dart';

class Game extends StatefulWidget {
  final List<String> playerNames;

  const Game({super.key, required this.playerNames});

  @override
  // ignore: library_private_types_in_public_api
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int roundCounter = 1; // Initialize round counter
  Map<String, int> scores = {};
  late List<List<List<int>>> playerScores;

  @override
  void initState() {
    super.initState();
    scores = {
      widget.playerNames[0]: 301,
      widget.playerNames[1]: 301,
    }; // Initialize scores in initState

      playerScores = List.generate(
      widget.playerNames.length,
      (_) => [], // Each player starts with an empty list of rounds
    ); // Initialize playerScores in initState
  }

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('301 Game Rules', style: Theme.of(context).textTheme.bodyLarge,),
          content: Text(
            style: Theme.of(context).textTheme.bodyMedium,
            '1. Stand behind black line.\n'
            '2. Each person throws 3 darts per turn.\n'
            '3. Sum of all throws per turn is subtracted from score.\n'
            '4. Once a player\'s score reaches exactly 0, the game is over and that player wins.\n'
            '5. If a player busts (goes over 301 during their turn), '
            'their turn is over and any points scored this turn are nullified.\n',
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

  void _updateScore(String player, int throwScore) {
    int result = (scores[player] ?? 0) - throwScore;
    if(result > 0){
      scores[player] = result;
    }else if(result == 0){
      _gameWin(player);
    }else{
      // _playerBust(player);
    }
  }

  void _gameWin(String player) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over', style: Theme.of(context).textTheme.bodyLarge),
          content: Text(
            '$player has won the game!',
            style: Theme.of(context).textTheme.bodyMedium,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00703C),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showRules(context), // Show game rules when pressed
                    child: const Text('Show Rules'), // Button text
                  ),
                ),
              ],
            ),
            
            Text('Round: $roundCounter', style: const TextStyle(fontSize: 40)), // Display round counter

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00703C),
                foregroundColor: Colors.white,
              ),
              onPressed: () => _gameWin(widget.playerNames[0]), // Show game rules when pressed
              child: const Text('Win Game [test]'), // Button text
            ),

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
                            Text(widget.playerNames[0], style: const TextStyle(fontSize: 24)), // Display Player 1 name
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
                            Text(widget.playerNames[1], style: const TextStyle(fontSize: 24)), // Display Player 2 name
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