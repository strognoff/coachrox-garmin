# COACHROX - Garmin Training App

A workout training app for Garmin watches with 8-week training plans.

## Features

- **8-Week Training Plans** - Structured workouts progressing in difficulty
- **3 Difficulty Levels** - Beginner, Intermediate, Advanced
- **5 Workouts Per Week** - Intervals, Combo, Threshold, Recovery, Finale
- **Progress Tracking** - See completion rate and weekly progress
- **Persistent Storage** - Workouts and progress saved on device

## How It Works

### Training Levels

1. **Beginner** - 4 rounds intervals, easier workouts
2. **Intermediate** - 5 rounds intervals, medium difficulty
3. **Advanced** - 6 rounds intervals, harder workouts

### Weekly Structure

Each week has 5 workouts:
- **Intervals** - High intensity intervals (running + rest)
- **Combo** - Mixed exercises (running + burpees + lunges)
- **Recovery** - Easy pace workout
- **Threshold** - Tempo/continuous running
- **Finale** - Long combo workout

### Week Progression

- Each week increases workout duration slightly
- Progress is tracked per workout
- After completing all 5 workouts in a week → advance to next week

### Menu Navigation

- **UP/DOWN** - Navigate menu items
- **ENTER** - Select/start workout
- **ESC** - Go back

### Workout Controls

- **DOWN** - Pause/Resume
- **ENTER** - Finish workout early

## Settings

- **Level Selection** - Changes difficulty (resets progress)
- **Reset Progress** - Clears all data and starts fresh

## Building

The app is built for Garmin Connect IQ SDK 8.x.

```bash
# Install SDK from Garmin Developer Portal
# Build:
monkeyc -y private.key -p projectInfo.xml -d fenix8solar51mm -o coachrox.prg -f monkey.jungle -w
```

## Compatible Devices

- Fenix 7 series
- Fenix 8 series (tested on fenix8solar51mm)
- Forerunner 955/965
- And other Connect IQ 3.0+ devices
