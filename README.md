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

- **Plan: 8/12 Week** - Toggle between 8-week and 12-week plans
- **Level: Beginner/Intermediate/Advanced** - Difficulty level
- **Start from Phase** - Select which phase to start from (Base/Build/Specific/Taper)
- **Reset Progress** - Clear all workout data and start fresh

*Note: Changing level, plan, or start phase resets all progress.*

### Start from Phase Feature

If you missed recording workouts on your watch, you can use the "Start from Phase" setting to:
1. Go to Settings → Start from Phase
2. Select the phase you want to start from (Base/Build/Specific/Taper)
3. All progress will be reset and your training will continue from that phase

This is useful for:
- Catching up after missed training days
- Restarting a specific phase of the program
- Beginning training from a later week

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

---

# Testing Guide

## Testing the App

### Prerequisites
- Garmin Connect IQ SDK installed
- Garmin watch or simulator
- Developer Mode enabled on watch (or use simulator)

### Test Environment
- **Device**: Forerunner 255 / Fenix 7 / Venu 3 (or simulator)
- **SDK Version**: Connect IQ 8.x

---

## Test Cases

### 1. App Installation
**Steps:**
1. Build the app: `monkeyc -y private.der -d fenix7 -o coachrox.prg -f monkey.jungle -w`
2. Install via Garmin Express or `connectiq -d <device-ip> -o coachrox.prg`
3. Verify app appears in your Garmin apps list

**Expected:** App icon visible in menu

---

### 2. Menu Navigation
**Steps:**
1. Open COACHROX app
2. Verify main menu displays:
   - Start Workout
   - My Plan
   - Progress
   - Settings
3. Press UP/DOWN to navigate between options
4. Press ENTER to select
5. Press ESC to go back

**Expected:** All menu items accessible, navigation responsive

---

### 3. Workout Selection
**Steps:**
1. From menu, select "Start Workout"
2. Verify workout list displays (5 workouts per week)
3. Navigate through workouts
4. Select a workout to start

**Expected:** Workout list shows all 5 weekly workouts

---

### 4. Workout Execution
**Steps:**
1. Start any workout
2. Verify exercise name displays
3. Verify countdown timer (5/3/1) shows before each exercise
4. Press DOWN to pause
5. Press DOWN again to resume
6. Complete workout or press ENTER to finish early

**Expected:** 
- Exercise transitions work
- Pause/Resume works
- Workout completes successfully

---

### 5. Settings - Change Level
**Steps:**
1. Go to Settings
2. Select "Level: Beginner" (or current)
3. Press ENTER to cycle to next level
4. Verify level changes

**Expected:** Level cycles through Beginner → Intermediate → Advanced

---

### 6. Settings - Change Plan
**Steps:**
1. Go to Settings
2. Select "Plan: 8 Week" (or 12)
3. Press ENTER to toggle
4. Verify plan changes between 8 and 12 weeks

**Expected:** Plan toggles correctly

---

### 7. Settings - Start from Phase
**Steps:**
1. Go to Settings
2. Navigate to "Start from: Base" (or current)
3. Press ENTER to cycle through phases
4. Select different phase (e.g., Build)
5. Complete the selection

**Expected:**
- Phase cycles through Base → Build → Specific → Taper
- Progress resets after selection

---

### 8. Settings - Reset Progress
**Steps:**
1. Complete some workouts to build progress
2. Go to Settings
3. Select "Reset Progress"
4. Press ENTER to confirm

**Expected:**
- All workout data cleared
- Week counter resets to 0
- Adherence data cleared

---

### 9. Progress Tracking
**Steps:**
1. Complete workouts
2. Go to Progress view
3. Verify completed workouts tracked
4. Check adherence percentages

**Expected:** Progress shows completed workouts and adherence

---

### 10. Weekly Plan View
**Steps:**
1. Go to My Plan
2. Verify current week displays
3. Verify workout schedule for the week
4. Check which workouts are completed vs pending

**Expected:** Weekly plan shows all 5 workouts with completion status

---

## Running Tests on Simulator

### Start Garmin Simulator
```bash
# List available devices
garminconnectiq list

# Start simulator for specific device
garminconnectiq -d fenix7
```

### Deploy to Simulator
```bash
connectiq -d simulator -o coachrox.prg
```

### Debug
```bash
# View device logs
connectiq -d <device> -l
```

---

## Known Test Scenarios

| Scenario | Expected Result |
|----------|-----------------|
| First app launch | Shows main menu, no progress |
| Complete all 5 weekly workouts | Week advances, progress saved |
| Miss a week | Can use "Start from Phase" to catch up |
| Change level mid-program | Progress resets, new level applied |
| Battery dies during workout | Workout not saved (by design) |
| Pause for 1+ hour | Timer continues (GPS-based timing) |

---

## Reporting Issues

If you encounter bugs:
1. Note device model and firmware version
2. Describe steps to reproduce
3. Include any error messages
4. Open issue at: https://github.com/strognoff/coachrox-garmin/issues
