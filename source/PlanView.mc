using Toybox.WatchUi;
using Toybox.Graphics;

//! View for displaying the current training plan
class PlanView extends WatchUi.View {
    
    var app as CoachroxApp;
    var plan as Plan;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        plan = app.getCurrentPlan();
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 10, Graphics.FONT_MEDIUM, "Training Plan", Graphics.TEXT_JUSTIFY_CENTER);
        
        if (plan != null) {
            var levelName = "Beginner";
            if (plan.level >= 1) { levelName = "Intermediate"; }
            if (plan.level >= 2) { levelName = "Advanced"; }
            
            dc.drawText(dc.getWidth() / 2, 40, Graphics.FONT_SMALL, "Level: " + levelName, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(dc.getWidth() / 2, 60, Graphics.FONT_SMALL, "Week: " + plan.getWeekNumber() + " of 8", Graphics.TEXT_JUSTIFY_CENTER);
            
            // Progress bar
            var barWidth = dc.getWidth() - 40;
            var progress = plan.getCompletionRate();
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.fillRectangle(20, 85, barWidth, 10);
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.fillRectangle(20, 85, (barWidth * progress) / 100, 10);
            
            dc.drawText(dc.getWidth() / 2, 105, Graphics.FONT_TINY, progress + "% Complete", Graphics.TEXT_JUSTIFY_CENTER);
            
            // Sessions
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(20, 130, Graphics.FONT_SMALL, "This Week:", Graphics.TEXT_JUSTIFY_LEFT);
            
            var y = 150;
            for (var i = 0; i < 5; i++) {
                var workout = plan.getWorkout(i);
                if (workout != null) {
                    var status = workout.isCompleted() ? "[✓]" : "[ ]";
                    dc.drawText(20, y, Graphics.FONT_TINY, status + " " + workout.name, Graphics.TEXT_JUSTIFY_LEFT);
                    y += 18;
                }
            }
        }
        
        // Back hint
        dc.setColor(Graphics.COLOR_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 20, Graphics.FONT_TINY, "ESC: Back", Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class PlanDelegate extends WatchUi.InputDelegate {
    
    var view as PlanView;
    
    function initialize(pView as PlanView) {
        WatchUi.InputDelegate.initialize();
        view = pView;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        if (key.getKey() == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
}
