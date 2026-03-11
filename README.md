# COACHROX - Garmin Training App

A Garmin Connect IQ app for athletes training for fitness racing events such as HYROX.

## Features

### Plan Engine
- 8-week and 12-week training templates
- Three levels: Beginner, Intermediate, Advanced
- 3-5 sessions per week
- Session types: intervals, combo blocks, threshold/tempo, recovery

### Workout Execution
- Step-based workout model supporting:
  - Running
  - Rest periods
  - Burpee broad jumps
  - Lunges
  - Farmer carry
  - Wall balls simulation
- Duration and rep-based targets
- Vibration cues on transitions
- Controls: start, pause, resume, skip step

### Tracking
- Session completion tracking
- Weekly volume tracking
- Target compliance monitoring

### Adaptation Rules
- Automatic suggestions based on performance:
  - 2 failed weeks → suggest downshift
  - 2 successful weeks (>85%) → suggest progression

## Supported Devices

- Forerunner series
- Fenix/Epix series
- Venu series (where supported)

## Installation

### Prerequisites
- Garmin Connect IQ SDK
- Monkey C development environment

### Build
```bash
# Using Connect IQ SDK
ciq build
```

### Install on Simulator
```bash
# Start Garmin Express or Connect IQ Simulator
# Deploy the .prg file
```

### Install on Device
1. Copy the .prg file to your Garmin device via Garmin Connect
2. Or use Garmin Express to sync the app

## Development

### Project Structure
```
coachrox-garmin/
├── source/              # Monkey C source code
│   ├── CoachroxApp.mc   # Main application
│   ├── PlanEngine.mc    # Training plan logic
│   ├── Workout.mc      # Workout/step definitions
│   ├── WorkoutSession.mc # Active session runtime
│   ├── SessionStorage.mc # Data persistence
│   └── *.mc             # UI views and delegates
├── resources/           # App resources
│   └── strings.xml      # Localized strings
├── manifest.xml         # App manifest
└── README.md
```

### Architecture
- **Plan Engine**: Generates and manages training plans
- **Workout Runtime**: Executes workout sessions
- **Storage Adapter**: Handles local persistence
- **UI Layer**: Watch UI views and delegates

## Version

v0.1.0-MVP - Initial release

## License

Private - All rights reserved
