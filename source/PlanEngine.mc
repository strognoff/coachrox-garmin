import Toybox.Lang;
import Toybox.Application.Storage;

//! Plan Engine - HYROX-specific training plans
class PlanEngine {
    
    var sessionStorage as SessionStorage;
    
    const PLAN_8_WEEK = 8;
    
    // HYROX Levels
    const LEVEL_BEGINNER = 0;    // New to HYROX
    const LEVEL_INTERMEDIATE = 1; // Some HYROX experience
    const LEVEL_ADVANCED = 2;   // Competition level
    
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
    
    //! Generate 5 HYROX-specific workouts per week
    function generateWeeklyWorkouts(week as Number, level as Number, storage as SessionStorage) as Array<Workout> {
        var workouts = new [5] as Array<Workout>;
        
        // Week progression multiplier (workouts get harder each week)
        var weekMultiplier = 1.0 + (week * 0.1); // 1.0, 1.1, 1.2, etc.
        
        // Day 1: HYROX 1-4 (Burpee Broad Jump, Rowing, Farmer's Carry, Lunges)
        workouts[0] = createHYROXDay1(level, week, weekMultiplier, 0, storage);
        
        // Day 2: HYROX 5-8 (Ski Erg, Wall Balls, Pull-ups, Run)
        workouts[1] = createHYROXDay2(level, week, weekMultiplier, 1, storage);
        
        // Day 3: Endurance (Long run + functional)
        workouts[2] = createEnduranceWorkout(level, week, weekMultiplier, 2, storage);
        
        // Day 4: Upper Body + Core (Pull-ups, Wall Balls focus)
        workouts[3] = createUpperBodyWorkout(level, week, weekMultiplier, 3, storage);
        
        // Day 5: Lower Body + Cardio (Lunges, Farmer's Carry, Rowing)
        workouts[4] = createLowerBodyWorkout(level, week, weekMultiplier, 4, storage);
        
        return workouts;
    }
    
    //! HYROX Stations 1-4: Burpee Broad Jump, Rowing, Farmer's Carry, Lunges
    function createHYROXDay1(level as Number, week as Number, mult as Float, dayIndex as Number, storage as SessionStorage) as Workout {
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
    function createHYROXDay2(level as Number, week as Number, mult as Float, dayIndex as Number, storage as SessionStorage) as Workout {
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
    function createEnduranceWorkout(level as Number, week as Number, mult as Float, dayIndex as Number, storage as SessionStorage) as Workout {
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
    function createUpperBodyWorkout(level as Number, week as Number, mult as Float, dayIndex as Number, storage as SessionStorage) as Workout {
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
    function createLowerBodyWorkout(level as Number, week as Number, mult as Float, dayIndex as Number, storage as SessionStorage) as Workout {
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
