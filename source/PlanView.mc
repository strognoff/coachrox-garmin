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
        
        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 2, Graphics.FONT_TINY, "WEEK " + plan.getWeekNumber(), Graphics.TEXT_JUSTIFY_CENTER);

        // Show phase info
        var engine = app.planEngine;
        if (engine != null) {
            var phase = engine.getPhaseForWeek(plan.getWeekNumber());
            var phaseName = engine.getPhaseName(phase);
            dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
            dc.drawText(w/2, 14, Graphics.FONT_TINY, phaseName + " PHASE", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Progress bar
        var completion = plan.getCompletionRate().toNumber();
        var barColor = completion >= 100 ? COLOR_GREEN : (completion >= 50 ? COLOR_YELLOW : COLOR_BLUE);
        
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(10, 28, w - 20, 4);
        dc.setColor(barColor, Graphics.COLOR_BLACK);
        dc.fillRectangle(10, 28, (w - 20) * completion / 100, 4);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 36, Graphics.FONT_TINY, completion + "%", Graphics.TEXT_JUSTIFY_CENTER);

        // Workouts list from Plan
        var y = 50;
        
        for (var i = 0; i < 5; i++) {
            var workout = plan.getWorkout(i);
            if (workout != null) {
                var done = workout.isCompleted();
                dc.setColor(done ? COLOR_GREEN : Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.drawText(10, y, Graphics.FONT_TINY, (i+1) + ". " + workout.name, Graphics.TEXT_JUSTIFY_LEFT);
                
                // Phase indicator
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                dc.drawText(w - 10, y, Graphics.FONT_TINY, workout.getPhaseName(), Graphics.TEXT_JUSTIFY_RIGHT);
            }
            y += 16;
        }

        // Footer
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w/2, h - 8, Graphics.FONT_TINY, "ESC: Back", Graphics.TEXT_JUSTIFY_CENTER);
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
