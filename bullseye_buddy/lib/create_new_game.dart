import 'package:flutter/material.dart';
import 'standard_game.dart'; // Import the game page

class CreateNewGame extends StatefulWidget {
  @override
  _CreateNewGameState createState() => _CreateNewGameState();
}

class _CreateNewGameState extends State<CreateNewGame> {
  List<TextEditingController> playerControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final TextEditingController customScoreController = TextEditingController(); // Controller for custom score input

  String selectedGameType = '301'; // Default game type

  @override
  void dispose() {
    for (var controller in playerControllers) {
      controller.dispose();
    }
    customScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00703C),
        title: const Text('New Game'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            ...List.generate(playerControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: SizedBox(
                    width: screenWidth * 0.8,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: playerControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Enter Player ${index + 1} Name',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                        ),
                        if (playerControllers.length > 2)
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                playerControllers.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // Add Player Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Player'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00703C),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    playerControllers.add(TextEditingController());
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            // Dropdown for selecting game type
            DropdownButton<String>(
              value: selectedGameType,
              items: <String>['301', '501', '101', 'Custom']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGameType = newValue!;
                  // Clear custom score input when changing game type
                  if (selectedGameType != 'Custom') {
                    customScoreController.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            // Conditionally show the custom score input field
            if (selectedGameType == 'Custom')
              Center(
                child: SizedBox(
                  width: screenWidth * 0.8,
                  child: TextField(
                    controller: customScoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Custom Target Score',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.build_rounded),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00703C),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Determine the initial score based on the selected game type
                String gameMode = selectedGameType == 'Custom'
                    ? customScoreController.text
                    : selectedGameType;

                // Collect all non-empty player names
                List<String> playerNames = playerControllers
                    .map((controller) => controller.text.trim())
                    .where((name) => name.isNotEmpty)
                    .toList();

                if (playerNames.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter at least two player names.')),
                  );
                  return;
                }

                // Navigate to the Game page with names and selected game type
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => standardGame(
                      playerNames: playerNames,
                      gameMode: gameMode, // Pass the selected game type or custom score
                    ),
                  ),
                );
              },
              child: const Text('Start Game'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
