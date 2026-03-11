import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

//! View for listing available workouts
class WorkoutListView extends WatchUi.View {
    
    var app as CoachroxApp;
    var plan as Plan;
    var selectedIndex as Number = 0;
    
    //! Color constants - vibrant palette
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    const COLOR_YELLOW = 0xFFD600;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        plan = app.getCurrentPlan();
    }
    
    function onLayout(dc as Dc) as Void {
        // Custom drawn view - no layout needed
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header with orange accent
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_SMALL, "Workouts", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Decorative line
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 26, dc.getWidth() - 40, 2);
        
        if (plan != null) {
            var y = 45;
            var workoutCount = 5; // 5 workouts per week
            
            for (var i = 0; i < workoutCount; i++) {
                var workout = plan.getWorkout(i);
                if (workout != null) {
                    // Highlight selected with blue accent
                    if (i == selectedIndex) {
                        dc.setColor(COLOR_BLUE, Graphics.COLOR_DK_GRAY);
                        dc.fillRectangle(5, y, dc.getWidth() - 10, 32);
                        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                    } else {
                        // Color code: green if completed, white otherwise
                        if (workout.isCompleted()) {
                            dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
                        } else {
                            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                        }
                    }
                    
                    var text = workout.name + " (" + workout.durationMinutes + "m)";
                    if (workout.isCompleted()) {
                        text = "[D] " + text;
                    }
                    dc.drawText(10, y + 4, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_LEFT);
                    y += 35;
                }
            }
        }
        
        // Instructions - use tiny font
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 18, Graphics.FONT_TINY, "UP/DOWN: Select | ENTER: Start", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function selectNext() as Void {
        selectedIndex = (selectedIndex + 1) % 5;
        WatchUi.requestUpdate();
    }
    
    function selectPrevious() as Void {
        selectedIndex = (selectedIndex - 1 + 5) % 5;
        WatchUi.requestUpdate();
    }
    
    function startSelected() as Void {
        if (plan != null) {
            var workout = plan.getWorkout(selectedIndex);
            if (workout != null && !workout.isCompleted()) {
                app.startWorkout(selectedIndex);
            }
        }
    }
}

class WorkoutListDelegate extends WatchUi.InputDelegate {
    
    var view as WorkoutListView;
    
    function initialize(wView as WorkoutListView) {
        WatchUi.InputDelegate.initialize();
        view = wView;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        if (key.getKey() == WatchUi.KEY_UP) {
            view.selectPrevious();
            return true;
        } else if (key.getKey() == WatchUi.KEY_DOWN) {
            view.selectNext();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ENTER) {
            view.startSelected();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
    
    function onSelect() as Boolean {
        view.startSelected();
        return true;
    }
}
