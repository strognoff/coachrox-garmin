# COACHROX - Garmin HYROX Training App

A production-ready HYROX training app for Garmin watches with 12-week structured plans.

## Features

- **12-Week Training Plan** with phased progression
- **3 Difficulty Levels** - Beginner, Intermediate, Advanced
- **5 Workouts Per Week** targeting all HYROX stations
- **Visual Countdown Transitions** - 5/3/1 second countdown between exercises
- **Compliance Tracking** - Step and workout-level completion tracking
- **Adaptation Rules** - Auto-suggestions based on performance

## Training Phases (12 Weeks)

| Phase | Weeks | Focus |
|-------|-------|-------|
| **BASE** | 1-4 | Aerobic capacity, technique |
| **BUILD** | 5-8 | Threshold work, volume |
| **SPECIFIC** | 9-11 | Race simulation |
| **TAPER** | 12 | Reduced volume |

## Adaptation Rules

- **2 consecutive failed workouts** → Downshift suggestion
- **2 consecutive weeks ≥85% adherence** → Progression suggestion
- **Max +12% load jump** → Guardrail enforced

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

## Building

```bash
# Generate a signing key
openssl genrsa -out private.key 4096
openssl rsa -in private.key -traditional -out private.der

# Build
monkeyc -y private.der -p projectInfo.xml -d fenix7x -o coachrox.prg -f monkey.jungle -w
```

## App Type

Application (not watchface) - optimized for workout execution with UI controls.

## Security

- No keys/certs committed to repository
- Offline-first design - no phone dependency during workouts
- Local storage only
