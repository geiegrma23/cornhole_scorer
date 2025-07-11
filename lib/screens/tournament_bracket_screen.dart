import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/tournament_models.dart';
import '../services/tournament_service.dart';
import 'tournament_game_screen.dart';
import 'tournament_results_screen.dart';
import 'home_screen.dart';

class TournamentBracketScreen extends StatefulWidget {
  final Tournament tournament;
  final GameSettings gameSettings;

  const TournamentBracketScreen({
    Key? key,
    required this.tournament,
    required this.gameSettings,
  }) : super(key: key);

  @override
  State<TournamentBracketScreen> createState() => _TournamentBracketScreenState();
}

class _TournamentBracketScreenState extends State<TournamentBracketScreen> {
  late Tournament _tournament;

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
  }

  void _playNextMatch() {
    final nextMatch = _tournament.nextMatch;
    if (nextMatch != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TournamentGameScreen(
            tournament: _tournament,
            match: nextMatch,
            gameSettings: widget.gameSettings,
            onMatchComplete: _onMatchComplete,
          ),
        ),
      );
    }
  }

  void _onMatchComplete(Match completedMatch) {
    setState(() {
      // Update the match in the tournament
      final matchIndex = _tournament.matches.indexWhere((m) => m.id == completedMatch.id);
      if (matchIndex != -1) {
        _tournament.matches[matchIndex] = completedMatch;
      }
      
      // Advance the tournament
      try {
        TournamentService.advanceTournament(_tournament, completedMatch);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error advancing tournament: $e')),
        );
      }
    });

    // Check if tournament is complete
    if (_tournament.isCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TournamentResultsScreen(
            tournament: _tournament,
            gameSettings: widget.gameSettings,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final completionPercentage = _tournament.completionPercentage;
    final nextMatch = _tournament.nextMatch;

    return Scaffold(
      backgroundColor: widget.gameSettings.isDarkTheme ? Colors.grey.shade900 : Colors.blue.shade50,
      appBar: AppBar(
        title: Text(_tournament.name),
        backgroundColor: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exit Tournament'),
                  content: const Text('Are you sure you want to exit? Tournament progress will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
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
                      child: const Text('Exit'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tournament Progress
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _tournament.format == TournamentFormat.singleElimination
                          ? 'Single Elimination'
                          : 'Double Elimination',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${_tournament.teams.length} Teams',
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.gameSettings.isDarkTheme ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: completionPercentage,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(completionPercentage * 100).round()}% Complete',
                  style: TextStyle(
                    color: widget.gameSettings.isDarkTheme ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Next Match Section
          if (nextMatch != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.play_circle_filled, color: Colors.green, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Next Match Ready',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nextMatch.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Round ${nextMatch.round}${nextMatch.isLoserBracket ? ' (Loser Bracket)' : ''}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _playNextMatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Play Match',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Bracket View
          Expanded(
            child: _buildBracketView(),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketView() {
    if (_tournament.matches.isEmpty) {
      return const Center(
        child: Text('No matches available'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (_tournament.format == TournamentFormat.singleElimination)
          _buildSingleEliminationBracket()
        else
          _buildDoubleEliminationBracket(),
      ],
    );
  }

  Widget _buildSingleEliminationBracket() {
    final rounds = <int, List<Match>>{};
    
    // Group matches by round
    for (final match in _tournament.matches) {
      if (!match.isLoserBracket) {
        rounds.putIfAbsent(match.round, () => []).add(match);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tournament Bracket',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...rounds.entries.map((entry) => _buildRoundSection(
          'Round ${entry.key}',
          entry.value,
        )),
      ],
    );
  }

  Widget _buildDoubleEliminationBracket() {
    final winnerBracket = <int, List<Match>>{};
    final loserBracket = <int, List<Match>>{};
    
    // Group matches by bracket and round
    for (final match in _tournament.matches) {
      if (match.isLoserBracket) {
        loserBracket.putIfAbsent(match.round, () => []).add(match);
      } else {
        winnerBracket.putIfAbsent(match.round, () => []).add(match);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Winner Bracket',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...winnerBracket.entries.map((entry) => _buildRoundSection(
          'Round ${entry.key}',
          entry.value,
        )),
        
        const SizedBox(height: 24),
        
        if (loserBracket.isNotEmpty) ...[
          Text(
            'Loser Bracket',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...loserBracket.entries.map((entry) => _buildRoundSection(
            'Loser Round ${entry.key}',
            entry.value,
          )),
        ],
      ],
    );
  }

  Widget _buildRoundSection(String title, List<Match> matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.gameSettings.isDarkTheme ? Colors.white70 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...matches.map((match) => _buildMatchCard(match)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMatchCard(Match match) {
    Color cardColor;
    Color textColor = widget.gameSettings.isDarkTheme ? Colors.white : Colors.black87;
    
    switch (match.status) {
      case MatchStatus.completed:
        cardColor = Colors.green.shade100;
        break;
      case MatchStatus.inProgress:
        cardColor = Colors.orange.shade100;
        break;
      case MatchStatus.pending:
        if (match.isReady) {
          cardColor = Colors.blue.shade100;
        } else {
          cardColor = Colors.grey.shade200;
          textColor = Colors.grey;
        }
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (match.status == MatchStatus.completed)
                  const Icon(Icons.check_circle, color: Colors.green),
                if (match.status == MatchStatus.pending && match.isReady)
                  const Icon(Icons.play_arrow, color: Colors.blue),
              ],
            ),
            if (match.status == MatchStatus.completed) ...[
              const SizedBox(height: 4),
              Text(
                'Final: ${match.team1Score} - ${match.team2Score}',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Winner: ${match.winner?.displayName ?? 'TBD'}',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}