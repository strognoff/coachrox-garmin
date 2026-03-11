import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

//! View for displaying the current training plan
class PlanView extends WatchUi.View {
    
    var app as CoachroxApp;
    var plan as Plan;
    
    //! Scroll position
    var scrollY as Number = 0;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        plan = app.getCurrentPlan();
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header with week info at top
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 10, Graphics.FONT_MEDIUM, "Training Plan", Graphics.TEXT_JUSTIFY_CENTER);
        
        if (plan != null) {
            var levelName = "Beginner";
            if (plan.level >= 1) { levelName = "Intermediate"; }
            if (plan.level >= 2) { levelName = "Advanced"; }
            
            // Week and level info at top
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 40, Graphics.FONT_SMALL, "Week " + plan.getWeekNumber() + " of 8 | " + levelName, Graphics.TEXT_JUSTIFY_CENTER);
            
            // Progress bar
            var barWidth = dc.getWidth() - 40;
            var progress = plan.getCompletionRate();
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.fillRectangle(20, 65, barWidth, 10);
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.fillRectangle(20, 65, (barWidth * progress) / 100, 10);
            
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 85, Graphics.FONT_TINY, progress + "% Complete", Graphics.TEXT_JUSTIFY_CENTER);
            
            // Separator line
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.fillRectangle(20, 105, dc.getWidth() - 40, 1);
            
            // Sessions header with more vertical spacing
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 120, Graphics.FONT_SMALL, "This Week's Workouts:", Graphics.TEXT_JUSTIFY_CENTER);
            
            // Workouts with increased spacing
            var y = 145;
            for (var i = 0; i < 5; i++) {
                var workout = plan.getWorkout(i);
                if (workout != null) {
                    var status = workout.isCompleted() ? "[✓]" : "[ ]";
                    
                    // Highlight completed workouts
                    if (workout.isCompleted()) {
                        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
                    } else {
                        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                    }
                    
                    dc.drawText(20, y, Graphics.FONT_SMALL, status + " " + workout.name, Graphics.TEXT_JUSTIFY_LEFT);
                    
                    // Duration below workout name
                    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                    dc.drawText(20, y + 18, Graphics.FONT_TINY, "    " + workout.durationMinutes + " min", Graphics.TEXT_JUSTIFY_LEFT);
                    
                    y += 45; // Increased spacing between items
                }
            }
        }
        
        // Scroll hint
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
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
    
    function onSelect() as Boolean {
        return true;
    }
}
