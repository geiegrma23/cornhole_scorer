import 'package:flutter/material.dart';
import 'game_play_screen.dart';
import '../models/game_settings.dart';

class QuickGameSetupScreen extends StatefulWidget {
  final GameSettings gameSettings;

  const QuickGameSetupScreen({
    Key? key,
    required this.gameSettings,
  }) : super(key: key);

  @override
  State<QuickGameSetupScreen> createState() => _QuickGameSetupScreenState();
}

class _QuickGameSetupScreenState extends State<QuickGameSetupScreen> {
  final _team1Controller = TextEditingController();
  final _team2Controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _team1Controller.dispose();
    _team2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.gameSettings.isDarkTheme ? Colors.grey.shade900 : Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Quick Game Setup'),
        backgroundColor: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                color: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : null,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Names',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _team1Controller,
                        decoration: const InputDecoration(
                          labelText: 'Team 1 Name',
                          hintText: 'Enter team 1 name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name for Team 1';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _team2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Team 2 Name',
                          hintText: 'Enter team 2 name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name for Team 2';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                color: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : null,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Game Rules',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            widget.gameSettings.knockbackEnabled ? Icons.check_circle : Icons.cancel,
                            color: widget.gameSettings.knockbackEnabled ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Knockback Rule: ${widget.gameSettings.knockbackEnabled ? 'Enabled' : 'Disabled'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.gameSettings.isDarkTheme ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      if (widget.gameSettings.knockbackEnabled) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Knockback to: ${widget.gameSettings.knockbackScore}',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.gameSettings.isDarkTheme ? Colors.white60 : Colors.grey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '• Cancellation scoring\n• Max ${widget.gameSettings.maxRoundPoints} points per round\n• ${widget.gameSettings.throwsPerTeam} throws per team\n• Win at ${widget.gameSettings.winningScore} points',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.gameSettings.isDarkTheme ? Colors.white60 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamePlayScreen(
                            team1Name: _team1Controller.text.trim(),
                            team2Name: _team2Controller.text.trim(),
                            gameSettings: widget.gameSettings,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Start Game'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}