import 'package:flutter/material.dart';

class standardGame extends StatefulWidget {
  final List<String> playerNames;
  final String gameMode;

  const standardGame({super.key, required this.playerNames, required this.gameMode});

  @override
  _standardGameState createState() => _standardGameState();
}

class _standardGameState extends State<standardGame> {
  int roundCounter = 1;
  Map<String, int> scores = {};
  late List<List<List<int>>> throwScoreStorage;

  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();

  int player1ThrowCount = 0;
  int player2ThrowCount = 0;

  int originalPlayer1Score = 301; // Default score
  int originalPlayer2Score = 301; // Default score

  String currentPlayer = ''; // Track the current player
  int multiplier = 1;

  @override
  void initState() {
    super.initState();
    initializeScores();
    initializeThrowStorage();
    currentPlayer = widget.playerNames[0]; // Set initial player
  }

  void initializeScores() {
    int initialScoreValue;

    if (widget.gameMode.isEmpty) {
      initialScoreValue = 999;
    } else {
      initialScoreValue = int.parse(widget.gameMode);
    }

    scores = {
      widget.playerNames[0]: initialScoreValue,
      widget.playerNames[1]: initialScoreValue,
    };
    originalPlayer1Score = initialScoreValue;
    originalPlayer2Score = initialScoreValue;
  }

  void initializeThrowStorage() {
    throwScoreStorage = [
      [[], []],
    ];
  }

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Standard Game Rules', style: Theme.of(context).textTheme.bodyLarge),
          content: Text(
            '1. Players must stand behind the black line while throwing.\n'
            '2. Each player takes turns throwing 3 darts per round.\n'
            '3. The total score from all darts thrown in a turn is deducted from the player\'s current score.\n'
            '4. The game concludes when a player\'s score is reduced to exactly 0, declaring them the winner.\n'
            '5. If a player exceeds the target score of ${widget.gameMode} during their turn, it is considered a bust. Their turn ends, and any points scored in that turn are forfeited.\n',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
      roundCounter++;
      throwScoreStorage.add([[], []]);
      print('New Round # $roundCounter');

      player1ThrowCount = 0; // Reset Player 1's throw count
      player2ThrowCount = 0; // Reset Player 2's throw count
      _setCurrentPlayer(widget.playerNames[0]); // Start with Player 1
    });
  }

  void _updateScore(String player, int throwScore) {
    int currentScore = scores[player] ?? 0;
    int newScore = currentScore - throwScore;

    setState(() {
      if (newScore > 0) {
        scores[player] = newScore;
      } else if (newScore == 0) {
        _gameWin(player);
      } else {
        _bustPlayer(player);
      }
    });
  }

  void _bustPlayer(String player) {
    if (player == widget.playerNames[0]) {
      scores[player] = originalPlayer1Score; // Reset score to original for Player 1
      print('$player busted! Score reset to $originalPlayer1Score. Ending turn.');
      _setCurrentPlayer(widget.playerNames[1]); // Switch to Player 2
      player1ThrowCount = 0; // Reset Player 1's throw count
      player2ThrowCount = 0;
    } else {
      scores[player] = originalPlayer2Score; // Reset score to original for Player 2
      print('$player busted! Score reset to $originalPlayer2Score. Ending turn.');
      player2ThrowCount = 0; // Reset Player 2's throw count
      _nextRound();
    }
  }

  void _addThrow(String player, int throwValue) {
    int playerIndex = widget.playerNames.indexOf(player);
    if (playerIndex != -1) {
      throwScoreStorage[roundCounter - 1][playerIndex].add(throwValue);
      _updateScore(player, throwValue);
    } else {
      print('Player not found: $player');
    }
  }

  void _handlePlayerInput(String value, bool isPlayer1) {
    if (value.isNotEmpty) {
      int? throwValue = int.tryParse(value);
      if (throwValue != null) {
        if (currentPlayer == widget.playerNames[0]) {
          _processPlayerThrow(widget.playerNames[0], throwValue, true);
        } else if (currentPlayer == widget.playerNames[1]) {
          _processPlayerThrow(widget.playerNames[1], throwValue, false);
        } else {
          print('It\'s not your turn!');
        }
      } else {
        print('Invalid input: $value is not a number');
      }
    }
  }

  void _processPlayerThrow(String player, int throwValue, bool isPlayer1) {
    int currentThrowCount = isPlayer1 ? player1ThrowCount : player2ThrowCount;

    if (isPlayer1 && currentThrowCount == 0) {
      originalPlayer1Score = scores[player] ?? 0; // Store original score at the start of Player 1's turn
    } else if (!isPlayer1 && currentThrowCount == 0) {
      originalPlayer2Score = scores[player] ?? 0; // Store original score at the start of Player 2's turn
    }

    _addThrow(player, throwValue);

    if (isPlayer1) {
      player1ThrowCount++;
      player1Controller.clear();
      if (player1ThrowCount >= 3) {
        _setCurrentPlayer(widget.playerNames[1]); // Switch to Player 2
        player1ThrowCount = 0; // Reset Player 1's throw count
        print('${widget.playerNames[0]} has completed 3 throws. Now it\'s Player 2\'s turn.');
      }
    } else {
      player2ThrowCount++;
      player2Controller.clear();
      if (player2ThrowCount >= 3) {
        player2ThrowCount = 0; // Reset Player 2's throw count
        _nextRound(); // Only call _nextRound after Player 2 completes their throws
        print('${widget.playerNames[1]} has completed 3 throws. Now it\'s a new round.');
      }
    }

    // Print the throw number after submission
    print('${isPlayer1 ? "${widget.playerNames[0]}" : "${widget.playerNames[1]}"} has submitted throw ${currentThrowCount + 1}: $throwValue');
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
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _setCurrentPlayer(String player) {
    setState(() {
      currentPlayer = player;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00703C),
        title: const Text('Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildShowRulesButton(context),
            Text('Round: $roundCounter', style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  _buildPlayerColumn(widget.playerNames[0], player1Controller, player1ThrowCount, currentPlayer == widget.playerNames[0], true),
                  const VerticalDivider(width: 1),
                  _buildPlayerColumn(widget.playerNames[1], player2Controller, player2ThrowCount, currentPlayer == widget.playerNames[1], false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowRulesButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00703C),
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showRules(context),
            child: const Text('Show Rules'),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerColumn(String playerName, TextEditingController controller, int throwCount, bool isCurrentPlayer, bool isPlayer1) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildPlayerNameRow(playerName),
          _buildPlayerScoreRow(playerName),
          _buildPlayerInputRow(controller, throwCount, isCurrentPlayer, isPlayer1),
          const SizedBox(height: 20),
          _buildPlayerThrowsDisplay(isPlayer1),
        ],
      ),
    );
  }

  Widget _buildPlayerNameRow(String playerName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(playerName, style: const TextStyle(fontSize: 24)),
      ],
    );
  }

  Widget _buildPlayerScoreRow(String playerName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Score: ${scores[playerName].toString()}'),
      ],
    );
  }

  Widget _buildPlayerInputRow(TextEditingController controller, int throwCount, bool isCurrentPlayer, bool isPlayer1) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isCurrentPlayer) _buildMultiplierButton(),
          const SizedBox(width: 20),
          if (isCurrentPlayer) _buildInputField(controller, throwCount),
          const SizedBox(width: 20),
          if (isCurrentPlayer) _buildSubmitButton(controller, isPlayer1),
        ],
      ),
    );
  }

  Widget _buildMultiplierButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00703C),
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        setState(() {
          multiplier = (multiplier % 3) + 1; // Cycle through multipliers
        });
      },
      child: Text('${multiplier}x'), // Display current multiplier
    );
  }

  Widget _buildInputField(TextEditingController controller, int throwCount) {
    return Container(
      width: 100,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: 'Throw ${throwCount + 1}', // Display which throw it is
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Rounded border
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto, // Move label on focus
          floatingLabelAlignment: FloatingLabelAlignment.center,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(TextEditingController controller, bool isPlayer1) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00703C),
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        String value = controller.text;
        int throwValue = int.tryParse(value) ?? 0;
        _handlePlayerInput((throwValue * multiplier).toString(), isPlayer1);
        controller.clear();
      },
      child: const Text('Submit'),
    );
  }

  Widget _buildPlayerThrowsDisplay(bool isPlayer1) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: throwScoreStorage
            .map((round) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Round ${throwScoreStorage.indexOf(round) + 1}: ', style: Theme.of(context).textTheme.bodyLarge),
                    ...round[isPlayer1 ? 0 : 1].map((throwValue) => Text('$throwValue ', style: Theme.of(context).textTheme.bodyLarge)).toList(),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
