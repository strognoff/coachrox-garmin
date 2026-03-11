import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

//! View for listing available workouts
class WorkoutListView extends WatchUi.View {
    
    var app as CoachroxApp;
    var plan as Plan;
    var selectedIndex as Number = 0;
    
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
        
        // Header
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 10, Graphics.FONT_MEDIUM, "Workouts", Graphics.TEXT_JUSTIFY_CENTER);
        
        if (plan != null) {
            var y = 50;
            var workoutCount = 5; // 5 workouts per week
            
            for (var i = 0; i < workoutCount; i++) {
                var workout = plan.getWorkout(i);
                if (workout != null) {
                    // Highlight selected
                    if (i == selectedIndex) {
                        dc.setColor(Graphics.COLOR_BLACK, Graphics.FONT_SMALL);
                        dc.fillRectangle(5, y, dc.getWidth() - 10, 35);
                        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                    } else {
                        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                    }
                    
                    var text = workout.name + " (" + workout.durationMinutes + "m)";
                    if (workout.isCompleted()) {
                        text = "[D] " + text;
                    }
                    dc.drawText(10, y + 5, Graphics.FONT_SMALL, text, Graphics.TEXT_JUSTIFY_LEFT);
                    y += 40;
                }
            }
        }
        
        // Instructions
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 20, Graphics.FONT_TINY, "UP/DOWN: Select | ENTER: Start", Graphics.TEXT_JUSTIFY_CENTER);
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
}
