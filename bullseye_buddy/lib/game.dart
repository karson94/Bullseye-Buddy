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
  bool currentPlayer = false;
  Map<String, int> scores = {};
  late List<List<List<int>>> throwScoreStorage;

  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();

  int player1ThrowCount = 0; // Track throws for Player 1
  int player2ThrowCount = 0; // Track throws for Player 2

  bool isPlayer1Turn = true;  // Track whose turn it is

  @override
  void initState() {
    super.initState();
    scores = {
      widget.playerNames[0]: 301,
      widget.playerNames[1]: 301,
    }; // Initialize scores in initState

     throwScoreStorage = [
      [[], []], // Round 1: Alice's throws and Bob's throws
   ]; // Initialize playerScores in initState
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

  void _nextRound() {
    setState(() {
      roundCounter++; // Increment the round counter
      throwScoreStorage.add([[], []]); // Add a new round with empty throws
      print('New Round # $roundCounter');
    });
  }

  void _updateScore(String player, int throwScore) {
    int currentScore = scores[player] ?? 0; // Get the current score for the player
    int newScore = currentScore - throwScore; // Calculate the new score

    setState(() { // Notify the framework to rebuild the widget
        if (newScore > 0) {
            scores[player] = newScore; // Update the score if it's still positive
            print('Updated score for $player: ${scores[player]}');
        } else if (newScore == 0) {
            _gameWin(player); // Call game win if score reaches zero
        } else {
            // Handle bust scenario (if needed)
            print('$player busted! Score cannot go below zero.');
        }
    });
}

  void _addThrow(String player, int throwValue) {
    int playerIndex = widget.playerNames.indexOf(player);
    if (playerIndex != -1) {
      // Add throw to the correct player's list
      throwScoreStorage[roundCounter - 1][playerIndex].add(throwValue);
      print('Added throw: $throwValue for player: $player');
      print('Updated throwScoreStorage: $throwScoreStorage');

      // Update the player's score
      _updateScore(player, throwValue);
    } else {
      print('Player not found: $player');
    }
  }

  void _handlePlayerInput(String value, bool isPlayer1) {
    if (value.isNotEmpty) {
      int? throwValue = int.tryParse(value);
      if (throwValue != null) {
        if (isPlayer1 && isPlayer1Turn) {
          _addThrow(widget.playerNames[0], throwValue);
          player1ThrowCount++;
          player1Controller.clear(); // Clear the input field after submission

          // Check if Player 1 has completed 3 throws
          if (player1ThrowCount >= 3) {
            isPlayer1Turn = false; // Switch to Player 2
            player1ThrowCount = 0; // Reset Player 1's throw count
            print('Player 1 has completed 3 throws. Now it\'s Player 2\'s turn.');
          }
        } else if (!isPlayer1 && !isPlayer1Turn) {
          _addThrow(widget.playerNames[1], throwValue);
          player2ThrowCount++;
          player2Controller.clear();

          // Check if Player 2 has completed 3 throws
          if (player2ThrowCount >= 3) {
            isPlayer1Turn = true; // Switch back to Player 1
            player2ThrowCount = 0; // Reset Player 2's throw count
            _nextRound();
            print('Player 2 has completed 3 throws. Now it\'s Player 1\'s turn for the next round.');
          }
        } else {
          print('It\'s not your turn!');
        }
      } else {
        print('Invalid input: $value is not a number');
      }
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                          children: [
                            Text('Score: ${scores[widget.playerNames[0]].toString()}',), // Display Player 1 name
                          ], 
                        ), 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                          children: [
                            if(isPlayer1Turn)
                              Container(
                                width: 200, // Define a width
                                child: TextField(
                                  controller: player1Controller,
                                  keyboardType: TextInputType.number,
                                  onSubmitted: (value) => _handlePlayerInput(value, true),
                                  decoration: InputDecoration(
                                    hintText: 'Enter throw value for ${widget.playerNames[0]}',
                                  ),
                                ),
                              ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                          children: [
                            Text('Score: ${scores[widget.playerNames[1]].toString()}',), // Display Player 1 name
                          ], 
                        ), 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                          children: [
                            if(!isPlayer1Turn)
                              Container(
                                width: 200, // Define a width
                                child: TextField(
                                  controller: player2Controller,
                                  keyboardType: TextInputType.number,
                                  onSubmitted: (value) => _handlePlayerInput(value, false),
                                  decoration: InputDecoration(
                                    hintText: 'Enter throw value for ${widget.playerNames[1]}',
                                  ),
                                ),
                              ),
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