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
            var next = workout.getStep(currentStepIndex + 1);
            nextStepName = next != null ? next.name : "FINISH";
        }
    }
    
    function onLayout(dc as Dc) as Void {
    }
    
    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        
        // Background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Line 1: Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 2, Graphics.FONT_TINY, "WORKOUT", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Line 2: Current step name
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 18, Graphics.FONT_TINY, currentStepName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Line 3: Timer
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 38, Graphics.FONT_MEDIUM, getElapsedTimeFormatted(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Line 4: Paused
        if (isPaused) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
            dc.drawText(w/2, 60, Graphics.FONT_TINY, "- PAUSED -", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Line 5: Progress bar
        var progress = getProgress();
        var barW = w - 20;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(10, 75, barW, 5);
        dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.fillRectangle(10, 75, barW * progress / 100, 5);
        
        // Line 6: Progress text
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 85, Graphics.FONT_TINY, progress + "%  " + (currentStepIndex + 1) + "/" + workout.getStepCount(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Line 7: Next step
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 100, Graphics.FONT_TINY, "NEXT: " + nextStepName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Line 8: Done
        if (isCompleted) {
            dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.drawText(w/2, 130, Graphics.FONT_MEDIUM, "COMPLETED!", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Line 9: Controls
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w/2, h - 8, Graphics.FONT_TINY, "DOWN: Pause | ENTER: End", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function onShow() as Void {
        timer = new Timer.Timer();
        timer.start(method(:onTimer), 1000, true);
    }
    
    function onTimer() as Void {
        if (!isPaused && !isCompleted) {
            elapsedSeconds++;
            var step = workout.getStep(currentStepIndex);
            if (step != null && step.durationSec > 0 && elapsedSeconds >= step.durationSec) {
                nextStep();
            }
            WatchUi.requestUpdate();
        }
    }
    
    function nextStep() as Void {
        var step = workout.getStep(currentStepIndex);
        if (step != null) { step.completed = true; }
        currentStepIndex++;
        if (currentStepIndex >= workout.getStepCount()) {
            complete(true);
        } else {
            elapsedSeconds = 0;
            updateStepInfo();
        }
    }
    
    function skipStep() as Void { nextStep(); }
    
    function togglePause() as Void { isPaused = !isPaused; }
    
    function complete(success as Boolean) as Void {
        isCompleted = true;
        if (timer != null) { timer.stop(); timer = null; }
        workout.markComplete();
        var week = Application.getApp().completedWeeks;
        var key = "week_" + week + "_completed";
        var curr = sessionStorage.getValue(key) != null ? sessionStorage.getValue(key) : 0;
        sessionStorage.setValue(key, curr + 1);
    }
    
    function getProgress() as Number {
        var total = workout.getStepCount();
        return total > 0 ? (currentStepIndex * 100) / total : 0;
    }
    
    function getElapsedTimeFormatted() as String {
        return (elapsedSeconds / 60) + ":" + (elapsedSeconds % 60).format("%02d");
    }
    
    function onHide() as Void {
        if (timer != null) { timer.stop(); }
    }
}
