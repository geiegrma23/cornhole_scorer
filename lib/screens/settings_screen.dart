import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final GameSettings currentSettings;
  final Function(GameSettings) onSettingsChanged;

  const SettingsScreen({
    Key? key,
    required this.currentSettings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.currentSettings.copy();
  }

  Future<void> _updateSetting<T>(T value, void Function(T) setter) async {
    setState(() {
      setter(value);
    });
    
    // Save settings immediately when changed
    try {
      await SettingsService.saveSettings(_settings);
      widget.onSettingsChanged(_settings);
    } catch (e) {
      // Handle save error with mounted check
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _settings.isDarkTheme ? Colors.grey.shade900 : Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: _settings.isDarkTheme ? Colors.grey.shade800 : Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Settings
          _buildSectionCard(
            'Appearance',
            [
              SwitchListTile(
                title: const Text('Dark Theme'),
                subtitle: const Text('Switch between light and dark themes'),
                value: _settings.isDarkTheme,
                onChanged: (value) => _updateSetting(value, (v) => _settings.isDarkTheme = v),
                secondary: Icon(_settings.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Game Rules Settings
          _buildSectionCard(
            'Game Rules',
            [
              SwitchListTile(
                title: const Text('Knockback Rule'),
                subtitle: Text('Reset score when over ${_settings.winningScore}'),
                value: _settings.knockbackEnabled,
                onChanged: (value) => _updateSetting(value, (v) => _settings.knockbackEnabled = v),
                secondary: const Icon(Icons.refresh),
              ),
              
              if (_settings.knockbackEnabled) ...[
                const Divider(),
                ListTile(
                  title: const Text('Knockback Score'),
                  subtitle: Text('Score to reset to: ${_settings.knockbackScore}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _settings.knockbackScore > 10 
                          ? () => _updateSetting(_settings.knockbackScore - 1, (v) => _settings.knockbackScore = v)
                          : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text('${_settings.knockbackScore}', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        onPressed: _settings.knockbackScore < 20 
                          ? () => _updateSetting(_settings.knockbackScore + 1, (v) => _settings.knockbackScore = v)
                          : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
              
              const Divider(),
              
              ListTile(
                title: const Text('Winning Score'),
                subtitle: Text('First to reach: ${_settings.winningScore} points'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _settings.winningScore > 15 
                        ? () => _updateSetting(_settings.winningScore - 1, (v) => _settings.winningScore = v)
                        : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text('${_settings.winningScore}', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      onPressed: _settings.winningScore < 30 
                        ? () => _updateSetting(_settings.winningScore + 1, (v) => _settings.winningScore = v)
                        : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Gameplay Settings
          _buildSectionCard(
            'Gameplay',
            [
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Play sounds for scoring and game events'),
                value: _settings.soundEnabled,
                onChanged: (value) => _updateSetting(value, (v) => _settings.soundEnabled = v),
                secondary: Icon(_settings.soundEnabled ? Icons.volume_up : Icons.volume_off),
              ),
              
              const Divider(),
              
              SwitchListTile(
                title: const Text('Vibration Feedback'),
                subtitle: const Text('Vibrate on button presses and game events'),
                value: _settings.vibrationEnabled,
                onChanged: (value) => _updateSetting(value, (v) => _settings.vibrationEnabled = v),
                secondary: const Icon(Icons.vibration),
              ),
              
              const Divider(),
              
              SwitchListTile(
                title: const Text('Confirm Round End'),
                subtitle: const Text('Show confirmation before ending each round'),
                value: _settings.confirmRoundEnd,
                onChanged: (value) => _updateSetting(value, (v) => _settings.confirmRoundEnd = v),
                secondary: const Icon(Icons.check_circle_outline),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Advanced Settings
          _buildSectionCard(
            'Advanced',
            [
              ListTile(
                title: const Text('Max Round Points'),
                subtitle: Text('Maximum points per round: ${_settings.maxRoundPoints}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _settings.maxRoundPoints > 8 
                        ? () => _updateSetting(_settings.maxRoundPoints - 1, (v) => _settings.maxRoundPoints = v)
                        : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text('${_settings.maxRoundPoints}', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      onPressed: _settings.maxRoundPoints < 16 
                        ? () => _updateSetting(_settings.maxRoundPoints + 1, (v) => _settings.maxRoundPoints = v)
                        : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              ListTile(
                title: const Text('Throws Per Team'),
                subtitle: Text('Bags per team per round: ${_settings.throwsPerTeam}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _settings.throwsPerTeam > 2 
                        ? () => _updateSetting(_settings.throwsPerTeam - 1, (v) => _settings.throwsPerTeam = v)
                        : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text('${_settings.throwsPerTeam}', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      onPressed: _settings.throwsPerTeam < 6 
                        ? () => _updateSetting(_settings.throwsPerTeam + 1, (v) => _settings.throwsPerTeam = v)
                        : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Reset to Defaults
          Card(
            elevation: 4,
            child: ListTile(
              title: const Text('Reset to Defaults'),
              subtitle: const Text('Restore all settings to their default values'),
              leading: const Icon(Icons.restore, color: Colors.orange),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Settings'),
                    content: const Text('Are you sure you want to reset all settings to their default values?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _resetToDefaults();
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    try {
      await SettingsService.clearSettings();
      setState(() {
        _settings = GameSettings();
      });
      widget.onSettingsChanged(_settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset to defaults')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resetting settings: $e')),
        );
      }
    }
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _settings.isDarkTheme ? Colors.white : Colors.blue.shade800,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}