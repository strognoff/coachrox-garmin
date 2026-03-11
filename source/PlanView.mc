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
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 5, Graphics.FONT_SMALL, "TRAINING PLAN", Graphics.TEXT_JUSTIFY_CENTER);
        
        var plan = app.getCurrentPlan();
        if (plan != null) {
            var info = "Week " + plan.getWeekNumber();
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 25, Graphics.FONT_TINY, info, Graphics.TEXT_JUSTIFY_CENTER);
            
            // Progress bar
            var completion = plan.getCompletionRate().toNumber();
            var barColor = completion >= 100 ? COLOR_GREEN : (completion >= 50 ? COLOR_YELLOW : COLOR_BLUE);
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.fillRectangle(20, 40, dc.getWidth() - 40, 8);
            dc.setColor(barColor, Graphics.COLOR_BLACK);
            dc.fillRectangle(20, 40, (dc.getWidth() - 40) * completion / 100, 8);
            
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 52, Graphics.FONT_TINY, completion + "%", Graphics.TEXT_JUSTIFY_CENTER);
            
            // Workout list
            var y = 70;
            var workoutNames = ["Intervals 1", "Intervals 2", "Tempo Run", "Long Run", "Recovery"];
            
            for (var i = 0; i < 5; i++) {
                if (y > dc.getHeight() - 25) { break; }
                var done = (i < completion / 20);
                dc.setColor(done ? COLOR_GREEN : Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.drawText(10, y, Graphics.FONT_SMALL, (i + 1) + ". " + workoutNames[i], Graphics.TEXT_JUSTIFY_LEFT);
                y += 25;
            }
        }
        
        // Footer
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 12, Graphics.FONT_TINY, "ESC: Back", Graphics.TEXT_JUSTIFY_CENTER);
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
