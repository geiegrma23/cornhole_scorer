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
      // Handle odd number of players by creating a single-player team
      final List<Player> workingPlayers = List.from(players);
      final lastPlayer = workingPlayers.removeLast();
      
      final List<Team> teams = [];
      
      // Create teams of 2 from the even number of remaining players
      for (int i = 0; i < workingPlayers.length; i += 2) {
        final team = Team(
          id: _generateId(),
          name: '',
          players: [workingPlayers[i], workingPlayers[i + 1]],
        );
        teams.add(team);
      }
      
      // Add the single-player team
      teams.add(Team(
        id: _generateId(),
        name: '',
        players: [lastPlayer],
      ));
      
      return teams;
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
    final List<Match> allMatches = [];
    final teams = List<Team>.from(tournament.teams);
    
    // Calculate total rounds needed
    int totalTeams = teams.length;
    int rounds = 0;
    int tempTeams = totalTeams;
    while (tempTeams > 1) {
      tempTeams = (tempTeams / 2).ceil();
      rounds++;
    }
    
    print('DEBUG: Creating ${rounds} rounds for ${totalTeams} teams');
    
    // Create bracket structure: Calculate matches for each round
    List<int> matchesPerRound = [];
    int teamsInRound = totalTeams;
    for (int round = 1; round <= rounds; round++) {
      int matchesThisRound = teamsInRound ~/ 2;
      matchesPerRound.add(matchesThisRound);
      teamsInRound = (teamsInRound / 2).ceil();
      print('DEBUG: Round $round will have $matchesThisRound matches');
    }
    
    // Generate all matches for all rounds upfront
    for (int round = 1; round <= rounds; round++) {
      int matchesThisRound = matchesPerRound[round - 1];
      
      for (int position = 0; position < matchesThisRound; position++) {
        final match = Match(
          id: _generateId(),
          tournamentId: tournament.id,
          round: round,
          position: position,
        );
        
        allMatches.add(match);
        print('DEBUG: Created match R${round}P${position}');
      }
    }
    
    // Now assign teams to appropriate rounds, handling byes correctly
    _assignTeamsWithByes(allMatches, teams);
    
    return allMatches;
  }

  static void _assignTeamsWithByes(List<Match> allMatches, List<Team> teams) {
    int totalTeams = teams.length;
    
    if (totalTeams % 2 == 0) {
      // Even number of teams - no byes needed, everyone plays in round 1
      print('DEBUG: ${totalTeams} teams (even) - no byes needed');
      
      List<Match> firstRoundMatches = allMatches.where((m) => m.round == 1).toList();
      int teamIndex = 0;
      
      for (int i = 0; i < firstRoundMatches.length; i++) {
        final match = firstRoundMatches[i];
        match.team1 = teams[teamIndex++];
        match.team2 = teams[teamIndex++];
        print('DEBUG: R1P${i}: ${match.team1!.displayName} vs ${match.team2!.displayName}');
      }
    } else {
      // Odd number of teams - one team gets a bye to round 2
      int firstRoundTeams = totalTeams - 1; // All teams except one play in round 1
      print('DEBUG: ${totalTeams} teams (odd) - 1 team gets bye, ${firstRoundTeams} play in round 1');
      
      List<Match> firstRoundMatches = allMatches.where((m) => m.round == 1).toList();
      int teamIndex = 0;
      
      // Assign teams to round 1 matches
      for (int i = 0; i < firstRoundMatches.length; i++) {
        final match = firstRoundMatches[i];
        match.team1 = teams[teamIndex++];
        match.team2 = teams[teamIndex++];
        print('DEBUG: R1P${i}: ${match.team1!.displayName} vs ${match.team2!.displayName}');
      }
      
      // Assign the remaining team to round 2 as a bye
      final byeTeam = teams[teamIndex];
      List<Match> secondRoundMatches = allMatches.where((m) => m.round == 2).toList();
      
      if (secondRoundMatches.isNotEmpty) {
        final firstR2Match = secondRoundMatches.first;
        firstR2Match.team1 = byeTeam;
        print('DEBUG: ${byeTeam.displayName} gets bye to R2P${firstR2Match.position} as team1');
      }
    }
    
    // Print final bracket state for verification
    print('DEBUG: Final bracket assignments:');
    for (final match in allMatches) {
      if (match.team1 != null || match.team2 != null) {
        print('DEBUG: R${match.round}P${match.position}: ${match.team1?.displayName ?? "TBD"} vs ${match.team2?.displayName ?? "TBD"}');
      }
    }
  }

  static List<Match> _generateDoubleEliminationBracket(Tournament tournament) {
    final List<Match> matches = [];
    
    // Generate winner bracket (same as single elimination)
    final winnerBracketMatches = _generateSingleEliminationBracket(tournament);
    matches.addAll(winnerBracketMatches);
    
    // Generate loser bracket - simplified for now
    final loserBracketMatches = _generateLoserBracket(tournament, winnerBracketMatches);
    matches.addAll(loserBracketMatches);
    
    // Add grand final matches
    final grandFinalMatches = _generateGrandFinal(tournament);
    matches.addAll(grandFinalMatches);
    
    return matches;
  }

  static List<Match> _generateLoserBracket(Tournament tournament, List<Match> winnerBracket) {
    final List<Match> loserMatches = [];
    
    // For now, create a simplified loser bracket
    final int winnerRounds = winnerBracket.map((m) => m.round).reduce(max);
    
    // Create loser bracket rounds
    for (int round = 1; round <= winnerRounds * 2 - 1; round++) {
      int matchesInRound = _calculateLoserBracketMatches(tournament.teams.length, round);
      
      for (int i = 0; i < matchesInRound; i++) {
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

  static int _calculateLoserBracketMatches(int teamCount, int round) {
    // Simplified calculation
    int remaining = teamCount;
    for (int i = 1; i < round; i++) {
      remaining = remaining ~/ 2;
    }
    return max(1, remaining ~/ 2);
  }

  static List<Match> _generateGrandFinal(Tournament tournament) {
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

    // Set the loser
    if (completedMatch.winner == completedMatch.team1) {
      completedMatch.loser = completedMatch.team2;
    } else {
      completedMatch.loser = completedMatch.team1;
    }

    print('DEBUG: Advancing tournament - ${completedMatch.winner!.displayName} beat ${completedMatch.loser?.displayName ?? "BYE"}');

    if (tournament.format == TournamentFormat.singleElimination) {
      _advanceSingleElimination(tournament, completedMatch);
    } else {
      _advanceDoubleElimination(tournament, completedMatch);
    }

    // Check if tournament is complete
    _checkTournamentCompletion(tournament);
  }

  static void _advanceSingleElimination(Tournament tournament, Match completedMatch) {
    // Handle byes first
    if (completedMatch.team2 == null && completedMatch.team1 != null) {
      // Team1 had a bye, automatically advance them
      completedMatch.winner = completedMatch.team1;
      completedMatch.status = MatchStatus.completed;
      print('DEBUG: ${completedMatch.team1!.displayName} advances via bye');
    }
    
    if (completedMatch.winner == null) {
      print('DEBUG: ERROR - No winner set for completed match');
      return;
    }
    
    // Find the next match where the winner should advance
    final nextRound = completedMatch.round + 1;
    final nextPosition = completedMatch.position ~/ 2;
    
    print('DEBUG: Looking for next match R${nextRound}P${nextPosition}');
    
    final nextMatch = tournament.matches.where((m) => 
        m.round == nextRound && 
        m.position == nextPosition &&
        !m.isLoserBracket
    ).firstOrNull;
    
    if (nextMatch != null) {
      // Determine which slot to fill based on the current match position
      if (completedMatch.position % 2 == 0) {
        nextMatch.team1 = completedMatch.winner;
        print('DEBUG: ${completedMatch.winner!.displayName} advances to R${nextRound}P${nextPosition} as team1');
      } else {
        nextMatch.team2 = completedMatch.winner;
        print('DEBUG: ${completedMatch.winner!.displayName} advances to R${nextRound}P${nextPosition} as team2');
      }
      
      // Check if this next match now has both teams and can be played
      if (nextMatch.team1 != null && nextMatch.team2 != null) {
        print('DEBUG: Match R${nextRound}P${nextPosition} is now ready: ${nextMatch.team1!.displayName} vs ${nextMatch.team2!.displayName}');
      }
    } else {
      print('DEBUG: No next match found - ${completedMatch.winner!.displayName} wins tournament!');
    }
  }

  static void _advanceDoubleElimination(Tournament tournament, Match completedMatch) {
    if (!completedMatch.isLoserBracket) {
      // Winner advances in winner bracket
      _advanceSingleElimination(tournament, completedMatch);
      
      // Loser goes to loser bracket
      if (completedMatch.loser != null) {
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
      }
    } else {
      // Loser bracket advancement - winner continues, loser is eliminated
      final nextRound = completedMatch.round + 1;
      final nextMatch = tournament.matches.where((m) => 
          m.isLoserBracket && 
          m.round == nextRound &&
          (m.team1 == null || m.team2 == null)
      ).firstOrNull;
      
      if (nextMatch != null) {
        if (nextMatch.team1 == null) {
          nextMatch.team1 = completedMatch.winner;
        } else {
          nextMatch.team2 = completedMatch.winner;
        }
      }
    }
  }

  static void _checkTournamentCompletion(Tournament tournament) {
    print('DEBUG: Checking tournament completion...');
    
    // Count different types of matches
    final completedMatches = tournament.matches.where((m) => m.status == MatchStatus.completed).length;
    final readyMatches = tournament.matches.where((m) => m.isReady).length;
    final waitingMatches = tournament.matches.where((m) => 
        m.status == MatchStatus.pending && (m.team1 == null || m.team2 == null)
    ).length;
    
    print('DEBUG: Completed: $completedMatches, Ready: $readyMatches, Waiting: $waitingMatches');
    
    // Tournament is complete when there are no ready matches AND no matches that could become ready
    if (readyMatches == 0) {
      // Check if any waiting matches could potentially become ready
      bool canAdvance = false;
      
      for (final waitingMatch in tournament.matches.where((m) => 
          m.status == MatchStatus.pending && (m.team1 == null || m.team2 == null))) {
        
        // Check if there are completed matches from previous round that should feed this match
        final prevRound = waitingMatch.round - 1;
        final feedingMatches = tournament.matches.where((m) =>
            m.round == prevRound &&
            m.status == MatchStatus.completed &&
            !m.isLoserBracket == !waitingMatch.isLoserBracket
        ).toList();
        
        print('DEBUG: Waiting match R${waitingMatch.round}P${waitingMatch.position} has ${feedingMatches.length} potential feeding matches from round $prevRound');
        
        if (feedingMatches.isNotEmpty) {
          canAdvance = true;
          break;
        }
      }
      
      if (!canAdvance) {
        print('DEBUG: Tournament completed - no more matches can be played');
        tournament.isCompleted = true;
        _generateFinalRankings(tournament);
      } else {
        print('DEBUG: Tournament continues - matches can still advance');
      }
    } else {
      print('DEBUG: Tournament continues - $readyMatches matches ready to play');
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
    
    // If team never lost, they made it to the final round
    if (latestRound == 0) {
      final maxRound = tournament.matches.isEmpty 
          ? 0 
          : tournament.matches.map((m) => m.round).reduce(max);
      return maxRound;
    }
    
    return latestRound;
  }

  static int _getNextPowerOf2(int number) {
    int power = 1;
    while (power < number) {
      power *= 2;
    }
    return power;
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }
}