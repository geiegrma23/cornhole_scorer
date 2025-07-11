import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_settings.dart';

class SettingsService {
  // Save settings to device storage
  static Future<void> saveSettings(GameSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsMap = settings.toMap();
    
    // Convert Map to individual key-value pairs for SharedPreferences
    await prefs.setBool('isDarkTheme', settingsMap['isDarkTheme'] ?? false);
    await prefs.setBool('knockbackEnabled', settingsMap['knockbackEnabled'] ?? false);
    await prefs.setInt('knockbackScore', settingsMap['knockbackScore'] ?? 15);
    await prefs.setInt('winningScore', settingsMap['winningScore'] ?? 21);
    await prefs.setBool('soundEnabled', settingsMap['soundEnabled'] ?? true);
    await prefs.setBool('vibrationEnabled', settingsMap['vibrationEnabled'] ?? true);
    await prefs.setBool('confirmRoundEnd', settingsMap['confirmRoundEnd'] ?? false);
    await prefs.setInt('maxRoundPoints', settingsMap['maxRoundPoints'] ?? 12);
    await prefs.setInt('throwsPerTeam', settingsMap['throwsPerTeam'] ?? 4);
  }
  
  // Load settings from device storage
  static Future<GameSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return GameSettings(
      isDarkTheme: prefs.getBool('isDarkTheme') ?? false,
      knockbackEnabled: prefs.getBool('knockbackEnabled') ?? false,
      knockbackScore: prefs.getInt('knockbackScore') ?? 15,
      winningScore: prefs.getInt('winningScore') ?? 21,
      soundEnabled: prefs.getBool('soundEnabled') ?? true,
      vibrationEnabled: prefs.getBool('vibrationEnabled') ?? true,
      confirmRoundEnd: prefs.getBool('confirmRoundEnd') ?? false,
      maxRoundPoints: prefs.getInt('maxRoundPoints') ?? 12,
      throwsPerTeam: prefs.getInt('throwsPerTeam') ?? 4,
    );
  }
  
  // Clear all settings (reset to defaults)
  static Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isDarkTheme');
    await prefs.remove('knockbackEnabled');
    await prefs.remove('knockbackScore');
    await prefs.remove('winningScore');
    await prefs.remove('soundEnabled');
    await prefs.remove('vibrationEnabled');
    await prefs.remove('confirmRoundEnd');
    await prefs.remove('maxRoundPoints');
    await prefs.remove('throwsPerTeam');
  }
  
  // Check if settings exist (for first-time users)
  static Future<bool> hasSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('isDarkTheme'); // Check if any setting exists
  }
}