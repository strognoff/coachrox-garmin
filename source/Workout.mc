import Toybox.Lang;

//! Represents a single workout step
class WorkoutStep {
    var name as String;
    var activityType as String; // run, rest, burpee broad jump, lunges, farmer carry, etc.
    var durationSec as Number;
    var distanceMeters as Number;
    var targetReps as Number;
    var completed as Boolean;
    
    // Target model per workout step
    var targetPaceSecPerKm as Number;  // Target pace in seconds per km (e.g., 300 = 5:00/km)
    var targetHRZone as Number;          // Target HR zone (1-5)
    var targetRPE as Number;             // Target RPE 1-10
    
    // Compliance tracking
    var actualDurationSec as Number;     // Actual time spent on step
    var actualReps as Number;             // Actual reps completed
    var actualDistanceMeters as Number;   // Actual distance covered
    
    function initialize(stepName as String, actType as String, duration as Number, distance as Number, reps as Number) {
        name = stepName;
        activityType = actType;
        durationSec = duration;
        distanceMeters = distance;
        targetReps = reps;
        completed = false;
        
        // Initialize targets (0 = not set)
        targetPaceSecPerKm = 0;
        targetHRZone = 0;
        targetRPE = 0;
        
        // Initialize actuals
        actualDurationSec = 0;
        actualReps = 0;
        actualDistanceMeters = 0;
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
    
    //! Set target pace (pace in seconds per km, e.g., 300 = 5:00/km)
    function setTargetPace(paceSecPerKm as Number) as Void {
        targetPaceSecPerKm = paceSecPerKm;
    }
    
    //! Set target HR zone (1-5)
    function setTargetHRZone(zone as Number) as Void {
        targetHRZone = zone;
    }
    
    //! Set target RPE (1-10)
    function setTargetRPE(rpe as Number) as Void {
        targetRPE = rpe;
    }
    
    //! Record actual performance for compliance tracking
    function recordActual(duration as Number, reps as Number, distance as Number) as Void {
        actualDurationSec = duration;
        actualReps = reps;
        actualDistanceMeters = distance;
    }
    
    //! Calculate step compliance percentage (0-100)
    function getCompliancePercent() as Number {
        var totalScore = 0.0 as Float;
        var factors = 0;
        
        // Time compliance (for time-based steps)
        if (durationSec > 0) {
            var timeCompliance = (actualDurationSec.toFloat() / durationSec.toFloat()) * 100;
            // Cap at 100%, allow partial credit for partial completion
            totalScore += timeCompliance > 100 ? 100 : timeCompliance;
            factors++;
        }
        
        // Rep compliance (for rep-based steps)
        if (targetReps > 0) {
            var repCompliance = (actualReps.toFloat() / targetReps.toFloat()) * 100;
            totalScore += repCompliance > 100 ? 100 : repCompliance;
            factors++;
        }
        
        // Distance compliance (for distance-based steps)
        if (distanceMeters > 0) {
            var distCompliance = (actualDistanceMeters.toFloat() / distanceMeters.toFloat()) * 100;
            totalScore += distCompliance > 100 ? 100 : distCompliance;
            factors++;
        }
        
        if (factors == 0) { return 100; } // Default if no targets
        return (totalScore / factors).toNumber();
    }
    
    //! Get HR zone name for display
    static function getHRZoneName(zone as Number) as String {
        if (zone == 1) { return "Z1 Recovery"; }
        else if (zone == 2) { return "Z2 Aerobic"; }
        else if (zone == 3) { return "Z3 Tempo"; }
        else if (zone == 4) { return "Z4 Threshold"; }
        else if (zone == 5) { return "Z5 VO2Max"; }
        return "--";
    }
    
    //! Get RPE description
    static function getRPEDescription(rpe as Number) as String {
        if (rpe <= 2) { return "Very Easy"; }
        else if (rpe <= 4) { return "Easy"; }
        else if (rpe <= 6) { return "Moderate"; }
        else if (rpe <= 8) { return "Hard"; }
        else if (rpe <= 10) { return "Max Effort"; }
        return "--";
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
    var phase as Number; // 0=BASE, 1=BUILD, 2=SPECIFIC, 3=TAPER
    
    // Workout-level compliance tracking
    var stepsCompleted as Number;
    var totalCompliancePercent as Number;
    
    private static var nextId = 0;
    
    function initialize(workoutName as String, workoutType as Number, duration as Number, workoutSteps as Array<WorkoutStep>) {
        id = Workout.nextId;
        Workout.nextId++;
        
        name = workoutName;
        type = workoutType;
        durationMinutes = duration;
        steps = workoutSteps;
        completedAt = null;
        phase = 0; // Default to BASE
        stepsCompleted = 0;
        totalCompliancePercent = 0;
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
    
    //! Set phase for this workout
    function setPhase(week as Number) as Void {
        if (week <= 4) { phase = 0; } // BASE
        else if (week <= 8) { phase = 1; } // BUILD
        else if (week <= 11) { phase = 2; } // SPECIFIC
        else { phase = 3; } // TAPER
    }
    
    //! Get phase name
    function getPhaseName() as String {
        if (phase == 0) { return "BASE"; }
        else if (phase == 1) { return "BUILD"; }
        else if (phase == 2) { return "SPECIFIC"; }
        else { return "TAPER"; }
    }
    
    //! Mark a step as completed with actual performance
    function completeStep(stepIndex as Number, actualDuration as Number, actualReps as Number, actualDistance as Number) as Void {
        if (stepIndex >= 0 && stepIndex < steps.size()) {
            var step = steps[stepIndex];
            step.completed = true;
            step.recordActual(actualDuration, actualReps, actualDistance);
            stepsCompleted++;
        }
    }
    
    //! Calculate workout-level compliance percentage
    function getCompliancePercent() as Number {
        if (steps.size() == 0) { return 100; }
        
        var totalCompliance = 0;
        for (var i = 0; i < steps.size(); i++) {
            totalCompliance += steps[i].getCompliancePercent();
        }
        
        totalCompliancePercent = totalCompliance / steps.size();
        return totalCompliancePercent.toNumber();
    }
    
    //! Get compliance status for display
    function getComplianceStatus() as String {
        var pct = getCompliancePercent();
        if (pct >= 85) { return "EXCELLENT"; }
        else if (pct >= 70) { return "GOOD"; }
        else if (pct >= 50) { return "PARTIAL"; }
        else { return "INCOMPLETE"; }
    }
}
