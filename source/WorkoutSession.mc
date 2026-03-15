import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Activity;
import Toybox.System;
import Toybox.ActivityRecording;

class WorkoutSession extends WatchUi.View {
    
    var workout as Workout;
    var sessionStorage as SessionStorage;
    var currentStepIndex as Number = 0;
    var elapsedSeconds as Number = 0;
    var totalElapsedSeconds as Number = 0;
    var isPaused as Boolean = false;
    var showCountdown as Boolean = false;
    var countdownSeconds as Number = 0;
    var isCompleted as Boolean = false;
    var showSummary as Boolean = false;
    var timer as Timer.Timer?;
    var currentStepName as String = "";
    var nextStepName as String = "";
    var workoutIndex as Number = 0;
    var currentHeartRate as Number = 0;
    var session; // ActivityRecording session (kept untyped for device/API compatibility)
    
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    const COLOR_RED = 0xFF3B30;
    
    function initialize(workoutInstance as Workout, storage as SessionStorage, idx as Number) {
        WatchUi.View.initialize();
        workout = workoutInstance;
        sessionStorage = storage;
        workoutIndex = idx;
        
        if (workout.getStepCount() > 0) {
            updateStepInfo();
        }
        
        // Start activity recording session for HR tracking
        startActivitySession();
    }
    
    function startActivitySession() as Void {
        // Create and start an activity recording session
        if (Toybox has :ActivityRecording) {
            session = ActivityRecording.createSession({
                :name => "COACHROX",
                :sport => Activity.SPORT_TRAINING,
                :subSport => Activity.SUB_SPORT_GENERIC
            });
            
            if (session != null) {
                session.start();
            }
        }
    }
    
    function onSensor(sensorInfo) as Void {
        // Update heart rate from sensor callback
        if (sensorInfo != null && sensorInfo has :heartRate && sensorInfo.heartRate != null) {
            currentHeartRate = sensorInfo.heartRate;
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
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        if (showSummary) {
            drawSummary(dc, w, h);
            return;
        }
        
            // ===== Layout constants - start from top with proper spacing =====
        var cx = w / 2;
        var startY = 20; // Start much higher near the top
        var currentY = startY;
    
    // ===== Header =====
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(cx, currentY, Graphics.FONT_XTINY, "WORKOUT", Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 18;
        
        // ===== Current step name =====
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(cx, currentY, Graphics.FONT_SMALL, currentStepName, Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 28;
        
        // ===== Timer (largest element) =====
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(cx, currentY, Graphics.FONT_NUMBER_MEDIUM, getElapsedTimeFormatted(), Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 50; // Increased from 40 to add more space before progress bar
        
        // ===== Paused indicator =====
        if (isPaused) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
            dc.drawText(cx, currentY, Graphics.FONT_XTINY, "PAUSED", Graphics.TEXT_JUSTIFY_CENTER);
            currentY += 18;
        } else {
            // Add spacing even when not paused to maintain consistent layout
            currentY += 6;
        }
        
        // ===== Progress bar =====
        var progress = getProgress();
        var barW = w - 60;
        var barX = (w - barW) / 2;
        
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(barX, currentY, barW, 4);
        dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.fillRectangle(barX, currentY, (barW * progress) / 100, 4);
        currentY += 12; // Increased from 10
        
        // Progress text
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);

        var stepMinutesText = "";
        var _stepForMinutes = workout.getStep(currentStepIndex);
        if (_stepForMinutes != null && _stepForMinutes.durationSec != null && _stepForMinutes.durationSec > 0) {
            stepMinutesText = " • " + (_stepForMinutes.durationSec / 60) + " min";
        }

        dc.drawText(cx, currentY, Graphics.FONT_XTINY,
            (currentStepIndex + 1) + "/" + workout.getStepCount() + " • " + progress + "%" + stepMinutesText,
            Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 20; // Increased from 18
        
        // ===== Targets =====
        var currentStep = workout.getStep(currentStepIndex);
        if (currentStep != null) {
            if (currentStep.targetHRZone > 0) {
                dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
                dc.drawText(cx, currentY, Graphics.FONT_XTINY,
                    "HR: " + WorkoutStep.getHRZoneName(currentStep.targetHRZone),
                    Graphics.TEXT_JUSTIFY_CENTER);
                currentY += 18; // Increased from 16 for more space
            }
            
            if (currentStep.targetRPE > 0) {
                dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
                dc.drawText(cx, currentY, Graphics.FONT_XTINY,
                    "RPE: " + currentStep.targetRPE + " " + WorkoutStep.getRPEDescription(currentStep.targetRPE),
                    Graphics.TEXT_JUSTIFY_CENTER);
                currentY += 16;
            }
        }
        
        // ===== Next step or completion message =====
        currentY += 14; // Increased from 6
        if (isCompleted) {
            dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.drawText(cx, currentY, Graphics.FONT_SMALL, "COMPLETE!", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(cx, currentY, Graphics.FONT_XTINY, "NEXT: " + nextStepName, Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // ===== Current Heart Rate =====
        currentY += 18;
        updateHeartRate();
        if (currentHeartRate > 0) {
            dc.setColor(COLOR_RED, Graphics.COLOR_BLACK);
            dc.drawText(cx, currentY, Graphics.FONT_XTINY, "HR: " + currentHeartRate + " bpm", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(cx, currentY, Graphics.FONT_XTINY, "HR: --", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // ===== Controls hint at bottom (fixed position) =====
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(cx, h - 20, Graphics.FONT_XTINY, "DOWN=Pause ENTER=End", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function updateHeartRate() as Void {
        // Get latest heart rate from Activity Info
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null && activityInfo has :currentHeartRate && activityInfo.currentHeartRate != null) {
            currentHeartRate = activityInfo.currentHeartRate;
        }
    }

    //! Draw the post-workout summary screen
    function drawSummary(dc as Dc, w as Number, h as Number) as Void {
        var cx = w / 2;
        var currentY = 10;
        
        // Header
        dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.drawText(cx, currentY, Graphics.FONT_XTINY, "COMPLETE!", Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 20;
        
        // Workout name
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(cx, currentY, Graphics.FONT_XTINY, workout.name, Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 20;
        
        // Phase indicator
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        var phaseName = workout.getPhaseName();
        dc.drawText(cx, currentY, Graphics.FONT_XTINY, "Phase: " + phaseName, Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 22;
        
        // Total time (prominent)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(cx, currentY, Graphics.FONT_NUMBER_MEDIUM, getTotalElapsedTimeFormatted(), Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 50;
        
        // Steps completed
        var completedSteps = 0;
        for (var i = 0; i < workout.getStepCount(); i++) {
            var step = workout.getStep(i);
            if (step != null && step.completed) { completedSteps++; }
        }
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(cx, currentY, Graphics.FONT_XTINY, 
            "Steps: " + completedSteps + "/" + workout.getStepCount(), 
            Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 22;
        
        // Compliance percentage
        var compliance = workout.getCompliancePercent();
        var complianceColor = COLOR_GREEN;
        if (compliance < 70) { complianceColor = COLOR_ORANGE; }
        if (compliance < 50) { complianceColor = COLOR_RED; }
        
        dc.setColor(complianceColor, Graphics.COLOR_BLACK);
        dc.drawText(cx, currentY, Graphics.FONT_XTINY, 
            "Compliance: " + compliance + "%", 
            Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 18;
        
        // Compliance status
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        var status = workout.getComplianceStatus();
        dc.drawText(cx, currentY, Graphics.FONT_XTINY, status, Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 18;
        
        // Week info
        var week = Application.getApp().completedWeeks;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(cx, currentY, Graphics.FONT_XTINY, "Week: " + (week + 1), Graphics.TEXT_JUSTIFY_CENTER);
        currentY += 18;
        
        // Adaptation status
        var app = Application.getApp();
        if (app.planEngine != null) {
            var adaptStatus = app.planEngine.getAdaptationStatus();
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
            dc.drawText(cx, currentY, Graphics.FONT_XTINY, adaptStatus, Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Exit hint at bottom (fixed position)
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(cx, h - 16, Graphics.FONT_XTINY, "ENTER=exit", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function onShow() as Void {
        timer = new Timer.Timer();
        timer.start(method(:onTimer), 1000, true);
    }
    
    function onTimer() as Void {
        if (!isPaused && !isCompleted) {
            elapsedSeconds++;
            totalElapsedSeconds++;
            var step = workout.getStep(currentStepIndex);
            if (step != null && step.durationSec > 0 && elapsedSeconds >= step.durationSec) {
                nextStep();
            }
            WatchUi.requestUpdate();
        }
    }
    
    function nextStep() as Void {
        var step = workout.getStep(currentStepIndex);
        if (step != null) { 
            step.completed = true;
            // Record actual performance for compliance tracking
            step.recordActual(elapsedSeconds, step.targetReps, step.distanceMeters);
        }
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
    
    function startCountdown() as Void {
        showCountdown = true;
        countdownSeconds = 5;
    }
    
    function updateCountdown() as Boolean {
        if (showCountdown && countdownSeconds > 0) {
            countdownSeconds--;
            if (countdownSeconds == 0) {
                showCountdown = false;
                return true; // Trigger step change
            }
        }
        return false;
    }
    
    function complete(success as Boolean) as Void {
        isCompleted = true;
        showSummary = true;
        if (timer != null) { timer.stop(); timer = null; }
        workout.markComplete();
        
        // Stop and save the activity recording
        if (session != null && session.isRecording()) {
            session.stop();
            session.save();
            session = null;
        }
        
        // Mark workout as completed for this week
        var week = Application.getApp().completedWeeks;
        sessionStorage.setValue("week_" + week + "_day_" + workoutIndex + "_done", 1);
        
        // Increment completed sessions for week
        var key = "week_" + week + "_completed";
        var curr = sessionStorage.getValue(key) != null ? sessionStorage.getValue(key) : 0;
        sessionStorage.setValue(key, curr + 1);
        
        // Calculate weekly adherence percentage (completed/5 * 100)
        var weeklyAdherence = ((curr + 1) * 100) / 5;
        
        // Record the workout result for adaptation
        var app = Application.getApp();
        if (app.planEngine != null) {
            app.planEngine.recordWorkoutResult(success);
            
            // Record weekly adherence for progression logic
            app.planEngine.recordWeeklyAdherence(week, weeklyAdherence);
        }
        
        WatchUi.requestUpdate();
    }
    
    function finishAndExit() as Void {
        // Increment total weeks after completing all 5 workouts for the week
        var week = Application.getApp().completedWeeks;
        var completedThisWeek = sessionStorage.getValue("week_" + week + "_completed") != null 
            ? sessionStorage.getValue("week_" + week + "_completed") 
            : 0;
        
        if (completedThisWeek >= 5) {
            Application.getApp().completedWeeks = week + 1;
            sessionStorage.setValue("completedWeeks", week + 1);
        }
        
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }
    
    function getProgress() as Number {
        var total = workout.getStepCount();
        return total > 0 ? (currentStepIndex * 100) / total : 0;
    }
    
    function getElapsedTimeFormatted() as String {
        return (elapsedSeconds / 60) + ":" + (elapsedSeconds % 60).format("%02d");
    }
    
    function getTotalElapsedTimeFormatted() as String {
        return (totalElapsedSeconds / 60) + ":" + (totalElapsedSeconds % 60).format("%02d");
    }
    
    function onHide() as Void {
        if (timer != null) { timer.stop(); }
        
        // Clean up activity session if still running
        if (session != null && session.isRecording()) {
            session.stop();
            session.save();
            session = null;
        }
    }
}
