import Toybox.Lang;

//! Represents a single workout step
class WorkoutStep {
    var name as String;
    var activityType as String; // run, rest, burpee broad jump, lunges, farmer carry, etc.
    var durationSec as Number;
    var distanceMeters as Number;
    var targetReps as Number;
    var completed as Boolean;
    
    function initialize(stepName as String, actType as String, duration as Number, distance as Number, reps as Number) {
        name = stepName;
        activityType = actType;
        durationSec = duration;
        distanceMeters = distance;
        targetReps = reps;
        completed = false;
    }
    
    function getDurationFormatted() as String {
        var minutes = durationSec / 60;
        var seconds = durationSec % 60;
        if (seconds > 0) {
            return minutes + ":" + seconds.format("%02d");
        }
        return minutes + " min";
    }
    
    function isTimeBased() as Boolean {
        return durationSec > 0;
    }
    
    function isRepBased() as Boolean {
        return targetReps > 0;
    }
    
    function isDistanceBased() as Boolean {
        return distanceMeters > 0;
    }
}

//! Represents a complete workout
class Workout {
    var id as Number;
    var name as String;
    var type as Number;
    var durationMinutes as Number;
    var steps as Array<WorkoutStep>;
    var completedAt as Number?;
    
    private static var nextId = 0;
    
    function initialize(workoutName as String, workoutType as Number, duration as Number, workoutSteps as Array<WorkoutStep>) {
        id = Workout.nextId;
        Workout.nextId++;
        
        name = workoutName;
        type = workoutType;
        durationMinutes = duration;
        steps = workoutSteps;
        completedAt = null;
    }
    
    function getStepCount() as Number {
        return steps.size();
    }
    
    function getStep(index as Number) as WorkoutStep? {
        if (index >= 0 && index < steps.size()) {
            return steps[index];
        }
        return null;
    }
    
    function markComplete() as Void {
        completedAt = Time.now().value();
    }
    
    function isCompleted() as Boolean {
        return completedAt != null;
    }
    
    function getTotalDuration() as Number {
        var total = 0;
        for (var i = 0; i < steps.size(); i++) {
            total += steps[i].durationSec;
        }
        return total;
    }
    
    function getIntensityLabel() as String {
        if (type == 0) { // Intervals
            return "High";
        } else if (type == 1) { // Combo
            return "High";
        } else if (type == 2) { // Threshold
            return "Very High";
        }
        return "Low"; // Recovery
    }
}
