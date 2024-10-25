import 'package:flutter/material.dart';

class Game extends StatefulWidget {
  final List<String> playerNames;

  const Game({super.key, required this.playerNames});

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int roundCounter = 1;
  Map<String, int> scores = {};
  late List<List<List<int>>> throwScoreStorage;

  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();

  int player1ThrowCount = 0;
  int player2ThrowCount = 0;
  bool isPlayer1Turn = true;
  bool isPlayer2Turn = false; // New flag for Player 2
  int multiplier = 1;

  @override
  void initState() {
    super.initState();
    initializeScores();
    initializeThrowStorage();
  }

  void initializeScores() {
    scores = {
      widget.playerNames[0]: 301,
      widget.playerNames[1]: 301,
    };
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
          title: Text('301 Game Rules', style: Theme.of(context).textTheme.bodyLarge),
          content: Text(
            '1. Stand behind black line.\n'
            '2. Each person throws 3 darts per turn.\n'
            '3. Sum of all throws per turn is subtracted from score.\n'
            '4. Once a player\'s score reaches exactly 0, the game is over and that player wins.\n'
            '5. If a player busts (goes over 301 during their turn), their turn is over and any points scored this turn are nullified.\n',
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
    });
  }

  void _updateScore(String player, int throwScore) {
    int currentScore = scores[player] ?? 0;
    int newScore = currentScore - throwScore;

    setState(() {
      if (newScore > 0) {
        scores[player] = newScore;
        print('Updated score for $player: ${scores[player]}');
      } else if (newScore == 0) {
        _gameWin(player);
      } else {
        print('$player busted! Score cannot go below zero.');
      }
    });
  }

  void _addThrow(String player, int throwValue) {
    int playerIndex = widget.playerNames.indexOf(player);
    if (playerIndex != -1) {
      throwScoreStorage[roundCounter - 1][playerIndex].add(throwValue);
      print('Added throw: $throwValue for player: $player');
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
          _processPlayerThrow(widget.playerNames[0], throwValue, true);
        } else if (!isPlayer1 && isPlayer2Turn) {
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
    _addThrow(player, throwValue);
    if (isPlayer1) {
      player1ThrowCount++;
      player1Controller.clear();
      if (player1ThrowCount >= 3) {
        isPlayer1Turn = false;
        isPlayer2Turn = true; // Set Player 2's turn
        player1ThrowCount = 0;
        print('Player 1 has completed 3 throws. Now it\'s Player 2\'s turn.');
      }
    } else {
      player2ThrowCount++;
      player2Controller.clear();
      if (player2ThrowCount >= 3) {
        isPlayer2Turn = false; // Reset Player 2's turn
        isPlayer1Turn = true; // Set Player 1's turn
        player2ThrowCount = 0;
        _nextRound();
        print('Player 2 has completed 3 throws. Now it\'s Player 1\'s turn for the next round.');
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
                Navigator.of(context).pop();
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
                  _buildPlayerColumn(widget.playerNames[0], player1Controller, player1ThrowCount, isPlayer1Turn, true),
                  const VerticalDivider(width: 1),
                  _buildPlayerColumn(widget.playerNames[1], player2Controller, player2ThrowCount, isPlayer2Turn, false),
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
          multiplier = (multiplier % 3) + 1;
        });
      },
      child: Text('${multiplier}x'),
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
          hintText: 'Throw ${throwCount + 1}',
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
