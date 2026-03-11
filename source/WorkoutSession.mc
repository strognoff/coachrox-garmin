import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;
import Toybox.Graphics;

class WorkoutSession extends WatchUi.View {
    
    var workout as Workout;
    var sessionStorage as SessionStorage;
    
    var currentStepIndex as Number = 0;
    var elapsedSeconds as Number = 0;
    var isPaused as Boolean = false;
    var isCompleted as Boolean = false;
    
    var timer as Timer.Timer?;
    
    var currentStepName as String = "";
    var currentStepDuration as String = "";
    var nextStepName as String = "";
    
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    
    function initialize(workoutInstance as Workout, storage as SessionStorage) {
        WatchUi.View.initialize();
        workout = workoutInstance;
        sessionStorage = storage;
        
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
            nextStepName = next != null ? next.name : "DONE";
        }
    }
    
    function onLayout(dc as Dc) as Void {
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 5, Graphics.FONT_SMALL, "WORKOUT", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Current step name - large in center
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 30, Graphics.FONT_MEDIUM, currentStepName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Timer
        var timeStr = getElapsedTimeFormatted();
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 65, Graphics.FONT_LARGE, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Paused?
        if (isPaused) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 95, Graphics.FONT_TINY, "PAUSED", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Progress bar
        var progress = getProgress();
        var barW = dc.getWidth() - 30;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(15, 115, barW, 8);
        dc.setColor(COLOR_GREEN, Graphics.TEXT_JUSTIFY_CENTER);
        dc.fillRectangle(15, 115, barW * progress / 100, 8);
        
        // Progress text
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 128, Graphics.FONT_TINY, progress + "% - Step " + (currentStepIndex + 1) + "/" + workout.getStepCount(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Next step
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 145, Graphics.FONT_TINY, "Next: " + nextStepName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Completion
        if (isCompleted) {
            dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 170, Graphics.FONT_MEDIUM, "DONE!", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Controls hint
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 12, Graphics.FONT_TINY, "DOWN: Pause | ENTER: Finish", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function onShow() as Void {
        timer = new Timer.Timer();
        timer.start(method(:onTimer), 1000, true);
    }
    
    function onTimer() as Void {
        if (!isPaused && !isCompleted) {
            elapsedSeconds++;
            var step = workout.getStep(currentStepIndex);
            if (step != null && step.durationSec > 0) {
                if (elapsedSeconds >= step.durationSec) {
                    nextStep();
                }
            }
            WatchUi.requestUpdate();
        }
    }
    
    function nextStep() as Void {
        var step = workout.getStep(currentStepIndex);
        if (step != null) {
            step.completed = true;
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
        
        var week = Application.getApp().completedWeeks;
        var key = "week_" + week + "_completed";
        var curr = sessionStorage.getValue(key) != null ? sessionStorage.getValue(key) : 0;
        sessionStorage.setValue(key, curr + 1);
        
        sessionStorage.setValue("workout_" + workout.id + "_completed", 1);
    }
    
    function getProgress() as Number {
        return (currentStepIndex * 100) / workout.getStepCount();
    }
    
    function getElapsedTimeFormatted() as String {
        var min = elapsedSeconds / 60;
        var sec = elapsedSeconds % 60;
        return min + ":" + sec.format("%02d");
    }
    
    function onHide() as Void {
        if (timer != null) {
            timer.stop();
        }
    }
}
