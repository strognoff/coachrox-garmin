# COACHROX - Garmin HYROX Training App

A HYROX-specific training app for Garmin watches with 8-week training plans.

## What is HYROX?

HYROX is a fitness race consisting of 8 stations performed in sequence:
1. **Burpee Broad Jump** - 8 reps (50m)
2. **Rowing** - 1000m
3. **Farmer's Carry** - 200m
4. **Sandbag Lunges** - 100m
5. **Ski Erg** - 1000m
6. **Wall Balls** - 20 reps
7. **Pull-ups** - 10 reps
8. **Run** - 1.6km

## Training Levels

| Level | Description | Reps/Intensity |
|--------|-------------|----------------|
| **Beginner** (level 0) | New to HYROX | Fewer reps, longer rest |
| **Intermediate** (level 1) | Some experience | Medium volume |
| **Advanced** (level 2) | Competition level | More reps, shorter rest |

### How Levels Affect Workouts:

| Exercise | Beginner | Intermediate | Advanced |
|----------|----------|-------------|----------|
| Burpee Broad Jump | 8 reps | 10 reps | 12 reps |
| Sandbag Lunges | 10 reps | 12 reps | 14 reps |
| Pull-ups | 10 reps | 13 reps | 16 reps |
| Wall Balls | 20 reps | 25 reps | 30 reps |
| Run Distance | Base | +10% | +20% |
| Rest Between | Longer | Medium | Shorter |

## Weekly Structure (5 workouts/week)

| Day | Workout | Focus |
|-----|---------|-------|
| 1 | HYROX 1-4 | Burpee Broad Jump, Rowing, Farmer's Carry, Lunges |
| 2 | HYROX 5-8 | Ski Erg, Wall Balls, Pull-ups, Run |
| 3 | Endurance | Long run with functional movements |
| 4 | Upper Body | Pull-ups & Wall Balls focus |
| 5 | Lower Body | Lunges, Farmer's Carry, Rowing |

## Week Progression

- Each week increases intensity by ~10%
- More reps, longer distances
- Gradual build-up over 8 weeks

## How It Works

1. **Select Level** in Settings (Beginner/Intermediate/Advanced)
2. **Start Workout** from the list
3. **Follow Steps** on screen (exercise name, timer, next exercise)
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
