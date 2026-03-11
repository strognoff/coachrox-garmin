import Toybox.Lang;
import Toybox.Timer;
import Toybox.Activity;
import Toybox.SensorHistory;
import Toybox.WatchUi;
import Toybox.Graphics;

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
        // Custom drawn view - no layout needed
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 10, Graphics.FONT_MEDIUM, "Workout", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Pause indicator
        if (isPaused) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 35, Graphics.FONT_SMALL, "PAUSED", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Current step
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 60, Graphics.FONT_SMALL, "Current:", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, 80, Graphics.FONT_LARGE, currentStepName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Duration / Time
        if (!isCompleted) {
            var timeDisplay = isPaused ? currentStepDuration : getElapsedTimeFormatted();
            dc.drawText(dc.getWidth() / 2, 115, Graphics.FONT_MEDIUM, timeDisplay, Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Progress bar
        var barWidth = dc.getWidth() - 40;
        var progress = getProgress();
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 140, barWidth, 10);
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 140, (barWidth * progress) / 100, 10);
        
        // Progress text
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 160, Graphics.FONT_TINY, progress + "% | Step " + (currentStepIndex + 1) + "/" + workout.getStepCount(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Next step
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 180, Graphics.FONT_TINY, "Next: " + nextStepName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Completion message
        if (isCompleted) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_LARGE, "COMPLETED!", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Instructions
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 25, Graphics.FONT_TINY, "UP: Skip | DOWN: Pause | ENTER: Finish", Graphics.TEXT_JUSTIFY_CENTER);
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
