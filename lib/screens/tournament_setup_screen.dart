import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/tournament_models.dart';
import '../services/tournament_service.dart';
import 'tournament_bracket_screen.dart';

class TournamentSetupScreen extends StatefulWidget {
  final GameSettings gameSettings;

  const TournamentSetupScreen({
    Key? key,
    required this.gameSettings,
  }) : super(key: key);

  @override
  State<TournamentSetupScreen> createState() => _TournamentSetupScreenState();
}

class _TournamentSetupScreenState extends State<TournamentSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tournamentNameController = TextEditingController();
  
  TournamentFormat _selectedFormat = TournamentFormat.singleElimination;
  bool _useRandomTeams = true;
  
  final List<Player> _players = [];
  
  final List<TextEditingController> _playerControllers = [];
  final List<TextEditingController> _teamControllers = [];

  @override
  void initState() {
    super.initState();
    _addPlayersForMinimum();
  }

  @override
  void dispose() {
    _tournamentNameController.dispose();
    for (var controller in _playerControllers) {
      controller.dispose();
    }
    for (var controller in _teamControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPlayersForMinimum() {
    // Start with 2 players minimum 
    for (int i = _playerControllers.length; i < 2; i++) {
      _playerControllers.add(TextEditingController());
    }
  }

  void _addPlayer() {
    setState(() {
      _playerControllers.add(TextEditingController());
    });
  }

  void _removePlayer(int index) {
    if (_playerControllers.length > 2) {
      setState(() {
        _playerControllers[index].dispose();
        _playerControllers.removeAt(index);
      });
    }
  }

  void _addTeam() {
    setState(() {
      _teamControllers.add(TextEditingController());
      _teamControllers.add(TextEditingController()); // Player 1
      _teamControllers.add(TextEditingController()); // Player 2
    });
  }

  void _removeTeam(int teamIndex) {
    if (_teamControllers.length > 6) { // Keep at least 2 teams (6 controllers)
      setState(() {
        for (int i = 0; i < 3; i++) {
          _teamControllers[teamIndex * 3 + i].dispose();
        }
        _teamControllers.removeRange(teamIndex * 3, teamIndex * 3 + 3);
      });
    }
  }

  void _createTournament() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      List<Team> teams;
      
      if (_useRandomTeams) {
        // Create players from input
        _players.clear();
        for (int i = 0; i < _playerControllers.length; i++) {
          final name = _playerControllers[i].text.trim();
          if (name.isNotEmpty) {
            _players.add(Player(
              id: 'player_${DateTime.now().millisecondsSinceEpoch}_$i',
              name: name,
            ));
          }
        }
        
        if (_players.length < 2) {
          _showError('Please enter at least 2 players');
          return;
        }
        
        teams = TournamentService.createRandomTeams(_players);
      } else {
        // Create teams from manual input
        teams = [];
        for (int i = 0; i < _teamControllers.length; i += 3) {
          final teamName = _teamControllers[i].text.trim();
          final player1Name = _teamControllers[i + 1].text.trim();
          final player2Name = _teamControllers[i + 2].text.trim();
          
          if (teamName.isNotEmpty && player1Name.isNotEmpty && player2Name.isNotEmpty) {
            teams.add(Team(
              id: 'team_${DateTime.now().millisecondsSinceEpoch}_${i ~/ 3}',
              name: teamName,
              players: [
                Player(id: 'player_${DateTime.now().millisecondsSinceEpoch}_${i + 1}', name: player1Name),
                Player(id: 'player_${DateTime.now().millisecondsSinceEpoch}_${i + 2}', name: player2Name),
              ],
            ));
          }
        }
        
        if (teams.length < 2) {
          _showError('Please create at least 2 complete teams');
          return;
        }
      }

      // Shuffle teams for fairness
      teams = TournamentService.shuffleTeams(teams);

      // Create tournament
      final tournament = TournamentService.createTournament(
        name: _tournamentNameController.text.trim(),
        format: _selectedFormat,
        teams: teams,
      );

      // Navigate to bracket screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TournamentBracketScreen(
              tournament: tournament,
              gameSettings: widget.gameSettings,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Error creating tournament: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.gameSettings.isDarkTheme ? Colors.grey.shade900 : Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Tournament Setup'),
        backgroundColor: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Tournament Name
            Card(
              elevation: 4,
              color: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tournament Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tournamentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tournament Name',
                        hintText: 'Enter tournament name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.emoji_events),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a tournament name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tournament Format
            Card(
              elevation: 4,
              color: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tournament Format',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RadioListTile<TournamentFormat>(
                      title: const Text('Single Elimination'),
                      subtitle: const Text('One loss and you\'re out'),
                      value: TournamentFormat.singleElimination,
                      groupValue: _selectedFormat,
                      onChanged: (value) {
                        setState(() {
                          _selectedFormat = value!;
                        });
                      },
                    ),
                    RadioListTile<TournamentFormat>(
                      title: const Text('Double Elimination'),
                      subtitle: const Text('Two losses to be eliminated'),
                      value: TournamentFormat.doubleElimination,
                      groupValue: _selectedFormat,
                      onChanged: (value) {
                        setState(() {
                          _selectedFormat = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Team Assignment Method
            Card(
              elevation: 4,
              color: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Assignment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Random Team Assignment'),
                      subtitle: Text(_useRandomTeams 
                          ? 'Players will be randomly paired into teams'
                          : 'You will choose your own team partners'),
                      value: _useRandomTeams,
                      onChanged: (value) {
                        setState(() {
                          _useRandomTeams = value;
                          if (!_useRandomTeams && _teamControllers.isEmpty) {
                            // Initialize with 2 teams
                            for (int i = 0; i < 6; i++) {
                              _teamControllers.add(TextEditingController());
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Player/Team Input Section
            if (_useRandomTeams) _buildPlayerInput() else _buildTeamInput(),
            
            const SizedBox(height: 24),
            
            // Create Tournament Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _createTournament,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Create Tournament'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInput() {
    return Card(
      elevation: 4,
      color: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Players (${_playerControllers.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.blue.shade800,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Player'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter player names. Players will be randomly paired into teams (odd numbers create single-player teams).',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...List.generate(_playerControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _playerControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Player ${index + 1}',
                          hintText: 'Enter player name',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter player name';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_playerControllers.length > 2)
                      IconButton(
                        onPressed: () => _removePlayer(index),
                        icon: const Icon(Icons.remove_circle),
                        color: Colors.red,
                      ),
                  ],
                ),
              );
            }),
            if (_playerControllers.length % 2 != 0)
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Odd number of players: Last player will compete as a single-player team',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInput() {
    final teamCount = _teamControllers.length ~/ 3;
    
    return Card(
      elevation: 4,
      color: widget.gameSettings.isDarkTheme ? Colors.grey.shade800 : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Teams ($teamCount)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.gameSettings.isDarkTheme ? Colors.white : Colors.blue.shade800,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addTeam,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Team'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Create your own teams with chosen partners.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...List.generate(teamCount, (teamIndex) {
              final baseIndex = teamIndex * 3;
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Team ${teamIndex + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (teamCount > 2)
                            IconButton(
                              onPressed: () => _removeTeam(teamIndex),
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _teamControllers[baseIndex],
                        decoration: const InputDecoration(
                          labelText: 'Team Name',
                          hintText: 'Enter team name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter team name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _teamControllers[baseIndex + 1],
                        decoration: const InputDecoration(
                          labelText: 'Player 1',
                          hintText: 'Enter player 1 name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter player 1 name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _teamControllers[baseIndex + 2],
                        decoration: const InputDecoration(
                          labelText: 'Player 2',
                          hintText: 'Enter player 2 name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter player 2 name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}