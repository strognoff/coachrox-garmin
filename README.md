# COACHROX - Garmin HYROX Training App

A production-ready HYROX training app for Garmin watches with 12-week structured training plans.

## Features

### Training System
- **12-Week Training Plan** with phased progression
- **3 Difficulty Levels** - Beginner, Intermediate, Advanced
- **5 Workouts Per Week** targeting all HYROX stations
- **Adaptation Rules** - Auto-suggestions based on performance

### Target Model
Each workout step includes:
- **Pace Target** - Target pace in sec/km for running exercises
- **HR Zone Target** - Target heart rate zone (1-5)
- **RPE Target** - Target Rate of Perceived Exertion (1-10)

### Compliance Tracking
- **Step-level compliance** - Track actual vs target duration/reps
- **Workout-level compliance** - Overall completion percentage
- **Weekly analytics** - Adherence tracking over time

### Visual Transitions
- **5/3/1 Countdown** - Visual countdown between exercises
- **Clear transition UI** - Shows "NEXT: [exercise name]"

## Training Phases (12 Weeks)

| Phase | Weeks | Focus | HR Zone | RPE | Pace |
|-------|-------|-------|---------|-----|------|
| **BASE** | 1-4 | Technique, aerobic base | Zone 1-2 | 3-5 | ~6:00/km |
| **BUILD** | 5-8 | Threshold work | Zone 2-3 | 5-7 | ~5:30/km |
| **SPECIFIC** | 9-11 | Race simulation | Zone 3-4 | 7-9 | ~5:00/km |
| **TAPER** | 12 | Reduced volume | Zone 1-2 | 2 | Easy |

## Adaptation Rules

- **2 consecutive failed workouts** → Downshift suggestion (reduce intensity)
- **2 consecutive weeks ≥85% adherence** → Progression suggestion (increase load)
- **Max +12% load jump** → Guardrail enforced (prevent overtraining)

## Supported Devices

### Forerunner
- Forerunner 255
- Forerunner 965

### Fenix/Epix
- Fenix 7
- Fenix 7 Pro
- Fenix 7X
- Epix Pro

### Venu
- Venu 3

## HYROX Stations

The app trains all 8 HYROX stations:
1. Burpee Broad Jump
2. Rowing (1000m)
3. Farmer's Carry (200m)
4. Sandbag Lunges (100m)
5. Ski Erg (1000m)
6. Wall Balls (20 reps)
7. Pull-ups (10 reps)
8. Run (1.6km)

## Menu Navigation

- **UP/DOWN** - Navigate menu items
- **ENTER** - Select/start workout
- **ESC** - Go back

## Workout Controls

- **DOWN** - Pause/Resume workout
- **ENTER** - Finish workout early
- Visual countdown (5/3/1) between exercises

## Settings

- **Level: Beginner** - New to HYROX
- **Level: Intermediate** - Some HYROX experience
- **Level: Advanced** - Competition level
- **Reset Progress** - Clear all data

*Note: Changing level resets your progress.*

## Building

### Prerequisites
1. Install [Garmin Connect IQ SDK 8.x](https://developer.garmin.com/connect-iq/sdk/)
2. Java 17+

### Build Commands

```bash
# Clone repository
git clone https://github.com/strognoff/coachrox-garmin
cd coachrox-garmin

# Generate signing key (one time)
openssl genrsa -out private.key 4096
openssl rsa -in private.key -traditional -out private.der

# Build for specific device
monkeyc -y private.der -d fenix7x -o coachrox.prg -f monkey.jungle -w
```

### Supported Build Targets
- `fenix7`, `fenix7x`, `fenix7pro`
- `forerunner255`, `forerunner965`
- `venu3`

## Installing on Device

### Method 1: Garmin Express
1. Connect your Garmin watch to computer
2. Open Garmin Express
3. Add the `.prg` file to your device

### Method 2: Developer Mode
1. Enable Developer Mode in Garmin Connect app
2. Get the IP address from your watch
3. Deploy using:
   ```
   connectiq -d <device-ip> -o coachrox.prg
   ```

## Project Structure

```
coachrox-garmin/
├── source/
│   ├── CoachroxApp.mc       # Main app
│   ├── CoachroxMenuView.mc # Main menu
│   ├── PlanEngine.mc        # Training plan logic
│   ├── Workout.mc          # Workout model
│   ├── WorkoutSession.mc   # Active workout view
│   ├── WorkoutListView.mc  # Workout selection
│   ├── PlanView.mc         # Weekly plan view
│   ├── ProgressView.mc      # Progress tracking
│   └── SettingsView.mc      # App settings
├── resources/
│   ├── drawables.xml       # App icon
│   └── strings.xml         # Localized strings
├── manifest.xml             # App manifest
├── monkey.jungle           # Build config
└── README.md               # This file
```

## App Type

Application (not watchface) - optimized for workout execution with UI controls.

## Security

- No keys/certs committed to repository
- Offline-first design - no phone dependency during workouts
- Local storage only

## License

MIT License
