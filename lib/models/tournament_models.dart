enum TournamentFormat {
  singleElimination,
  doubleElimination,
}

enum MatchStatus {
  pending,
  inProgress,
  completed,
}

class Player {
  final String id;
  final String name;

  Player({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }
}

class Team {
  final String id;
  final String name;
  final List<Player> players;
  int wins;
  int losses;
  int totalScore;
  int gamesPlayed;

  Team({
    required this.id,
    required this.name,
    required this.players,
    this.wins = 0,
    this.losses = 0,
    this.totalScore = 0,
    this.gamesPlayed = 0,
  });

  String get displayName {
    if (players.length == 1) {
      return players.first.name;
    } else if (players.length == 2) {
      return '${players[0].name} & ${players[1].name}';
    } else {
      return name.isNotEmpty ? name : 'Team ${id.substring(0, 4)}';
    }
  }

  double get averageScore {
    return gamesPlayed > 0 ? totalScore / gamesPlayed : 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'players': players.map((p) => p.toMap()).toList(),
      'wins': wins,
      'losses': losses,
      'totalScore': totalScore,
      'gamesPlayed': gamesPlayed,
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      players: (map['players'] as List<dynamic>?)
          ?.map((p) => Player.fromMap(p))
          .toList() ?? [],
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      totalScore: map['totalScore'] ?? 0,
      gamesPlayed: map['gamesPlayed'] ?? 0,
    );
  }
}

class Match {
  final String id;
  final String tournamentId;
  final int round;
  final int position;
  Team? team1;
  Team? team2;
  Team? winner;
  Team? loser;
  int team1Score;
  int team2Score;
  MatchStatus status;
  final String? nextMatchId; // For bracket progression
  final String? loserNextMatchId; // For double elimination loser bracket
  final bool isLoserBracket; // For double elimination

  Match({
    required this.id,
    required this.tournamentId,
    required this.round,
    required this.position,
    this.team1,
    this.team2,
    this.winner,
    this.loser,
    this.team1Score = 0,
    this.team2Score = 0,
    this.status = MatchStatus.pending,
    this.nextMatchId,
    this.loserNextMatchId,
    this.isLoserBracket = false,
  });

  bool get isReady => team1 != null && team2 != null && status == MatchStatus.pending;
  bool get isEmpty => team1 == null && team2 == null;
  bool get hasWinner => winner != null;

  String get displayName {
    if (team1 == null && team2 == null) {
      return 'TBD vs TBD';
    } else if (team1 == null) {
      return 'TBD vs ${team2!.displayName}';
    } else if (team2 == null) {
      return '${team1!.displayName} vs TBD';
    } else {
      return '${team1!.displayName} vs ${team2!.displayName}';
    }
  }

  void completeMatch(Team winningTeam, int winnerScore, int loserScore) {
    if (winningTeam == team1) {
      winner = team1;
      loser = team2;
      team1Score = winnerScore;
      team2Score = loserScore;
    } else {
      winner = team2;
      loser = team1;
      team1Score = loserScore;
      team2Score = winnerScore;
    }
    status = MatchStatus.completed;
    
    // Update team stats
    winner!.wins++;
    winner!.gamesPlayed++;
    winner!.totalScore += winnerScore;
    
    loser!.losses++;
    loser!.gamesPlayed++;
    loser!.totalScore += loserScore;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'round': round,
      'position': position,
      'team1': team1?.toMap(),
      'team2': team2?.toMap(),
      'winner': winner?.toMap(),
      'loser': loser?.toMap(),
      'team1Score': team1Score,
      'team2Score': team2Score,
      'status': status.index,
      'nextMatchId': nextMatchId,
      'loserNextMatchId': loserNextMatchId,
      'isLoserBracket': isLoserBracket,
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'] ?? '',
      tournamentId: map['tournamentId'] ?? '',
      round: map['round'] ?? 0,
      position: map['position'] ?? 0,
      team1: map['team1'] != null ? Team.fromMap(map['team1']) : null,
      team2: map['team2'] != null ? Team.fromMap(map['team2']) : null,
      winner: map['winner'] != null ? Team.fromMap(map['winner']) : null,
      loser: map['loser'] != null ? Team.fromMap(map['loser']) : null,
      team1Score: map['team1Score'] ?? 0,
      team2Score: map['team2Score'] ?? 0,
      status: MatchStatus.values[map['status'] ?? 0],
      nextMatchId: map['nextMatchId'],
      loserNextMatchId: map['loserNextMatchId'],
      isLoserBracket: map['isLoserBracket'] ?? false,
    );
  }
}

class Tournament {
  final String id;
  final String name;
  final TournamentFormat format;
  final List<Team> teams;
  final List<Match> matches;
  final DateTime createdAt;
  bool isCompleted;
  List<Team> finalRankings;

  Tournament({
    required this.id,
    required this.name,
    required this.format,
    required this.teams,
    required this.matches,
    required this.createdAt,
    this.isCompleted = false,
    this.finalRankings = const [],
  });

  int get totalRounds {
    if (teams.isEmpty) return 0;
    return format == TournamentFormat.singleElimination 
        ? _calculateSingleEliminationRounds()
        : _calculateDoubleEliminationRounds();
  }

  int _calculateSingleEliminationRounds() {
    int teamCount = teams.length;
    int rounds = 0;
    while (teamCount > 1) {
      teamCount = (teamCount / 2).ceil();
      rounds++;
    }
    return rounds;
  }

  int _calculateDoubleEliminationRounds() {
    // Double elimination is more complex - winner bracket + loser bracket
    int teamCount = teams.length;
    int winnerRounds = 0;
    while (teamCount > 1) {
      teamCount = (teamCount / 2).ceil();
      winnerRounds++;
    }
    // Loser bracket typically has (2 * winnerRounds - 1) rounds
    return winnerRounds + (2 * winnerRounds - 1);
  }

  Match? get nextMatch {
    return matches.where((m) => m.isReady).isNotEmpty 
        ? matches.where((m) => m.isReady).first 
        : null;
  }

  List<Match> get completedMatches {
    return matches.where((m) => m.status == MatchStatus.completed).toList();
  }

  List<Match> get pendingMatches {
    return matches.where((m) => m.status == MatchStatus.pending).toList();
  }

  double get completionPercentage {
    if (matches.isEmpty) return 0.0;
    return completedMatches.length / matches.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'format': format.index,
      'teams': teams.map((t) => t.toMap()).toList(),
      'matches': matches.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'finalRankings': finalRankings.map((t) => t.toMap()).toList(),
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      format: TournamentFormat.values[map['format'] ?? 0],
      teams: (map['teams'] as List<dynamic>?)
          ?.map((t) => Team.fromMap(t))
          .toList() ?? [],
      matches: (map['matches'] as List<dynamic>?)
          ?.map((m) => Match.fromMap(m))
          .toList() ?? [],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isCompleted: map['isCompleted'] ?? false,
      finalRankings: (map['finalRankings'] as List<dynamic>?)
          ?.map((t) => Team.fromMap(t))
          .toList() ?? [],
    );
  }
}