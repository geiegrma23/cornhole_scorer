# cornhole_scorer

# Cornhole Scorer

A comprehensive Flutter mobile application for scoring cornhole games and managing tournaments. Features both quick casual games and full tournament bracket management with customizable rules and settings.

## 🎯 Features

### Quick Game Mode
- **Fast Setup**: Enter team names and start playing immediately
- **Real-time Scoring**: Easy-to-use scoring interface with +1 and +3 point buttons
- **Cancellation Scoring**: Automatic calculation of round scores using standard cornhole rules
- **Round Management**: Track throws remaining and round progression
- **Score Adjustments**: Ability to subtract points for bag interactions

### Tournament Mode
- **Multiple Formats**: Single elimination and double elimination brackets
- **Flexible Team Creation**: 
  - Random team assignment from player list
  - Manual team creation with chosen partners
- **Bracket Visualization**: Visual tournament bracket with match progression
- **Match Management**: Play matches in sequence with automatic advancement
- **Final Rankings**: Complete tournament results with win/loss records and statistics

### Customizable Game Rules
- **Winning Score**: Adjustable target score (15-30 points)
- **Knockback Rule**: Optional rule to reset scores when exceeding target
- **Throws Per Team**: Configurable bags per team (2-6)
- **Max Round Points**: Limit maximum points per round (8-16)
- **Round Confirmation**: Optional confirmation dialog before ending rounds

### User Experience
- **Dark/Light Theme**: Toggle between visual themes
- **Settings Persistence**: All preferences saved locally using SharedPreferences
- **Sound & Vibration**: Configurable feedback options
- **Responsive Design**: Clean, intuitive interface optimized for mobile

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio or VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone [your-repo-url]
   cd cornhole_scorer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point
├── models/
│   ├── game_settings.dart             # Game configuration model
│   └── tournament_models.dart         # Tournament, Team, Match, Player models
├── screens/
│   ├── home_screen.dart              # Main navigation screen
│   ├── quick_game_setup_screen.dart  # Quick game team setup
│   ├── game_play_screen.dart         # Game scoring interface
│   ├── settings_screen.dart          # App settings management
│   ├── tournament_setup_screen.dart  # Tournament creation
│   ├── tournament_bracket_screen.dart # Tournament bracket view
│   ├── tournament_game_screen.dart   # Tournament match gameplay
│   └── tournament_results_screen.dart # Final tournament rankings
└── services/
    ├── settings_service.dart         # Settings persistence
    └── tournament_service.dart       # Tournament logic and bracket generation
```

## 🎮 How to Play

### Quick Game
1. **Setup**: Tap "Quick Game" from home screen
2. **Teams**: Enter names for both teams
3. **Scoring**: Use +1 (board), +3 (hole), or 0 (miss) buttons
4. **Rounds**: Complete all throws, then tap "End Round"
5. **Winner**: First team to reach target score wins

### Tournament
1. **Create**: Tap "Tournament Mode" from home screen
2. **Setup**: Choose format and enter tournament name
3. **Teams**: Either add players for random pairing or create manual teams
4. **Play**: Follow bracket progression, playing each match
5. **Results**: View final rankings and statistics

## ⚙️ Settings & Rules

### Game Rules
- **Knockback Rule**: When enabled, scores above the winning threshold reset to the knockback score
- **Cancellation Scoring**: Only the difference between team scores counts each round
- **Winning Score**: First team to reach this score wins (default: 21)

### Customization Options
- **Appearance**: Light/dark theme toggle
- **Gameplay**: Sound effects, vibration feedback, round confirmations
- **Advanced**: Modify scoring limits and throws per team

## 🏗️ Current Implementation Status

### ✅ Completed Features
- Complete quick game functionality with scoring
- Tournament bracket generation (single & double elimination)
- Settings management with persistence
- Dark/light theme support
- Game rules customization
- Tournament match progression
- Final rankings calculation

### 🔄 In Progress
- Tournament features were the main focus of recent development
- All core tournament functionality is implemented and working

### 🎯 Future Enhancements
- Firebase integration for cloud storage and multiplayer
- Player statistics tracking across games
- Game history and replay functionality
- Advanced tournament seeding options
- Export tournament results
- Sound effects and enhanced animations

## 🛠️ Technical Details

### Dependencies
- **flutter**: Core framework
- **shared_preferences**: ^2.2.2 - Local settings storage
- **cupertino_icons**: ^1.0.2 - iOS-style icons

### Architecture
- **Models**: Data classes for game state and tournament management
- **Services**: Business logic for settings and tournament operations
- **Screens**: UI components following Flutter best practices
- **State Management**: StatefulWidget with setState for reactive UI updates

### Key Features
- **Bracket Generation**: Automatic single/double elimination bracket creation
- **Match Advancement**: Smart tournament progression with winner/loser tracking
- **Settings Persistence**: All user preferences saved locally
- **Responsive UI**: Adapts to different screen sizes and themes

## 📱 Screenshots & Usage

The app provides an intuitive interface for both casual and competitive cornhole play:
- **Home Screen**: Quick access to game modes and settings
- **Game Play**: Large, clear scoring interface with team cards
- **Tournament Bracket**: Visual representation of match progression
- **Settings**: Comprehensive customization options

## 🤝 Contributing

This project is actively developed with a focus on user experience and tournament functionality. The tournament system is feature-complete and ready for extensive testing and usage.

## 📄 License

This project is currently private. License details to be determined.

---

**Ready to play?** Launch the app and start your first cornhole game or tournament!
