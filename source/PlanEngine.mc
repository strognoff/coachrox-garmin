import Toybox.Lang;
import Toybox.Application.Storage;

//! Plan Engine - manages training plans
class PlanEngine {
    
    var sessionStorage as SessionStorage;
    
    //! Available plan templates
    const PLAN_8_WEEK = 8;
    const PLAN_12_WEEK = 12;
    
    //! Training levels
    const LEVEL_BEGINNER = 0;
    const LEVEL_INTERMEDIATE = 1;
    const LEVEL_ADVANCED = 2;
    
    //! Session types
    const SESSION_INTERVALS = 0;
    const SESSION_COMBO = 1;
    const SESSION_THRESHOLD = 2;
    const SESSION_RECOVERY = 3;
    
    function initialize(storage as SessionStorage) {
        sessionStorage = storage;
    }
    
    //! Get a training plan based on level and week
    function getPlan(level as Number, week as Number) as Plan {
        var planLength = PLAN_8_WEEK;
        var planType = LEVEL_BEGINNER;
        
        if (level >= LEVEL_INTERMEDIATE) {
            planType = LEVEL_INTERMEDIATE;
        }
        if (level >= LEVEL_ADVANCED) {
            planType = LEVEL_ADVANCED;
        }
        
        // Get completed sessions this week
        var completedThisWeek = sessionStorage.getValue("week_" + week + "_completed") != null 
            ? sessionStorage.getValue("week_" + week + "_completed") 
            : 0;
            
        return new Plan(planType, week, completedThisWeek);
    }
    
    //! Get suggested adaptation based on performance
    function getAdaptationSuggestion() as Number {
        // Check last 2 weeks performance
        var lastWeekCompleted = sessionStorage.getValue("week_completed") != null 
            ? sessionStorage.getValue("week_completed") 
            : 0;
        var weekBeforeCompleted = sessionStorage.getValue("week_-1_completed") != null 
            ? sessionStorage.getValue("week_-1_completed") 
            : 0;
            
        // 2 failed weeks in a row -> suggest downshift
        if (lastWeekCompleted < 3 && weekBeforeCompleted < 3) {
            return -1; // Downshift
        }
        
        // 2 successful weeks (>85% adherence) -> suggest progression
        if (lastWeekCompleted >= 4 && weekBeforeCompleted >= 4) {
            return 1; // Progress
        }
        
        return 0; // Maintain
    }
    
    //! Generate workout for the week
    function generateWeeklyWorkouts(week as Number, level as Number) as Array<Workout> {
        var workouts = new [5] as Array<Workout>;
        
        // Day 1: Intervals
        workouts[0] = createWorkout("Intervals " + (week + 1), SESSION_INTERVALS, level, 30 + week * 2);
        
        // Day 2: Combo blocks
        workouts[1] = createWorkout("Combo " + (week + 1), SESSION_COMBO, level, 35 + week * 2);
        
        // Day 3: Recovery
        workouts[2] = createWorkout("Recovery " + (week + 1), SESSION_RECOVERY, level, 20);
        
        // Day 4: Threshold
        workouts[3] = createWorkout("Threshold " + (week + 1), SESSION_THRESHOLD, level, 40 + week * 3);
        
        // Day 5: Combo
        workouts[4] = createWorkout("Finale " + (week + 1), SESSION_COMBO, level, 45 + week * 2);
        
        return workouts;
    }
    
    function createWorkout(name as String, type as Number, level as Number, durationMin as Number) as Workout {
        var steps = new [0] as Array<WorkoutStep>;
        
        // Warm up
        steps.add(new WorkoutStep("Warm Up", "run", 300, 0, 0)); // 5 min
        
        // Main workout based on type
        if (type == SESSION_INTERVALS) {
            var rounds = 4 + level;
            for (var i = 0; i < rounds; i++) {
                steps.add(new WorkoutStep("Work " + (i + 1), "run", 120, 0, 0)); // 2 min
                steps.add(new WorkoutStep("Rest " + (i + 1), "rest", 60, 0, 0)); // 1 min
            }
        } else if (type == SESSION_COMBO) {
            steps.add(new WorkoutStep("Run Block", "run", 600, 0, 0)); // 10 min
            steps.add(new WorkoutStep("Burpees", "burpee broad jump", 180, 0, 15)); // 3 min, 15 reps
            steps.add(new WorkoutStep("Run Block", "run", 600, 0, 0)); // 10 min
            steps.add(new WorkoutStep("Lunges", "lunges", 180, 0, 20)); // 3 min
        } else if (type == SESSION_THRESHOLD) {
            steps.add(new WorkoutStep("Tempo", "run", 1800, 0, 0)); // 30 min
        } else if (type == SESSION_RECOVERY) {
            steps.add(new WorkoutStep("Easy Run", "run", 900, 0, 0)); // 15 min
            steps.add(new WorkoutStep("Walk", "rest", 300, 0, 0)); // 5 min
        }
        
        // Cool down
        steps.add(new WorkoutStep("Cool Down", "run", 300, 0, 0)); // 5 min
        
        return new Workout(name, type, durationMin, steps);
    }
}

//! Training Plan
class Plan {
    var level as Number;
    var currentWeek as Number;
    var completedSessions as Number;
    var workouts as Array<Workout> = [];
    
    function initialize(lvl as Number, week as Number, completed as Number) {
        level = lvl;
        currentWeek = week;
        completedSessions = completed;
        
        // Generate workouts for this week
        var engine = Application.getApp().planEngine;
        if (engine != null) {
            workouts = engine.generateWeeklyWorkouts(week, level);
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
        return (completedSessions * 100) / 5; // 5 sessions per week
    }
}
