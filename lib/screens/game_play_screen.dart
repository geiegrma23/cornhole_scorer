import 'package:flutter/material.dart';
import 'quick_game_setup_screen.dart';
import 'home_screen.dart';
import '../models/game_settings.dart';

class GamePlayScreen extends StatefulWidget {
  final String team1Name;
  final String team2Name;
  final GameSettings gameSettings;

  const GamePlayScreen({
    Key? key,
    required this.team1Name,
    required this.team2Name,
    required this.gameSettings,
  }) : super(key: key);

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  int team1TotalScore = 0;
  int team2TotalScore = 0;
  int team1RoundScore = 0;
  int team2RoundScore = 0;
  int team1ThrowsRemaining = 4;
  int team2ThrowsRemaining = 4;
  int currentRound = 1;

  @override
  void initState() {
    super.initState();
    team1ThrowsRemaining = widget.gameSettings.throwsPerTeam;
    team2ThrowsRemaining = widget.gameSettings.throwsPerTeam;
  }

  void _addScore(bool isTeam1, int points) {
    setState(() {
      if (isTeam1) {
        if (team1ThrowsRemaining > 0) {
          team1RoundScore = (team1RoundScore + points).clamp(0, widget.gameSettings.maxRoundPoints);
          team1ThrowsRemaining--;
        }
      } else {
        if (team2ThrowsRemaining > 0) {
          team2RoundScore = (team2RoundScore + points).clamp(0, widget.gameSettings.maxRoundPoints);
          team2ThrowsRemaining--;
        }
      }
    });
  }

  void _subtractScore(bool isTeam1, int points) {
    setState(() {
      if (isTeam1) {
        team1RoundScore = (team1RoundScore - points).clamp(0, widget.gameSettings.maxRoundPoints);
      } else {
        team2RoundScore = (team2RoundScore - points).clamp(0, widget.gameSettings.maxRoundPoints);
      }
    });
  }

  void _endRound() async {
    if (widget.gameSettings.confirmRoundEnd) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('End Round?'),
          content: Text(
            'Round $currentRound Results:\n'
            '${widget.team1Name}: $team1RoundScore\n'
            '${widget.team2Name}: $team2RoundScore\n\n'
            'Apply cancellation scoring?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('End Round'),
            ),
          ],
        ),
      );
      
      if (confirm != true) return;
    }

    setState(() {
      // Apply cancellation scoring
      int team1Points = 0;
      int team2Points = 0;
      
      if (team1RoundScore > team2RoundScore) {
        team1Points = team1RoundScore - team2RoundScore;
      } else if (team2RoundScore > team1RoundScore) {
        team2Points = team2RoundScore - team1RoundScore;
      }
      
      // Add points to total scores
      team1TotalScore += team1Points;
      team2TotalScore += team2Points;
      
      // Apply knockback rule if enabled
      if (widget.gameSettings.knockbackEnabled) {
        if (team1TotalScore > widget.gameSettings.winningScore) {
          team1TotalScore = widget.gameSettings.knockbackScore;
        }
        if (team2TotalScore > widget.gameSettings.winningScore) {
          team2TotalScore = widget.gameSettings.knockbackScore;
        }
      }
      
      // Reset round scores and throws
      team1RoundScore = 0;
      team2RoundScore = 0;
      team1ThrowsRemaining = widget.gameSettings.throwsPerTeam;
      team2ThrowsRemaining = widget.gameSettings.throwsPerTeam;
      currentRound++;
    });
    
    // Check for winner
    if (team1TotalScore >= widget.gameSettings.winningScore || team2TotalScore >= widget.gameSettings.winningScore) {
      _showWinnerDialog();
    }
  }

  void _showWinnerDialog() {
    String winner = team1TotalScore >= widget.gameSettings.winningScore ? widget.team1Name : widget.team2Name;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎉 Game Over!'),
          content: Text(
            '$winner Wins!\n\nFinal Score:\n${widget.team1Name}: $team1TotalScore\n${widget.team2Name}: $team2TotalScore',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuickGameSetupScreen(
                      gameSettings: widget.gameSettings,
                    ),
                  ),
                );
              },
              child: const Text('New Teams'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('Quit'),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      team1TotalScore = 0;
      team2TotalScore = 0;
      team1RoundScore = 0;
      team2RoundScore = 0;
      team1ThrowsRemaining = widget.gameSettings.throwsPerTeam;
      team2ThrowsRemaining = widget.gameSettings.throwsPerTeam;
      currentRound = 1;
    });
  }

  Widget _buildScoreCard(String teamName, int totalScore, int roundScore, int throwsRemaining, bool isTeam1) {
    return Card(
      elevation: 4,
      color: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              teamName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalScore',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Round: $roundScore',
              style: TextStyle(
                fontSize: 16,
                color: widget.gameSettings.isDarkTheme ? Colors.white70 : Colors.grey,
              ),
            ),
            Text(
              'Throws: $throwsRemaining',
              style: TextStyle(
                fontSize: 14,
                color: widget.gameSettings.isDarkTheme ? Colors.white60 : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Scoring buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: throwsRemaining > 0 ? () => _addScore(isTeam1, 0) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(45, 40),
                  ),
                  child: const Text('0'),
                ),
                ElevatedButton(
                  onPressed: throwsRemaining > 0 ? () => _addScore(isTeam1, 1) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(45, 40),
                  ),
                  child: const Text('+1'),
                ),
                ElevatedButton(
                  onPressed: throwsRemaining > 0 ? () => _addScore(isTeam1, 3) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(45, 40),
                  ),
                  child: const Text('+3'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Adjustment buttons (for bag interactions)
            if (roundScore > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _subtractScore(isTeam1, 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(45, 35),
                    ),
                    child: const Text('-1'),
                  ),
                  ElevatedButton(
                    onPressed: () => _subtractScore(isTeam1, 3),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(45, 35),
                    ),
                    child: const Text('-3'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canEndRound = team1ThrowsRemaining == 0 && team2ThrowsRemaining == 0;
    
    return Scaffold(
      backgroundColor: widget.gameSettings.isDarkTheme ? Colors.grey.shade900 : Colors.blue.shade50,
      appBar: AppBar(
        title: Text('Round $currentRound'),
        backgroundColor: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Game'),
                  content: const Text('Are you sure you want to reset the game?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetGame();
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.gameSettings.knockbackEnabled)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Knockback Rule: Active (>${widget.gameSettings.winningScore} → ${widget.gameSettings.knockbackScore})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildScoreCard(
                      widget.team1Name,
                      team1TotalScore,
                      team1RoundScore,
                      team1ThrowsRemaining,
                      true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildScoreCard(
                      widget.team2Name,
                      team2TotalScore,
                      team2RoundScore,
                      team2ThrowsRemaining,
                      false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (canEndRound)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _endRound,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.gameSettings.isDarkTheme ? Colors.grey.shade700 : Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('End Round & Apply Cancellation'),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Complete all throws to end round',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.gameSettings.isDarkTheme ? Colors.white70 : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}