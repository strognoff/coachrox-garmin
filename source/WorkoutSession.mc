using Toybox.Timer;
using Toybox.Activity;
using Toybox.SensorHistory;

//! Active workout session runtime
class WorkoutSession extends WatchUi.View {
    
    var workout as Workout;
    var sessionStorage as SessionStorage;
    
    var currentStepIndex as Number = 0;
    var elapsedSeconds as Number = 0;
    var isPaused as Boolean = false;
    var isCompleted as Boolean = false;
    
    var timer as Timer.Timer?;
    var startTime as Number;
    
    //! Current step info for display
    var currentStepName as String = "";
    var currentStepDuration as String = "";
    var nextStepName as String = "";
    
    function initialize(workoutInstance as Workout, storage as SessionStorage) {
        WatchUi.View.initialize();
        
        workout = workoutInstance;
        sessionStorage = storage;
        
        startTime = Time.now().value();
        
        if (workout.getStepCount() > 0) {
            updateStepInfo();
        }
    }
    
    function updateStepInfo() as Void {
        var step = workout.getStep(currentStepIndex);
        if (step != null) {
            currentStepName = step.name;
            currentStepDuration = step.getDurationFormatted();
            
            var next = workout.getStep(currentStepIndex + 1);
            nextStepName = next != null ? next.name : "Done";
        }
    }
    
    function onLayout(dc as Dc) as Void {
        setLayout(dc);
    }
    
    function onShow() as Void {
        // Start the workout timer
        timer = new Timer.Timer();
        timer.start(method(:onTimer), 1000, true);
    }
    
    function onTimer() as Void {
        if (!isPaused && !isCompleted) {
            elapsedSeconds++;
            
            var currentStep = workout.getStep(currentStepIndex);
            if (currentStep != null && currentStep.durationSec > 0) {
                if (elapsedSeconds >= currentStep.durationSec) {
                    // Move to next step
                    nextStep();
                }
            }
            
            // Request UI update
            WatchUi.requestUpdate();
        }
    }
    
    function nextStep() as Void {
        var step = workout.getStep(currentStepIndex);
        if (step != null) {
            step.completed = true;
            
            // Vibrate on transition
            System.println("Step completed: " + step.name);
        }
        
        currentStepIndex++;
        
        if (currentStepIndex >= workout.getStepCount()) {
            complete(true);
        } else {
            elapsedSeconds = 0;
            updateStepInfo();
        }
    }
    
    function skipStep() as Void {
        nextStep();
    }
    
    function togglePause() as Void {
        isPaused = !isPaused;
    }
    
    function complete(success as Boolean) as Void {
        isCompleted = true;
        
        if (timer != null) {
            timer.stop();
            timer = null;
        }
        
        workout.markComplete();
        
        // Save to storage
        var week = Application.getApp().completedWeeks;
        var completedKey = "week_" + week + "_completed";
        var current = sessionStorage.getValue(completedKey) != null ? sessionStorage.getValue(completedKey) : 0;
        sessionStorage.setValue(completedKey, current + 1);
        
        // Record completion
        var workoutId = workout.id;
        sessionStorage.setValue("workout_" + workoutId + "_completed", 1);
        sessionStorage.setValue("workout_" + workoutId + "_duration", elapsedSeconds);
        sessionStorage.setValue("workout_" + workoutId + "_success", success ? 1 : 0);
    }
    
    function getProgress() as Number {
        return (currentStepIndex * 100) / workout.getStepCount();
    }
    
    function getElapsedTimeFormatted() as String {
        var minutes = elapsedSeconds / 60;
        var seconds = elapsedSeconds % 60;
        return minutes + ":" + seconds.format("%02d");
    }
    
    function onHide() as Void {
        if (timer != null) {
            timer.stop();
        }
    }
}
