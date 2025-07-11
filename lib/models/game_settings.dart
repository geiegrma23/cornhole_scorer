class GameSettings {
  // Theme Settings
  bool isDarkTheme;
  
  // Game Rules
  bool knockbackEnabled;
  int knockbackScore;
  int winningScore;
  
  // Gameplay
  bool soundEnabled;
  bool vibrationEnabled;
  bool confirmRoundEnd;
  
  // Advanced
  int maxRoundPoints;
  int throwsPerTeam;

  GameSettings({
    this.isDarkTheme = false,
    this.knockbackEnabled = false,
    this.knockbackScore = 15,
    this.winningScore = 21,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.confirmRoundEnd = false,
    this.maxRoundPoints = 12,
    this.throwsPerTeam = 4,
  });

  GameSettings copy() {
    return GameSettings(
      isDarkTheme: isDarkTheme,
      knockbackEnabled: knockbackEnabled,
      knockbackScore: knockbackScore,
      winningScore: winningScore,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      confirmRoundEnd: confirmRoundEnd,
      maxRoundPoints: maxRoundPoints,
      throwsPerTeam: throwsPerTeam,
    );
  }

  // Convert to/from Map for storage (future Firebase integration)
  Map<String, dynamic> toMap() {
    return {
      'isDarkTheme': isDarkTheme,
      'knockbackEnabled': knockbackEnabled,
      'knockbackScore': knockbackScore,
      'winningScore': winningScore,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'confirmRoundEnd': confirmRoundEnd,
      'maxRoundPoints': maxRoundPoints,
      'throwsPerTeam': throwsPerTeam,
    };
  }

  factory GameSettings.fromMap(Map<String, dynamic> map) {
    return GameSettings(
      isDarkTheme: map['isDarkTheme'] ?? false,
      knockbackEnabled: map['knockbackEnabled'] ?? false,
      knockbackScore: map['knockbackScore'] ?? 15,
      winningScore: map['winningScore'] ?? 21,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      confirmRoundEnd: map['confirmRoundEnd'] ?? false,
      maxRoundPoints: map['maxRoundPoints'] ?? 12,
      throwsPerTeam: map['throwsPerTeam'] ?? 4,
    );
  }
}