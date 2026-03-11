# COACHROX - Garmin HYROX Training App

A HYROX-specific training app for Garmin watches with 8-week training plans.

## What is HYROX?

HYROX is a fitness race consisting of 8 stations performed in sequence:
1. **Burpee Broad Jump** - 8 reps (50m)
2. **Rowing** - 1000m
3. **Farmer's Carry** - 200m (2x16kg men / 2x10kg women)
4. **Sandbag Lunges** - 100m (10kg men / 6kg women)
5. **Ski Erg** - 1000m
6. **Wall Balls** - 20 reps (9kg men / 6kg women)
7. **Pull-ups** - 10 reps
8. **Run** - 1.6km

Each race = 8 stations + 1 run = 9 total. The entire course is then repeated.

## App Structure

### Training Levels

- **Beginner** - New to HYROX, lower volume
- **Intermediate** - Some HYROX experience
- **Advanced** - Competition-level training

### Weekly Structure (5 workouts/week)

Each week has 5 workouts designed to target all HYROX stations:

| Day | Workout | Focus |
|-----|---------|-------|
| 1 | HYROX 1-4 | Stations 1-4 (Burpee Broad Jump, Rowing, Farmer's Carry, Lunges) |
| 2 | HYROX 5-8 | Stations 5-8 (Ski Erg, Wall Balls, Pull-ups, Run) |
| 3 | Endurance | Long run with functional movements |
| 4 | Upper Body | Pull-ups & Wall Balls focus |
| 5 | Lower Body | Lunges, Farmer's Carry, Rowing |

### Week Progression

- Each week increases workout intensity by ~10%
- More reps, longer distances, shorter rest times
- Gradual progression to prepare for HYROX race

## How It Works

1. **Select Level** in Settings (Beginner/Intermediate/Advanced)
2. **Start Workout** from the list
3. **Follow Steps** displayed on screen (current exercise, timer, next exercise)
4. **Complete All 5 Workouts** in a week to advance
5. **Progress Through 8 Weeks** to build HYROX fitness

### Controls

- **UP/DOWN** - Navigate menu
- **ENTER** - Select/start
- **ESC** - Go back
- **DOWN** - Pause workout
- **ENTER** - Finish workout

## Settings

- **Level: Beginner** - Start fresh, easier workouts
- **Level: Intermediate** - Moderate difficulty
- **Level: Advanced** - Competition-level training
- **Reset Progress** - Clear all data

*Note: Changing level resets your progress.*

## Building

```bash
# Install Garmin Connect IQ SDK 8.x
# Build:
monkeyc -y private.key -p projectInfo.xml -d fenix8solar51mm -o coachrox.prg -f monkey.jungle -w
```

## Compatible Devices

- Fenix 7/8 series
- Forerunner 955/965
- Other Connect IQ 3.0+ devices
