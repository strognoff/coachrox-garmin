# COACHROX - Garmin HYROX Training App

A HYROX-specific training app for Garmin watches with 12-week training plans.

## What is HYROX?

HYROX is a fitness race consisting of 8 stations performed in sequence with running between each.

## Training Plan (12 Weeks)

### Phases

| Phase | Weeks | Focus |
|-------|-------|-------|
| **BASE** | 1-4 | Aerobic capacity, movement quality, station technique |
| **BUILD** | 5-8 | Threshold work, heavier station volume, compromised runs |
| **SPECIFIC** | 9-11 | Race simulation focus |
| **TAPER** | 12 | Reduced volume for race day |

### Training Levels

- **Beginner** - New to HYROX
- **Intermediate** - Some HYROX experience  
- **Advanced** - Competition level

## Workout Types

1. **Engine Intervals** - Run/erg threshold intervals
2. **Station Strength-Endurance** - HYROX station focused
3. **Race-Sim Brick** - Run + stations combination
4. **Recovery** - Light movement

## Controls

- **UP/DOWN** - Navigate
- **ENTER** - Select/Start
- **ESC** - Back
- **DOWN** - Pause
- **ENTER** - Finish workout

## Building

```bash
monkeyc -y private.key -p projectInfo.xml -d fenix8solar51mm -o coachrox.prg -f monkey.jungle -w
```

## Supported Devices

### Fenix/Epix
- Fenix 7, 7 Pro, 7X
- Fenix 8, 8 Solar
- Epix Pro

### Forerunner
- Forerunner 255, 965, 985

### Venu
- Venu 2, Venu 3
