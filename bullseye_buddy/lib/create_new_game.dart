import 'package:flutter/material.dart';
import 'standard_game.dart'; // Import the game page

class CreateNewGame extends StatefulWidget {
  @override
  _CreateNewGameState createState() => _CreateNewGameState();
}

class _CreateNewGameState extends State<CreateNewGame> {
  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();
  final TextEditingController customScoreController = TextEditingController(); // Controller for custom score input

  String selectedGameType = '301'; // Default game type

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00703C),
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

              // Navigate to the Game page with names and selected game type
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => standardGame(
                    playerNames: [player1Controller.text, player2Controller.text],
                    gameMode: gameMode, // Pass the selected game type or custom score
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
