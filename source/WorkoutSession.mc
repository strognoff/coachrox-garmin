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

    // Fonts + measured heights (prevents "broken" spacing across devices)
    var headerFont = Graphics.FONT_TINY;
    var titleFont = Graphics.FONT_TINY;
    var timerFont = Graphics.FONT_MEDIUM;
    var smallFont = Graphics.FONT_TINY;

    var headerFontH = dc.getFontHeight(headerFont);
    var titleFontH = dc.getFontHeight(titleFont);
    var timerFontH = dc.getFontHeight(timerFont);
    var smallFontH = dc.getFontHeight(smallFont);

    var topPad = 2;
    var sidePad = 10;
    var lineGap = 2;

    // Reserve footer for controls text
    var footerH = smallFontH + 4;
    var contentTop = topPad;
    var contentBottom = h - footerH;
    var contentH = contentBottom - contentTop;

    var y = contentTop;

    // Line 1: Header
    dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
    dc.drawText(w / 2, y, headerFont, "WORKOUT", Graphics.TEXT_JUSTIFY_CENTER);
    y += headerFontH + lineGap;

    // Line 2: Current step name (truncate if too long)
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    var stepName = currentStepName;
    dc.drawText(w / 2, y, titleFont, stepName, Graphics.TEXT_JUSTIFY_CENTER);
    y += titleFontH + lineGap;

    // Line 3: Timer (center in remaining vertical space above progress area)
    // Keep timer prominent and centered-ish
    var timerY = contentTop + (contentH * 0.30).toNumber();
    dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
    dc.drawText(w / 2, timerY, timerFont, getElapsedTimeFormatted(), Graphics.TEXT_JUSTIFY_CENTER);

    // Paused indicator (under timer) - do not show if completed
    if (isPaused && !isCompleted) {
        var pausedY = timerY + timerFontH + 2;
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, pausedY, smallFont, "- PAUSED -", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Progress block anchored toward bottom of content area (so it doesn't overlap on small screens)
    var barH = 6;
    var barW = w - (sidePad * 2);
    var barY = contentBottom - (barH + (smallFontH * 2) + 10);

    // Line: Progress bar
    var progress = getProgress();
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
    dc.fillRectangle(sidePad, barY, barW, barH);
    dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
    dc.fillRectangle(sidePad, barY, (barW * progress / 100).toNumber(), barH);

    // Line: Progress text
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.drawText(w / 2, barY + barH + 2, smallFont, progress + "%  " + (currentStepIndex + 1) + "/" + workout.getStepCount(), Graphics.TEXT_JUSTIFY_CENTER);

    // Line: Next step
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
    dc.drawText(w / 2, barY + barH + 2 + smallFontH + 2, smallFont, "NEXT: " + nextStepName, Graphics.TEXT_JUSTIFY_CENTER);

    // Completed overlay (centered) - wins over paused indicator
    var totalSteps = workout.getStepCount();
    var isAtEnd = (totalSteps > 0) && ((currentStepIndex + 1) >= totalSteps);

    if (isCompleted || isAtEnd) {
        dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, (contentTop + (contentH / 2).toNumber()), Graphics.FONT_MEDIUM, "COMPLETED!", Graphics.TEXT_JUSTIFY_CENTER);
    }

    
    // Footer: Controls
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
    dc.drawText(w / 2, h - footerH + 1, Graphics.FONT_XTINY, "DOWN: Pause | ENTER: End", Graphics.TEXT_JUSTIFY_CENTER);
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
        if (total <= 0) { return 0; }

        // Use 1-based step position so the last step shows 100%.
        var completedOrCurrent = currentStepIndex + 1;

        // Clamp to [1..total] (and thus [0..100]) so UI never exceeds 100%.
        if (completedOrCurrent < 1) { completedOrCurrent = 1; }
        if (completedOrCurrent > total) { completedOrCurrent = total; }

        var pct = (completedOrCurrent * 100 / total).toNumber();
        if (pct < 0) { pct = 0; }
        if (pct > 100) { pct = 100; }
        return pct;
    }
    
    function getElapsedTimeFormatted() as String {
        return (elapsedSeconds / 60) + ":" + (elapsedSeconds % 60).format("%02d");
    }
    
    function onHide() as Void {
        if (timer != null) { timer.stop(); }
    }
}
