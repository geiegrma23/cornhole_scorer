import 'package:flutter/material.dart';
import 'quick_game_setup_screen.dart';
import 'settings_screen.dart';
import 'tournament_setup_screen.dart';
import '../models/game_settings.dart';
import '../services/settings_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameSettings _gameSettings = GameSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load settings when the screen initializes
  Future<void> _loadSettings() async {
    try {
      final settings = await SettingsService.loadSettings();
      setState(() {
        _gameSettings = settings;
        _isLoading = false;
      });
    } catch (e) {
      // If loading fails, use defaults
      setState(() {
        _gameSettings = GameSettings();
        _isLoading = false;
      });
    }
  }

  // Update settings and save them
  Future<void> _updateSettings(GameSettings newSettings) async {
    setState(() {
      _gameSettings = newSettings;
    });
    
    try {
      await SettingsService.saveSettings(newSettings);
    } catch (e) {
      // Handle save error silently in production
      // In development, you might want to log this
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while settings are loading
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _gameSettings.isDarkTheme ? Colors.grey.shade900 : Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Cornhole Scorer'),
        centerTitle: true,
        backgroundColor: _gameSettings.isDarkTheme ? Colors.grey.shade800 : Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    currentSettings: _gameSettings,
                    onSettingsChanged: _updateSettings,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Cornhole Board Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.brown.shade400,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.brown.shade600, width: 2),
              ),
              child: Stack(
                children: [
                  // Board surface
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.brown.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Hole
                  Positioned(
                    top: 15,
                    left: 30,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Cornhole bag
                  Positioned(
                    bottom: 10,
                    right: 15,
                    child: Container(
                      width: 12,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Cornhole Scorer',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _gameSettings.isDarkTheme ? Colors.white : Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 40),
            Card(
              elevation: 4,
              color: _gameSettings.isDarkTheme ? Colors.grey.shade800 : null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Quick Game Ready',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _gameSettings.isDarkTheme ? Colors.white : Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Knockback Rule: ${_gameSettings.knockbackEnabled ? "ON" : "OFF"}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _gameSettings.isDarkTheme ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        Icon(
                          _gameSettings.knockbackEnabled ? Icons.check_circle : Icons.cancel,
                          color: _gameSettings.knockbackEnabled ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                    if (_gameSettings.knockbackEnabled) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Knockback to: ${_gameSettings.knockbackScore}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _gameSettings.isDarkTheme ? Colors.white60 : Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Win at: ${_gameSettings.winningScore} points',
                      style: TextStyle(
                        fontSize: 14,
                        color: _gameSettings.isDarkTheme ? Colors.white60 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuickGameSetupScreen(
                        gameSettings: _gameSettings,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Quick Game'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TournamentSetupScreen(
                        gameSettings: _gameSettings,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Tournament Mode'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}