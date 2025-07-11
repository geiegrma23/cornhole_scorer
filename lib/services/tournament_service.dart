import 'dart:math';
import '../models/tournament_models.dart';

class TournamentService {
  static List<Team> shuffleTeams(List<Team> teams) {
    final List<Team> shuffled = List.from(teams);
    shuffled.shuffle();
    return shuffled;
  }

  static List<Team> createRandomTeams(List<Player> players) {
    if (players.length % 2 != 0) {
      throw ArgumentError('Number of players must be even to create teams');
    }
    
    final List<Player> shuffledPlayers = List.from(players);
    shuffledPlayers.shuffle();
    
    final List<Team> teams = [];
    for (int i = 0; i < shuffledPlayers.length; i += 2) {
      final team = Team(
        id: _generateId(),
        name: '',
        players: [shuffledPlayers[i], shuffledPlayers[i + 1]],
      );
      teams.add(team);
    }
    
    return teams;
  }

  static Tournament createTournament({
    required String name,
    required TournamentFormat format,
    required List<Team> teams,
  }) {
    if (teams.length < 2) {
      throw ArgumentError('Tournament must have at least 2 teams');
    }
    
    final tournament = Tournament(
      id: _generateId(),
      name: name,
      format: format,
      teams: teams,
      matches: [],
      createdAt: DateTime.now(),
    );
    
    final matches = format == TournamentFormat.singleElimination
        ? _generateSingleEliminationBracket(tournament)
        : _generateDoubleEliminationBracket(tournament);
    
    return Tournament(
      id: tournament.id,
      name: tournament.name,
      format: tournament.format,
      teams: tournament.teams,
      matches: matches,
      createdAt: tournament.createdAt,
    );
  }

  static List<Match> _generateSingleEliminationBracket(Tournament tournament) {
    final List<Match> matches = [];
    final teams = List<Team>.from(tournament.teams);
    
    // Calculate total rounds needed
    int totalTeams = teams.length;
    int currentRound = 1;
    
    // First round - pair up all teams
    List<Team?> currentTeams = List<Team?>.from(teams);
    
    // Add byes if needed to make it a power of 2
    int nextPowerOf2 = _getNextPowerOf2(totalTeams);
    while (currentTeams.length < nextPowerOf2) {
      currentTeams.add(null); // null represents a bye
    }
    
    // Generate matches for each round
    while (currentTeams.length > 1) {
      List<Team?> nextRoundTeams = [];
      int matchPosition = 0;
      
      for (int i = 0; i < currentTeams.length; i += 2) {
        final team1 = currentTeams[i];
        final team2 = currentTeams[i + 1];
        
        if (team1 != null && team2 != null) {
          // Regular match
          final match = Match(
            id: _generateId(),
            tournamentId: tournament.id,
            round: currentRound,
            position: matchPosition,
            team1: team1,
            team2: team2,
          );
          matches.add(match);
          nextRoundTeams.add(null); // Winner will be determined later
          matchPosition++;
        } else if (team1 != null) {
          // team1 gets a bye
          nextRoundTeams.add(team1);
        } else if (team2 != null) {
          // team2 gets a bye
          nextRoundTeams.add(team2);
        }
      }
      
      currentTeams = nextRoundTeams;
      currentRound++;
    }
    
    return matches;
  }

  static List<Match> _generateDoubleEliminationBracket(Tournament tournament) {
    final List<Match> matches = [];
    
    // Generate winner bracket (same as single elimination)
    final winnerBracketMatches = _generateSingleEliminationBracket(tournament);
    matches.addAll(winnerBracketMatches);
    
    // Generate loser bracket
    final loserBracketMatches = _generateLoserBracket(tournament, winnerBracketMatches);
    matches.addAll(loserBracketMatches);
    
    // Add grand final matches
    final grandFinalMatches = _generateGrandFinal(tournament);
    matches.addAll(grandFinalMatches);
    
    return matches;
  }

  static List<Match> _generateLoserBracket(Tournament tournament, List<Match> winnerBracket) {
    final List<Match> loserMatches = [];
    
    // This is a simplified loser bracket generation
    // In a real implementation, this would be more complex
    final int rounds = winnerBracket.map((m) => m.round).reduce(max);
    
    for (int round = 1; round < rounds; round++) {
      final roundMatches = winnerBracket.where((m) => m.round == round).toList();
      
      for (int i = 0; i < roundMatches.length; i++) {
        final loserMatch = Match(
          id: _generateId(),
          tournamentId: tournament.id,
          round: round,
          position: i,
          isLoserBracket: true,
        );
        loserMatches.add(loserMatch);
      }
    }
    
    return loserMatches;
  }

  static List<Match> _generateGrandFinal(Tournament tournament) {
    // Grand final and potential grand final reset for double elimination
    return [
      Match(
        id: _generateId(),
        tournamentId: tournament.id,
        round: 999, // Special round number for grand final
        position: 0,
      ),
    ];
  }

  static void advanceTournament(Tournament tournament, Match completedMatch) {
    if (!completedMatch.hasWinner) {
      throw ArgumentError('Match must have a winner to advance tournament');
    }

    if (tournament.format == TournamentFormat.singleElimination) {
      _advanceSingleElimination(tournament, completedMatch);
    } else {
      _advanceDoubleElimination(tournament, completedMatch);
    }

    // Check if tournament is complete
    _checkTournamentCompletion(tournament);
  }

  static void _advanceSingleElimination(Tournament tournament, Match completedMatch) {
    // Find next match in the same bracket
    final nextRound = completedMatch.round + 1;
    final nextPosition = completedMatch.position ~/ 2;
    
    final nextMatch = tournament.matches.where((m) => 
        m.round == nextRound && 
        m.position == nextPosition &&
        !m.isLoserBracket
    ).firstOrNull;
    
    if (nextMatch != null) {
      // Determine which slot to fill (team1 or team2)
      if (completedMatch.position % 2 == 0) {
        nextMatch.team1 = completedMatch.winner;
      } else {
        nextMatch.team2 = completedMatch.winner;
      }
    }
  }

  static void _advanceDoubleElimination(Tournament tournament, Match completedMatch) {
    // This is a simplified version - real double elimination is more complex
    if (!completedMatch.isLoserBracket) {
      // Winner advances in winner bracket
      _advanceSingleElimination(tournament, completedMatch);
      
      // Loser goes to loser bracket
      final loserMatch = tournament.matches.where((m) => 
          m.isLoserBracket && 
          m.team1 == null && 
          m.team2 == null
      ).firstOrNull;
      
      if (loserMatch != null) {
        if (loserMatch.team1 == null) {
          loserMatch.team1 = completedMatch.loser;
        } else {
          loserMatch.team2 = completedMatch.loser;
        }
      }
    } else {
      // Loser bracket advancement
      _advanceSingleElimination(tournament, completedMatch);
    }
  }

  static void _checkTournamentCompletion(Tournament tournament) {
    // Tournament is complete when there are no more ready matches
    final hasReadyMatches = tournament.matches.any((m) => m.isReady);
    final hasIncompleteMatches = tournament.matches.any((m) => 
        m.status == MatchStatus.pending && (m.team1 != null && m.team2 != null)
    );
    
    if (!hasReadyMatches && !hasIncompleteMatches) {
      tournament.isCompleted = true;
      _generateFinalRankings(tournament);
    }
  }

  static void _generateFinalRankings(Tournament tournament) {
    final teams = List<Team>.from(tournament.teams);
    
    // Sort teams by:
    // 1. Wins (descending)
    // 2. Total score (descending) 
    // 3. Round eliminated (later rounds = better ranking)
    teams.sort((a, b) {
      // Primary: More wins first
      if (a.wins != b.wins) {
        return b.wins.compareTo(a.wins);
      }
      
      // Secondary: Higher total score first
      if (a.totalScore != b.totalScore) {
        return b.totalScore.compareTo(a.totalScore);
      }
      
      // Tertiary: Round eliminated (find latest round where team lost)
      int teamAEliminatedRound = _getEliminationRound(tournament, a);
      int teamBEliminatedRound = _getEliminationRound(tournament, b);
      
      return teamBEliminatedRound.compareTo(teamAEliminatedRound);
    });
    
    tournament.finalRankings.clear();
    tournament.finalRankings.addAll(teams);
  }
  
  static int _getEliminationRound(Tournament tournament, Team team) {
    // Find the latest round where this team lost
    int latestRound = 0;
    
    for (final match in tournament.matches) {
      if (match.status == MatchStatus.completed && match.loser == team) {
        if (match.round > latestRound) {
          latestRound = match.round;
        }
      }
    }
    
    // If team never lost, they made it to the final
    if (latestRound == 0) {
      final maxRound = tournament.matches.isEmpty 
          ? 1 
          : tournament.matches.map((m) => m.round).reduce((a, b) => a > b ? a : b);
      return maxRound + 1; // Winner gets a bonus round
    }
    
    return latestRound;
  }

  static int _getNextPowerOf2(int n) {
    int power = 1;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}