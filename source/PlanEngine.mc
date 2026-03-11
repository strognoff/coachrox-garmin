import Toybox.Lang;
import Toybox.Application.Storage;

//! Plan Engine - HYROX-specific training plans
class PlanEngine {
    
    var sessionStorage as SessionStorage;
    
    const PLAN_8_WEEK = 8;
    const PLAN_12_WEEK = 12;
    
    // Week types for 12-week plan
    const PHASE_BASE = 0;      // Weeks 1-4: Foundation (low intensity, technique focus)
    const PHASE_BUILD = 1;     // Weeks 5-8: Building intensity (threshold work, higher volume)
    const PHASE_SPECIFIC = 2;  // Weeks 9-11: Race-specific (race simulation, compromised runs)
    const PHASE_TAPER = 3;     // Week 12: Taper (reduced volume)
    
    // HYROX Levels
    const LEVEL_BEGINNER = 0;    // New to HYROX
    const LEVEL_INTERMEDIATE = 1; // Some HYROX experience
    const LEVEL_ADVANCED = 2;   // Competition level
    
    // Adaptation tracking keys
    const ADAPTATION_SUCCESS = "adapt_success";
    const ADAPTATION_FAIL = "adapt_fail";
    const ADAPTATION_THRESHOLD = 2;
    const ADHERENCE_THRESHOLD = 85; // 85% weekly adherence for progression
    const WEEKS_FOR_PROGRESSION = 2; // 2 consecutive weeks at threshold for progression
    
    // Load jump guardrail
    const MAX_LOAD_JUMP = 12; // Max 12% load increase
    
    // Current week adherence tracking
    var currentWeekWorkouts as Number = 0;
    var currentWeekCompleted as Number = 0;
    
    function initialize(storage as SessionStorage) {
        sessionStorage = storage;
    }
    
    function getPlan(level as Number, week as Number) as Plan {
        var planType = LEVEL_BEGINNER;
        if (level >= LEVEL_ADVANCED) { planType = LEVEL_ADVANCED; }
        else if (level >= LEVEL_INTERMEDIATE) { planType = LEVEL_INTERMEDIATE; }
        
        var completedThisWeek = sessionStorage.getValue("week_" + week + "_completed") != null 
            ? sessionStorage.getValue("week_" + week + "_completed") 
            : 0;
            
        return new Plan(planType, week, completedThisWeek, sessionStorage);
    }
    
    //! Get the current phase for a given week (1-indexed)
    function getPhaseForWeek(week as Number) as Number {
        if (week <= 4) { return PHASE_BASE; }
        else if (week <= 8) { return PHASE_BUILD; }
        else if (week <= 11) { return PHASE_SPECIFIC; }
        else { return PHASE_TAPER; }
    }
    
    //! Get phase name for display
    function getPhaseName(phase as Number) as String {
        if (phase == PHASE_BASE) { return "BASE"; }
        else if (phase == PHASE_BUILD) { return "BUILD"; }
        else if (phase == PHASE_SPECIFIC) { return "SPECIFIC"; }
        else { return "TAPER"; }
    }
    
    //! Get the total weeks in the plan
    function getPlanWeeks() as Number {
        var planType = sessionStorage.getValue("planType");
        if (planType != null && planType == 12) {
            return PLAN_12_WEEK;
        }
        return PLAN_8_WEEK;
    }
    
    //! Generate 5 HYROX-specific workouts per week
    function generateWeeklyWorkouts(week as Number, level as Number, storage as SessionStorage) as Array<Workout> {
        var workouts = new [5] as Array<Workout>;
        var planWeeks = getPlanWeeks();
        
        // Determine phase for this week
        var phase = getPhaseForWeek(week);
        
        // Week progression multiplier (workouts get harder each week, but taper in final week)
        var weekMultiplier = 1.0 + (week * 0.1);
        if (phase == PHASE_TAPER) {
            weekMultiplier = 0.7; // Reduce intensity for taper
        } else if (phase == PHASE_SPECIFIC) {
            weekMultiplier = 1.0 + ((week - 1) * 0.08); // Slower build in specific
        }
        
        // Day 1: HYROX 1-4 (Burpee Broad Jump, Rowing, Farmer's Carry, Lunges)
        workouts[0] = createHYROXDay1(level, week, weekMultiplier, phase, 0, storage);
        
        // Day 2: HYROX 5-8 (Ski Erg, Wall Balls, Pull-ups, Run)
        workouts[1] = createHYROXDay2(level, week, weekMultiplier, phase, 1, storage);
        
        // Day 3: Varies by phase
        workouts[2] = createPhaseSpecificWorkout(level, week, weekMultiplier, phase, 2, storage);
        
        // Day 4: Upper Body + Core (Pull-ups, Wall Balls focus)
        workouts[3] = createUpperBodyWorkout(level, week, weekMultiplier, phase, 3, storage);
        
        // Day 5: Lower Body + Cardio (Lunges, Farmer's Carry, Rowing)
        workouts[4] = createLowerBodyWorkout(level, week, weekMultiplier, phase, 4, storage);
        
        // Set phase on all workouts and add targets
        for (var i = 0; i < workouts.size(); i++) {
            workouts[i].setPhase(week);
            addTargetsToWorkout(workouts[i], phase, week, level);
        }
        
        return workouts;
    }
    
    //! Add target model to all steps in a workout
    function addTargetsToWorkout(workout as Workout, phase as Number, week as Number, level as Number) as Void {
        for (var i = 0; i < workout.getStepCount(); i++) {
            var step = workout.getStep(i);
            if (step != null) {
                setStepTargets(step, step.activityType, phase, week, level);
            }
        }
    }
    
    //! Create phase-specific workout for Day 3
    function createPhaseSpecificWorkout(level as Number, week as Number, mult as Float, phase as Number, dayIndex as Number, storage as SessionStorage) as Workout {
        if (phase == PHASE_BASE) {
            // Base phase: Engine Intervals - focus on cardio base
            return createEngineIntervals(level, week, mult, dayIndex, storage);
        } else if (phase == PHASE_BUILD) {
            // Build phase: Station Strength-Endurance
            return createStationStrengthEndurance(level, week, mult, dayIndex, storage);
        } else if (phase == PHASE_SPECIFIC) {
            // Specific phase: Race-Sim Brick
            return createRaceSimBrick(level, week, mult, dayIndex, storage);
        } else {
            // Taper: Light active recovery
            return createRecoveryWorkout(level, week, mult, dayIndex, storage);
        }
    }
    
    //! Engine Intervals - High intensity cardio intervals (NEW)
    function createEngineIntervals(level as Number, week as Number, mult as Float, dayIndex as Number, storage as SessionStorage) as Workout {
        var steps = new [0] as Array<WorkoutStep>;
        
        // Warm up
        steps.add(new WorkoutStep("Warm Up", "run", 300, 0, 0));
        
        // Engine intervals: 4 x 4 min hard, 3 min easy
        var hardTime = 240 + (week * 10);
        var easyTime = 180;
        var intervals = 4 + level; // Beginner: 4, Int: 5, Adv: 6
        
        for (var i = 0; i < intervals; i++) {
            // Hard interval
            steps.add(new WorkoutStep("Engine " + (i + 1), "rowing", hardTime, 0, 0));
            // Easy recovery
            if (i < intervals - 1) {
                steps.add(new WorkoutStep("Recover", "run", easyTime, 0, 0));
            }
        }
        
        // Cool down
        steps.add(new WorkoutStep("Cool Down", "run", 300, 0, 0));
        
        var duration = (300 + (intervals * (hardTime + easyTime)) + 300) / 60;
        
        return new Workout("Engine Intervals", 5, duration.toNumber(), steps);
    }
    
    //! Station Strength-Endurance - Compound movements (NEW)
    function createStationStrengthEndurance(level as Number, week as Number, mult as Float, dayIndex as Number, storage as SessionStorage) as Workout {
        var steps = new [0] as Array<WorkoutStep>;
        
        steps.add(new WorkoutStep("Warm Up", "run", 300, 0, 0));
        
        // 5 stations, 3 rounds
        var rounds = 3 + level; // Beginner: 3, Int: 4, Adv: 5
        var stationTime = 60 + (week * 5);
        
        for (var r = 0; r < rounds; r++) {
            // Station 1: Burpees
            steps.add(new WorkoutStep("Burpees", "burpee_broad_jump", stationTime, 0, 10 + level * 2));
            
            // Station 2: KB Swings
            steps.add(new WorkoutStep("KB Swings", "kettlebell_swing", stationTime, 0, 15 + level * 3));
            
            // Station 3: Push-ups
            steps.add(new WorkoutStep("Push-ups", "push_up", stationTime, 0, 15 + level * 2));
            
            // Station 4: Box Step-ups
            steps.add(new WorkoutStep("Box Step-up", "box_step_up", stationTime, 0, 12 + level * 2));
            
            // Station 5: Plank Hold
            steps.add(new WorkoutStep("Plank", "plank", stationTime, 0, 0));
        }
        
        steps.add(new WorkoutStep("Cool Down", "run", 300, 0, 0));
        
        var duration = (300 + (rounds * 5 * stationTime) + 300) / 60;
        
        return new Workout("Station S&E", 6, duration.toNumber(), steps);
    }
    
    //! Race-Sim Brick - Run after other stations (NEW)
    function createRaceSimBrick(level as Number, week as Number, mult as Float, dayIndex as Number, storage as SessionStorage) as Workout {
        var steps = new [0] as Array<WorkoutStep>;
        
        steps.add(new WorkoutStep("Warm Up", "run", 300, 0, 0));
        
        // Simulate HYROX race: stations then run
        // Station 1-2: Burpee Broad + Rowing
        steps.add(new WorkoutStep("BBJ + Row", "burpee_broad_jump", 180, 0, 8));
        steps.add(new WorkoutStep("Rowing", "rowing", 180, 0, 0));
        
        // Station 3-4: Farmer's Carry + Lunges
        steps.add(new WorkoutStep("Farmer Carry", "farmers_carry", 60, 0, 0));
        steps.add(new WorkoutStep("Lunges", "sandbag_lunge", 90, 0, 10));
        
        // Station 5-6: Ski + Wall Balls
        steps.add(new WorkoutStep("Ski Erg", "ski_erg", 180, 0, 0));
        steps.add(new WorkoutStep("Wall Balls", "wall_ball", 120, 0, 15));
        
        // Station 7: Pull-ups
        steps.add(new WorkoutStep("Pull-ups", "pull_up", 90, 0, 8));
        
        // Final Run (800m - half race distance)
        var runTime = 240 + (week * 10) - (level * 20);
        steps.add(new WorkoutStep("Final Run", "run", runTime, 800, 0));
        
        steps.add(new WorkoutStep("Cool Down", "run", 300, 0, 0));
        
        var duration = (300 + 180 + 180 + 60 + 90 + 180 + 120 + 90 + runTime + 300) / 60;
        
        return new Workout("Race-Sim Brick", 7, duration.toNumber(), steps);
    }
    
    //! Recovery workout for taper week
    function createRecoveryWorkout(level as Number, week as Number, mult as Float, dayIndex as Number, storage as SessionStorage) as Workout {
        var steps = new [0] as Array<WorkoutStep>;
        
        steps.add(new WorkoutStep("Easy Warm Up", "run", 300, 0, 0));
        
        // Light movements
        steps.add(new WorkoutStep("Light Row", "rowing", 300, 0, 0));
        steps.add(new WorkoutStep("Dynamic Stretch", "stretch", 300, 0, 0));
        
        steps.add(new WorkoutStep("Easy Cool Down", "run", 300, 0, 0));
        
        var duration = (300 + 300 + 300 + 300) / 60;
        
        return new Workout("Recovery", 8, duration.toNumber(), steps);
    }
    
    //! HYROX Stations 1-4: Burpee Broad Jump, Rowing, Farmer's Carry, Lunges
    function createHYROXDay1(level as Number, week as Number, mult as Float, phase as Number, dayIndex as Number, storage as SessionStorage) as Workout {
        var steps = new [0] as Array<WorkoutStep>;
        
        // Warm up - 5 min
        steps.add(new WorkoutStep("Warm Up", "run", 300, 0, 0));
        
        // Station 1: Burpee Broad Jumps (8 reps for HYROX)
        var bbjReps = 8 + (level * 2); // Beginner: 8, Int: 10, Adv: 12
        steps.add(new WorkoutStep("Burpee Broad", "burpee_broad_jump", bbjReps * 10, 0, bbjReps));
        
        // Station 2: Rowing (1000m = ~4 min)
        var rowTime = 240 + (week * 15);
        steps.add(new WorkoutStep("Rowing", "rowing", rowTime, 0, 0));
        
        // Station 3: Farmer's Carry (200m = 4 lengths with heavy weights)
        var carryTime = 45 + (level * 5);
        steps.add(new WorkoutStep("Farmer Carry", "farmers_carry", carryTime, 0, 0));
        
        // Station 4: Sandbag Lunges (100m = 10 lunges)
        var lungeReps = 10 + (level * 2);
        steps.add(new WorkoutStep("Sandbag Lunges", "sandbag_lunge", lungeReps * 8, 0, lungeReps));
        
        // Cool down
        steps.add(new WorkoutStep("Cool Down", "run", 180, 0, 0));
        
        var duration = (300 + 180 + bbjReps*10 + rowTime + carryTime + lungeReps*8 + 180) / 60;
        
        return new Workout("HYROX 1-4", 0, duration.toNumber(), steps);
    }
    
    //! HYROX Stations 5-8: Ski Erg, Wall Balls, Pull-ups, Running
    function createHYROXDay2(level as Number, week as Number, mult as Float, phase as Number, dayIndex as Number, storage as SessionStorage) as Workout {
        var steps = new [0] as Array<WorkoutStep>;
        
        // Warm up
        steps.add(new WorkoutStep("Warm Up", "run", 300, 0, 0));
        
        // Station 5: Ski Erg (1000m)
        var skiTime = 210 + (week * 12);
        steps.add(new WorkoutStep("Ski Erg", "ski_erg", skiTime, 0, 0));
        
        // Station 6: Wall Balls (20 reps for HYROX)
        var wbReps = 20 + (level * 5);
        steps.add(new WorkoutStep("Wall Balls", "wall_ball", wbReps * 8, 0, wbReps));
        
        // Station 7: Pull-ups (10 reps for HYROX)
        var pullReps = 10 + (level * 3);
        steps.add(new WorkoutStep("Pull-ups", "pull_up", pullReps * 6, 0, pullReps));
        
        // Station 8: Run (1.6km = 1600m)
        var runTime = 420 + (week * 20) - (level * 30); // Faster for advanced
        steps.add(new WorkoutStep("Run 1.6km", "run", runTime, 1600, 0));
        
        // Cool down
        steps.add(new WorkoutStep("Cool Down", "run", 180, 0, 0));
        
        var duration = (300 + skiTime + wbReps*8 + pullReps*6 + runTime + 180 + 180) / 60;
        
        return new Workout("HYROX 5-8", 1, duration.toNumber(), steps);
    }
    
    //! Endurance: Long functional run
    function createEnduranceWorkout(level as Number, week as Number, mult as Float, phase as Number, dayIndex as Number, storage as SessionStorage) as Workout {
        var steps = new [0] as Array<WorkoutStep>;
        
        steps.add(new WorkoutStep("Warm Up", "run", 300, 0, 0));
        
        // Progressive run with burpees
        var runTime = (20 + week * 2) * 60; // 20-36 min
        var runDist = 3000 + (week * 200);
        steps.add(new WorkoutStep("Endurance Run", "run", runTime, runDist, 0));
        
        // Add burpees every 5 min
        var burpCount = 10 + level * 5;
        steps.add(new WorkoutStep("Burpees x" + burpCount, "burpee_broad_jump", 60, 0, burpCount));
        
        steps.add(new WorkoutStep("Cool Down", "run", 300, 0, 0));
        
        var duration = (300 + runTime + 60 + 300) / 60;
        
        return new Workout("Endurance", 2, duration.toNumber(), steps);
    }
    
    //! Upper body: Pull-ups and Wall Balls focus
    function createUpperBodyWorkout(level as Number, week as Number, mult as Float, phase as Number, dayIndex as Number, storage as SessionStorage) as Workout {
        var steps = new [0] as Array<WorkoutStep>;
        
        steps.add(new WorkoutStep("Warm Up", "run", 180, 0, 0));
        
        // Pull-up ladder
        var pullSets = 4 + level;
        for (var i = 0; i < pullSets; i++) {
            var reps = 5 + (i * 2) + level;
            steps.add(new WorkoutStep("Pull-ups", "pull_up", reps * 5, 0, reps));
        }
        
        // Wall balls
        var wbSets = 4;
        for (var i = 0; i < wbSets; i++) {
            var reps = 15 + (level * 3) + i;
            steps.add(new WorkoutStep("Wall Balls", "wall_ball", reps * 6, 0, reps));
        }
        
        steps.add(new WorkoutStep("Cool Down", "run", 180, 0, 0));
        
        var duration = (180 + pullSets*20 + wbSets*30 + 180) / 60;
        
        return new Workout("Upper Body", 3, duration.toNumber(), steps);
    }
    
    //! Lower body: Lunges, Farmer's Carry, Rowing
    function createLowerBodyWorkout(level as Number, week as Number, mult as Float, phase as Number, dayIndex as Number, storage as SessionStorage) as Workout {
        var steps = new [0] as Array<WorkoutStep>;
        
        steps.add(new WorkoutStep("Warm Up", "run", 180, 0, 0));
        
        // Lunges
        var lungeReps = 50 + (week * 5) + (level * 10);
        steps.add(new WorkoutStep("Goblet Lunges", "sandbag_lunge", lungeReps * 5, 0, lungeReps));
        
        // Farmer's Carry
        var carryTime = 60 + (week * 5);
        steps.add(new WorkoutStep("Farmer Carry", "farmers_carry", carryTime, 0, 0));
        
        // Rowing
        var rowTime = 300 + (week * 20);
        steps.add(new WorkoutStep("Rowing", "rowing", rowTime, 0, 0));
        
        steps.add(new WorkoutStep("Cool Down", "run", 180, 0, 0));
        
        var duration = (180 + lungeReps*5 + carryTime + rowTime + 180) / 60;
        
        return new Workout("Lower Body", 4, duration.toNumber(), steps);
    }
    
    //! Adaptation: Called when workout is completed
    function recordWorkoutResult(success as Boolean) as Void {
        var currentLevel = sessionStorage.getValue("userLevel") != null 
            ? sessionStorage.getValue("userLevel") 
            : 0;
        
        if (success) {
            // Increment success counter
            var successes = sessionStorage.getValue(ADAPTATION_SUCCESS) != null 
                ? sessionStorage.getValue(ADAPTATION_SUCCESS) 
                : 0;
            successes = successes + 1;
            sessionStorage.setValue(ADAPTATION_SUCCESS, successes);
            
            // Reset fail counter
            sessionStorage.setValue(ADAPTATION_FAIL, 0);
            
            // Check if should progress (2 successful = progress)
            if (successes >= ADAPTATION_THRESHOLD && currentLevel < LEVEL_ADVANCED) {
                var newLevel = currentLevel + 1;
                sessionStorage.setValue("userLevel", newLevel);
                sessionStorage.setValue(ADAPTATION_SUCCESS, 0); // Reset counter
            }
        } else {
            // Increment fail counter
            var fails = sessionStorage.getValue(ADAPTATION_FAIL) != null 
                ? sessionStorage.getValue(ADAPTATION_FAIL) 
                : 0;
            fails = fails + 1;
            sessionStorage.setValue(ADAPTATION_FAIL, fails);
            
            // Reset success counter
            sessionStorage.setValue(ADAPTATION_SUCCESS, 0);
            
            // Check if should downshift (2 failed = downshift)
            if (fails >= ADAPTATION_THRESHOLD && currentLevel > LEVEL_BEGINNER) {
                var newLevel = currentLevel - 1;
                sessionStorage.setValue("userLevel", newLevel);
                sessionStorage.setValue(ADAPTATION_FAIL, 0); // Reset counter
            }
        }
    }
    
    //! Get adaptation status for display
    function getAdaptationStatus() as String {
        var successes = sessionStorage.getValue(ADAPTATION_SUCCESS) != null 
            ? sessionStorage.getValue(ADAPTATION_SUCCESS) 
            : 0;
        var fails = sessionStorage.getValue(ADAPTATION_FAIL) != null 
            ? sessionStorage.getValue(ADAPTATION_FAIL) 
            : 0;
            
        if (successes >= ADAPTATION_THRESHOLD) {
            return "READY TO LEVEL UP!";
        } else if (fails >= ADAPTATION_THRESHOLD) {
            return "CONSIDER DOWNGRADING";
        }
        
        return "Progress: " + successes + "/" + ADAPTATION_THRESHOLD + " OK, " + fails + "/" + ADAPTATION_THRESHOLD + " FAIL";
    }
    
    //! Enhanced adaptation logic with weekly adherence tracking
    function recordWeeklyAdherence(week as Number, adherencePercent as Number) as Void {
        // Store weekly adherence
        sessionStorage.setValue("week_" + week + "_adherence", adherencePercent);
        
        // Check for 2 consecutive weeks ≥85% adherence → progression suggestion
        var prevWeekAdherenceVal = sessionStorage.getValue("week_" + (week - 1) + "_adherence");
        var prevWeekAdherence = prevWeekAdherenceVal != null ? prevWeekAdherenceVal as Number : 0;
        
        var currentLevel = sessionStorage.getValue("userLevel") != null 
            ? sessionStorage.getValue("userLevel") as Number
            : 0;
        
        if (adherencePercent >= ADHERENCE_THRESHOLD && 
            prevWeekAdherenceVal != null && 
            prevWeekAdherence >= ADHERENCE_THRESHOLD &&
            currentLevel < LEVEL_ADVANCED) {
            // 2 consecutive weeks at threshold - suggest progression
            sessionStorage.setValue("progression_suggested", 1);
            sessionStorage.setValue("progression_reason", "2 weeks >= 85% adherence");
        }
    }
    
    //! Apply max load jump guardrail (max 12% increase)
    function applyLoadGuardrail(currentLoad as Float, proposedLoad as Float) as Float {
        var maxLoad = currentLoad * (1.0 + (MAX_LOAD_JUMP / 100.0));
        if (proposedLoad > maxLoad) {
            return maxLoad;
        }
        return proposedLoad;
    }
    
    //! Calculate load for a given week based on phase and progression
    function calculateWeekLoad(week as Number, baseLoad as Number) as Number {
        var phase = getPhaseForWeek(week);
        var load = baseLoad;
        
        // Apply phase-specific multipliers
        if (phase == PHASE_BASE) {
            // BASE: Low intensity, focus on technique (weeks 1-4)
            load = baseLoad * 0.7; 
        } else if (phase == PHASE_BUILD) {
            // BUILD: Threshold work, higher volume (weeks 5-8)
            load = baseLoad * (0.8 + ((week - 4) * 0.05)); // Progressive increase
        } else if (phase == PHASE_SPECIFIC) {
            // SPECIFIC: Race simulation, compromised runs (weeks 9-11)
            load = baseLoad * (1.0 + ((week - 8) * 0.05)); // Peak load
        } else {
            // TAPER: Reduced volume (week 12)
            load = baseLoad * 0.6;
        }
        
        // Apply load guardrail
        var prevWeekLoadVal = sessionStorage.getValue("prev_week_load");
        if (prevWeekLoadVal != null) {
            var prevWeekLoad = prevWeekLoadVal as Float;
            load = applyLoadGuardrail(prevWeekLoad, load);
        }
        
        sessionStorage.setValue("prev_week_load", load);
        return load.toNumber();
    }
    
    //! Set targets on a workout step based on phase and activity type
    function setStepTargets(step as WorkoutStep, activityType as String, phase as Number, week as Number, level as Number) as Void {
        // Set HR zone based on phase
        if (phase == PHASE_BASE) {
            // BASE: Zone 1-2 (Recovery, Aerobic)
            step.setTargetHRZone(2);
            step.setTargetRPE(3 + (week * 0.5).toNumber()); // RPE 3-5
            step.setTargetPace(360 + (week * 10)); // Easy pace ~6:00/km
        } else if (phase == PHASE_BUILD) {
            // BUILD: Zone 2-3 (Tempo/Threshold)
            step.setTargetHRZone(3);
            step.setTargetRPE(5 + (week * 0.5).toNumber()); // RPE 5-7
            step.setTargetPace(330 + (week * 8)); // ~5:30/km
        } else if (phase == PHASE_SPECIFIC) {
            // SPECIFIC: Zone 3-4 (Race pace)
            step.setTargetHRZone(4);
            step.setTargetRPE(7 + (week * 0.5).toNumber()); // RPE 7-9
            step.setTargetPace(300 + (week * 5)); // ~5:00/km
        } else {
            // TAPER: Zone 1-2 (Recovery)
            step.setTargetHRZone(1);
            step.setTargetRPE(2); // Very easy
            step.setTargetPace(380); // Very easy pace
        }
        
        // Adjust for activity type
        if (activityType.equals("run")) {
            // Running pace targets already set above
        } else if (activityType.equals("rowing") || activityType.equals("ski_erg")) {
            // Cardio equipment - use pace equivalent
            step.setTargetPace(step.targetPaceSecPerKm / 2); // Convert to effort
        } else if (activityType.equals("burpee_broad_jump") || 
                   activityType.equals("wall_ball") || 
                   activityType.equals("pull_up") ||
                   activityType.equals("kettlebell_swing")) {
            // Rep-based exercises - RPE is primary target
            step.setTargetPace(0); // Not applicable
        }
    }
    
    //! Get phase description for display
    function getPhaseDescription(phase as Number) as String {
        if (phase == PHASE_BASE) {
            return "Base: Low intensity, technique focus";
        } else if (phase == PHASE_BUILD) {
            return "Build: Threshold work, higher volume";
        } else if (phase == PHASE_SPECIFIC) {
            return "Specific: Race simulation, race pace";
        } else {
            return "Taper: Reduced volume, freshen up";
        }
    }
}

//! Training Plan
class Plan {
    var level as Number;
    var currentWeek as Number;
    var completedSessions as Number;
    var workouts as Array<Workout> = [];
    
    function initialize(lvl as Number, week as Number, completed as Number, storage as SessionStorage) {
        level = lvl;
        currentWeek = week;
        completedSessions = completed;
        
        var engine = Application.getApp().planEngine;
        if (engine != null) {
            workouts = engine.generateWeeklyWorkouts(week, lvl, storage);
        }
    }
    
    function getWorkout(index as Number) as Workout? {
        if (index >= 0 && index < workouts.size()) {
            return workouts[index];
        }
        return null;
    }
    
    function getWeekNumber() as Number {
        return currentWeek + 1;
    }
    
    function getCompletionRate() as Number {
        return (completedSessions * 100) / 5;
    }
}
