import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/tournament_models.dart';

class TournamentGameScreen extends StatefulWidget {
  final Tournament tournament;
  final Match match;
  final GameSettings gameSettings;
  final Function(Match) onMatchComplete;

  const TournamentGameScreen({
    Key? key,
    required this.tournament,
    required this.match,
    required this.gameSettings,
    required this.onMatchComplete,
  }) : super(key: key);

  @override
  State<TournamentGameScreen> createState() => _TournamentGameScreenState();
}

class _TournamentGameScreenState extends State<TournamentGameScreen> {
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
    
    // Mark match as in progress
    widget.match.status = MatchStatus.inProgress;
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
            '${widget.match.team1?.displayName}: $team1RoundScore\n'
            '${widget.match.team2?.displayName}: $team2RoundScore\n\n'
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
    Team winner;
    int winnerScore, loserScore;
    
    if (team1TotalScore >= widget.gameSettings.winningScore) {
      winner = widget.match.team1!;
      winnerScore = team1TotalScore;
      loserScore = team2TotalScore;
    } else {
      winner = widget.match.team2!;
      winnerScore = team2TotalScore;
      loserScore = team1TotalScore;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎉 Match Complete!'),
          content: Text(
            '${winner.displayName} Wins!\n\nFinal Score:\n${widget.match.team1?.displayName}: $team1TotalScore\n${widget.match.team2?.displayName}: $team2TotalScore',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _completeMatch(winner, winnerScore, loserScore);
              },
              child: const Text('Continue Tournament'),
            ),
          ],
        );
      },
    );
  }

  void _completeMatch(Team winner, int winnerScore, int loserScore) {
    // Update the match with results
    widget.match.completeMatch(winner, winnerScore, loserScore);
    
    // Call the callback to update the tournament
    widget.onMatchComplete(widget.match);
    
    // Return to bracket screen
    Navigator.of(context).pop();
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
        title: Text('Round $currentRound - Tournament Match'),
        backgroundColor: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Match'),
                  content: const Text('Are you sure you want to reset this match?'),
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
            // Tournament context
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    widget.tournament.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  Text(
                    'Round ${widget.match.round}${widget.match.isLoserBracket ? ' (Loser Bracket)' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
            
            if (widget.gameSettings.knockbackEnabled) ...[
              const SizedBox(height: 12),
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
            ],
            
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildScoreCard(
                      widget.match.team1?.displayName ?? 'Team 1',
                      team1TotalScore,
                      team1RoundScore,
                      team1ThrowsRemaining,
                      true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildScoreCard(
                      widget.match.team2?.displayName ?? 'Team 2',
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