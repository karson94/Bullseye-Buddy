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

  late List<TextEditingController> playerControllers;
  late List<int> playerThrowCounts;
  late List<int> originalPlayerScores;
  int currentPlayerIndex = 0;
  int multiplier = 1;

  @override
  void initState() {
    super.initState();
    initializeScores();
    initializeThrowStorage();
    playerControllers = List.generate(widget.playerNames.length, (_) => TextEditingController());
    playerThrowCounts = List.filled(widget.playerNames.length, 0);
    originalPlayerScores = List.filled(widget.playerNames.length, 301);
    currentPlayerIndex = 0;
  }

  void initializeScores() {
    int initialScoreValue;

    if (widget.gameMode.isEmpty) {
      initialScoreValue = 999;
    } else {
      initialScoreValue = int.parse(widget.gameMode);
    }

    scores = {
      for (var name in widget.playerNames) name: initialScoreValue,
    };
    originalPlayerScores = List.filled(widget.playerNames.length, initialScoreValue);
  }

  void initializeThrowStorage() {
    throwScoreStorage = [
      List.generate(widget.playerNames.length, (_) => []),
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
      throwScoreStorage.add(List.generate(widget.playerNames.length, (_) => []));
      print('New Round # $roundCounter');
      playerThrowCounts = List.filled(widget.playerNames.length, 0);
      _setCurrentPlayer(0);
    });
  }

  void _updateScore(int playerIndex, int throwScore) {
    String player = widget.playerNames[playerIndex];
    int currentScore = scores[player] ?? 0;
    int newScore = currentScore - throwScore;

    setState(() {
      if (newScore > 0) {
        scores[player] = newScore;
      } else if (newScore == 0) {
        _gameWin(player);
      } else {
        _bustPlayer(playerIndex);
      }
    });
  }

  void _bustPlayer(int playerIndex) {
    String player = widget.playerNames[playerIndex];
    scores[player] = originalPlayerScores[playerIndex];
    print('$player busted! Score reset to ${originalPlayerScores[playerIndex]}. Ending turn.');
    playerThrowCounts[playerIndex] = 0;
    _nextPlayer();
  }

  void _addThrow(int playerIndex, int throwValue) {
    throwScoreStorage[roundCounter - 1][playerIndex].add(throwValue);
    _updateScore(playerIndex, throwValue);
  }

  void _handlePlayerInput(String value, int playerIndex) {
    if (value.isNotEmpty) {
      int? throwValue = int.tryParse(value);
      if (throwValue != null) {
        if (currentPlayerIndex == playerIndex) {
          _processPlayerThrow(playerIndex, throwValue);
        } else {
          print('It\'s not your turn!');
        }
      } else {
        print('Invalid input: $value is not a number');
      }
    }
  }

  void _processPlayerThrow(int playerIndex, int throwValue) {
    int currentThrowCount = playerThrowCounts[playerIndex];

    if (currentThrowCount == 0) {
      originalPlayerScores[playerIndex] = scores[widget.playerNames[playerIndex]] ?? 0;
    }

    _addThrow(playerIndex, throwValue);

    playerThrowCounts[playerIndex]++;
    playerControllers[playerIndex].clear();
    if (playerThrowCounts[playerIndex] >= 3) {
      playerThrowCounts[playerIndex] = 0;
      _nextPlayer();
    }

    print('${widget.playerNames[playerIndex]} has submitted throw ${currentThrowCount + 1}: $throwValue');
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

  void _setCurrentPlayer(int playerIndex) {
    setState(() {
      currentPlayerIndex = playerIndex;
    });
  }

  void _nextPlayer() {
    if (currentPlayerIndex < widget.playerNames.length - 1) {
      _setCurrentPlayer(currentPlayerIndex + 1);
    } else {
      _nextRound();
    }
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
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.playerNames.length,
                separatorBuilder: (context, index) => const VerticalDivider(width: 1),
                itemBuilder: (context, index) {
                  return _buildPlayerColumn(
                    widget.playerNames[index],
                    playerControllers[index],
                    playerThrowCounts[index],
                    currentPlayerIndex == index,
                    index,
                  );
                },
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

  Widget _buildPlayerColumn(String playerName, TextEditingController controller, int throwCount, bool isCurrentPlayer, int playerIndex) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildPlayerNameRow(playerName),
          _buildPlayerScoreRow(playerName),
          _buildPlayerInputRow(controller, throwCount, isCurrentPlayer, playerIndex),
          const SizedBox(height: 20),
          _buildPlayerThrowsDisplay(playerIndex),
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

  Widget _buildPlayerInputRow(TextEditingController controller, int throwCount, bool isCurrentPlayer, int playerIndex) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isCurrentPlayer) _buildMultiplierButton(),
          const SizedBox(width: 20),
          if (isCurrentPlayer) _buildInputField(controller, throwCount),
          const SizedBox(width: 20),
          if (isCurrentPlayer) _buildSubmitButton(controller, playerIndex),
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
          labelText: 'Throw ${throwCount + 1}',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          floatingLabelAlignment: FloatingLabelAlignment.center,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(TextEditingController controller, int playerIndex) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00703C),
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        String value = controller.text;
        int throwValue = int.tryParse(value) ?? 0;
        _handlePlayerInput((throwValue * multiplier).toString(), playerIndex);
        controller.clear();
      },
      child: const Text('Submit'),
    );
  }

  Widget _buildPlayerThrowsDisplay(int playerIndex) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: throwScoreStorage
            .map((round) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Round ${throwScoreStorage.indexOf(round) + 1}: ', style: Theme.of(context).textTheme.bodyLarge),
                    ...round[playerIndex].map((throwValue) => Text('$throwValue ', style: Theme.of(context).textTheme.bodyLarge)).toList(),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
