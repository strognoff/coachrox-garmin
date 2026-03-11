import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

//! View for displaying the current training plan
class PlanView extends WatchUi.Scrollable {
    
    var app as CoachroxApp;
    var plan as Plan;
    
    //! Scroll position
    var scrollY as Number = 0;
    
    //! Color constants - vibrant palette
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    const COLOR_YELLOW = 0xFFD600;
    
    function initialize(application as CoachroxApp) {
        WatchUi.Scrollable.initialize({
            :scrollable => true
        });
        app = application;
        plan = app.getCurrentPlan();
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header with orange accent
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_SMALL, "Training Plan", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Decorative line
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 26, dc.getWidth() - 40, 2);
        
        if (plan != null) {
            var levelName = "Beginner";
            if (plan.level >= 1) { levelName = "Intermediate"; }
            if (plan.level >= 2) { levelName = "Advanced"; }
            
            // Week and level info - use tiny font
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 38, Graphics.FONT_TINY, "Week " + plan.getWeekNumber() + " of 8 | " + levelName, Graphics.TEXT_JUSTIFY_CENTER);
            
            // Progress bar with colors
            var barWidth = dc.getWidth() - 40;
            var progress = plan.getCompletionRate();
            
            // Bar background
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.fillRectangle(20, 55, barWidth, 8);
            
            // Progress fill with gradient-like color based on progress
            if (progress >= 100) {
                dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
            } else if (progress >= 50) {
                dc.setColor(COLOR_YELLOW, Graphics.COLOR_BLACK);
            } else {
                dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
            }
            dc.fillRectangle(20, 55, (barWidth * progress) / 100, 8);
            
            // Progress text
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 70, Graphics.FONT_TINY, progress + "% Complete", Graphics.TEXT_JUSTIFY_CENTER);
            
            // Separator line
            dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
            dc.fillRectangle(20, 88, dc.getWidth() - 40, 1);
            
            // Sessions header
            dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 98, Graphics.FONT_TINY, "This Week's Workouts:", Graphics.TEXT_JUSTIFY_CENTER);
            
            // Workouts with proper spacing for scrolling
            var y = 118;
            for (var i = 0; i < 5; i++) {
                var workout = plan.getWorkout(i);
                if (workout != null) {
                    var status = workout.isCompleted() ? "[✓]" : "[ ]";
                    
                    // Color code: green for completed, orange for pending
                    if (workout.isCompleted()) {
                        dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
                    } else {
                        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                    }
                    
                    dc.drawText(20, y, Graphics.FONT_TINY, status + " " + workout.name, Graphics.TEXT_JUSTIFY_LEFT);
                    
                    // Duration below workout name - tiny font
                    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                    dc.drawText(20, y + 14, Graphics.FONT_TINY, "    " + workout.durationMinutes + " min", Graphics.TEXT_JUSTIFY_LEFT);
                    
                    y += 32; // Compact spacing for scrollable content
                }
            }
        }
        
        // Scroll hint at bottom
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 18, Graphics.FONT_TINY, "UP/DOWN: Scroll | ESC: Back", Graphics.TEXT_JUSTIFY_CENTER);
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
