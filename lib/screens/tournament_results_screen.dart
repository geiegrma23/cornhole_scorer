import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/tournament_models.dart';
import 'home_screen.dart';
import 'tournament_setup_screen.dart';

class TournamentResultsScreen extends StatelessWidget {
  final Tournament tournament;
  final GameSettings gameSettings;

  const TournamentResultsScreen({
    Key? key,
    required this.tournament,
    required this.gameSettings,
  }) : super(key: key);

  Widget _getTrophyIcon(int position) {
    switch (position) {
      case 1:
        return const Icon(
          Icons.emoji_events,
          color: Colors.amber,
          size: 32,
        );
      case 2:
        return const Icon(
          Icons.emoji_events,
          color: Colors.grey,
          size: 28,
        );
      case 3:
        return const Icon(
          Icons.emoji_events,
          color: Color(0xFFCD7F32), // Bronze color
          size: 24,
        );
      default:
        return const SizedBox(width: 32);
    }
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber.shade100;
      case 2:
        return Colors.grey.shade200;
      case 3:
        return const Color(0xFFEDC9B3); // Light bronze
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gameSettings.isDarkTheme ? Colors.grey.shade900 : Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Tournament Results'),
        backgroundColor: gameSettings.isDarkTheme ? Colors.grey.shade800 : Colors.blue.shade600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tournament Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  tournament.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tournament Complete!',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${tournament.format == TournamentFormat.singleElimination ? 'Single' : 'Double'} Elimination • ${tournament.teams.length} Teams',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tournament.finalRankings.length,
              itemBuilder: (context, index) {
                final team = tournament.finalRankings[index];
                final position = index + 1;
                final isTopThree = position <= 3;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: isTopThree ? _getPositionColor(position) : null,
                    borderRadius: BorderRadius.circular(12),
                    border: isTopThree 
                        ? Border.all(
                            color: position == 1 
                                ? Colors.amber 
                                : position == 2 
                                    ? Colors.grey 
                                    : const Color(0xFFCD7F32),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Card(
                    elevation: isTopThree ? 8 : 2,
                    margin: EdgeInsets.zero,
                    color: gameSettings.isDarkTheme ? Colors.grey.shade800 : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Position and Trophy
                          SizedBox(
                            width: 60,
                            child: Row(
                              children: [
                                Text(
                                  '$position',
                                  style: TextStyle(
                                    fontSize: isTopThree ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: gameSettings.isDarkTheme ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isTopThree) _getTrophyIcon(position),
                              ],
                            ),
                          ),
                          
                          // Team Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  team.displayName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: gameSettings.isDarkTheme ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${team.players.map((p) => p.name).join(' & ')}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: gameSettings.isDarkTheme ? Colors.white70 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Stats
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${team.wins}W - ${team.losses}L',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: gameSettings.isDarkTheme ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Avg: ${team.averageScore.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: gameSettings.isDarkTheme ? Colors.white60 : Colors.grey,
                                ),
                              ),
                              Text(
                                'Total: ${team.totalScore}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: gameSettings.isDarkTheme ? Colors.white60 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TournamentSetupScreen(
                            gameSettings: gameSettings,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('New Tournament'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade600,
                      side: BorderSide(color: Colors.blue.shade600),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Return to Home'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}