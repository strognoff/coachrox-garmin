import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class PlanView extends WatchUi.View {
    
    var app as CoachroxApp;
    
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    const COLOR_YELLOW = 0xFFD600;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
    }
    
    function onLayout(dc as Dc) as Void {
    }
    
    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var plan = app.getCurrentPlan();
        
        // Start from the top
        var y = 15;
        
        // Phase info at the top header
        var engine = app.planEngine;
        if (engine != null) {
            var phase = engine.getPhaseForWeek(plan.getWeekNumber());
            var phaseName = engine.getPhaseName(phase);
            dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
            dc.drawText(w/2, y, Graphics.FONT_TINY, phaseName + " PHASE", Graphics.TEXT_JUSTIFY_CENTER);
            y += 18;
        }

        // Header - Week Number (with space after phase)
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, y + 5, Graphics.FONT_SMALL, "WEEK " + plan.getWeekNumber(), Graphics.TEXT_JUSTIFY_CENTER);
        y += 40;

        // Progress bar
        var completion = plan.getCompletionRate().toNumber();
        var barColor = completion >= 100 ? COLOR_GREEN : (completion >= 50 ? COLOR_YELLOW : COLOR_BLUE);
        
        var barWidth = w - 40;
        var barX = (w - barWidth) / 2;
        
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(barX, y, barWidth, 6);
        dc.setColor(barColor, Graphics.COLOR_BLACK);
        dc.fillRectangle(barX, y, barWidth * completion / 100, 6);
        y += 10;
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, y, Graphics.FONT_MEDIUM, completion + "%", Graphics.TEXT_JUSTIFY_CENTER);
        y += 30;

        // Workouts list - with more spacing between items
        for (var i = 0; i < 5; i++) {
            var workout = plan.getWorkout(i);
            if (workout != null) {
                var done = workout.isCompleted();
                dc.setColor(done ? COLOR_GREEN : Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                
                // Workout name
                var workoutText = (i+1) + ". " + workout.name;
                dc.drawText(w/2, y+20, Graphics.FONT_XTINY, workoutText, Graphics.TEXT_JUSTIFY_CENTER);
                
                y += 25;
            } else {
                y += 16;
            }
        }

        // Footer hint
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w/2, h - 20, Graphics.FONT_XTINY, "ESC: Back", Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class PlanDelegate extends WatchUi.InputDelegate {
    var view as PlanView;
    
    function initialize(planView as PlanView) {
        WatchUi.InputDelegate.initialize();
        view = planView;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        if (key.getKey() == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
}
