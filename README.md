# 🏏 CricPulse Live — Live Cricket Score & Hub

A high-performance, visually stunning mobile application built with **Flutter** for live cricket scores, ball-by-ball commentary, real-time match simulation, detailed scorecards, worm progression charts, tournament standings, ICC player rankings, and fan utility tools.

---

## 🌟 Key Features

### 1. ⚡ Live Match Center & Real-Time Engine
- **Autonomous Live Match Simulator**: Simulates real-time ball-by-ball updates (runs, wickets, boundaries, dots, strike rotation, and commentary).
- **Interactive Controls**: Toggle live auto-play, manual step (`+1 Ball`), and adjust simulation speed (1x, 2x, 4x).
- **Hero Scoreboard**: Featured live match card with live pulsing badge, current run rate (CRR), required run rate (RRR), and dynamic Win Predictor gauge.
- **Recent Balls Strip**: Colored visual tags for deliveries (`[0]`, `[1]`, `[4]` gold, `[6]` purple, `[W]` crimson).
- **Live Striker & Bowler Trackers**: Real-time stats (Runs, Balls, 4s, 6s, Strike Rate, Overs, Maidens, Economy).

### 2. 📊 Comprehensive Match Screen (Multi-Tab)
- **Live Commentary Tab**:
  - Instant ball-by-ball narrative stream with dynamic cricket descriptions.
  - Over summaries with runs conceded per over.
  - Partnership tracker and striker indicator (`*`).
- **Detailed Scorecard Tab**:
  - Complete innings breakdown for both teams.
  - Batting table (Batter, dismissal method, Runs, Balls, 4s, 6s, Strike Rate).
  - Bowling table (Bowler, Overs, Maidens, Runs, Wickets, Economy, Dots).
  - Fall of Wickets (FOW) timeline and list of "Yet to bat" players.
- **Overs & Visual Charts Tab**:
  - **Worm Chart (CustomPainter)**: Over-by-over run progression comparing both teams with glowing active indicators.
  - **Phase Analysis**: Powerplay (1-6 ov), Middle (7-15 ov), and Death overs (16-20 ov) statistical comparison.
- **Match Info & Squads Tab**:
  - Venue, Pitch report, Weather conditions, Toss result, and Playing XIs with Captain `(c)` and Wicketkeeper `(wk)` tags.

### 3. 🏆 Points Table & Standings
- ICC Men's T20 World Cup 2026 (Super 8 Group 1 & Group 2) with semi-final qualification indicators.
- Indian Premier League (IPL 2026) standings.
- Horizontal scrollable table: POS, Team, Played, Won, Lost, Points, NRR, and recent form badges (`W`/`L`).

### 4. 🥇 ICC Player Rankings
- Top Men's & Women's rankings across **T20I**, **ODI**, and **Test** formats.
- Sub-tabs for **Batting** and **Bowling**.
- World No. 1 spotlight card and rating movement indicators (`+1`, `-1`).

### 5. 📰 Cricket News & Editorials
- Curated breaking news, match previews, and tactical analysis.
- Filter chips: World Cup, Analysis, IPL, and All.
- Interactive likes, bookmarks, and sharing options.

### 6. 🎉 Fan Zone & Utility Tools
- **Live Fan Poll**: Community voting on tournament winners with real-time percentage progress bars.
- **DLS (Duckworth-Lewis-Stern) Target Calculator**: Enter Team 1 score, overs, revised overs, and wickets lost to compute revised targets and par scores on the fly.
- **Trivia & Record Watch**: Quick records and cricket milestones.
- **Alerts Preferences**: Toggles for wicket falls, boundaries, and match results.

---

## 🎨 Design System & Aesthetics
- **Dark Sports Theme**: Deep midnight stadium palette (`#0B111E`, `#131D31`, `#1B2A47`) with neon cyan (`#00E5FF`), live emerald (`#00F59B`), boundary gold (`#FFB703`), and wicket crimson (`#FF3366`).
- **Typography**: Google Fonts **Outfit** for sleek, sporty, and readable numbers and headers.
- **Responsive Layout**: Pixel-perfect layout with zero overflows across varied mobile screen sizes.

---

## 🚀 Running the Project

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.13+)
- Dart SDK

### Steps to Run
```bash
# 1. Install dependencies
flutter pub get

# 2. Run code analysis
flutter analyze

# 3. Run widget tests
flutter test

# 4. Launch on connected device / Chrome / macOS desktop
flutter run -d chrome
# or for macOS Desktop:
flutter run -d macos
```

---

## 📁 Directory Structure
```
lib/
├── main.dart                          # App entry point & initialization
├── theme/
│   ├── app_colors.dart                # Design tokens & sports color palette
│   └── app_theme.dart                 # Dark theme & GoogleFonts Outfit typography
├── models/
│   ├── match_model.dart               # CricketMatch & MatchTeam models
│   ├── scorecard_model.dart           # BatterScore, BowlerScore, InningsScorecard
│   ├── commentary_model.dart          # Ball-by-ball commentary item
│   ├── tournament_model.dart          # PointsTableEntry & TournamentGroup
│   ├── news_model.dart                # CricketNews model
│   └── ranking_model.dart             # PlayerRanking model
├── services/
│   └── cricket_data_service.dart      # Live simulation engine, mock data & state manager
├── widgets/
│   ├── live_badge.dart                # Animated pulsing LIVE badge
│   ├── ball_circle.dart               # Colored outcome pill for recent balls
│   ├── hero_match_card.dart           # Prominent featured match card
│   ├── match_card.dart                # Compact match card for list views
│   ├── win_probability_bar.dart       # Split gradient win predictor bar
│   └── worm_chart.dart                # CustomPainter over-by-over worm chart
└── screens/
    ├── main_navigation_screen.dart    # Bottom navigation hosting 5 primary views
    ├── home_matches_screen.dart       # Home live feed & category filters
    ├── match_detail_screen.dart       # Multi-tab match detail center
    ├── standings_screen.dart          # Standings & Points Table
    ├── rankings_screen.dart           # ICC Player Rankings
    ├── news_screen.dart               # Cricket News & Previews
    └── fan_zone_screen.dart           # Fan polls, DLS calculator & trivia
```
