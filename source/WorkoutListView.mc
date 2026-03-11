import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class WorkoutListView extends WatchUi.View {
    
    var app as CoachroxApp;
    var plan as Plan;
    var selectedIndex as Number = 0;
    
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        plan = app.getCurrentPlan();
    }
    
    function onLayout(dc as Dc) as Void {
    }
    
    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 4, Graphics.FONT_TINY, "WORKOUTS", Graphics.TEXT_JUSTIFY_CENTER);
        
        if (plan == null) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(w/2, h/2, Graphics.FONT_TINY, "No plan", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }
        
        // Draw 5 workouts
        var y = 25;
        for (var i = 0; i < 5; i++) {
            var workout = plan.getWorkout(i);
            if (workout != null) {
                var done = workout.completedAt != null;
                
                if (i == selectedIndex) {
                    dc.setColor(COLOR_BLUE, Graphics.COLOR_DK_GRAY);
                    dc.fillRectangle(3, y - 2, w - 6, 20);
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(done ? COLOR_GREEN : Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                }
                
                var name = (i+1) + ". " + workout.name;
                if (done) { name = "[D] " + name; }
                dc.drawText(10, y, Graphics.FONT_TINY, name, Graphics.TEXT_JUSTIFY_LEFT);
                
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
                dc.drawText(w - 10, y, Graphics.FONT_TINY, workout.durationMinutes + "m", Graphics.TEXT_JUSTIFY_RIGHT);
            }
            y += 20;
        }
        
        // Footer
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w/2, h - 8, Graphics.FONT_TINY, "UP/DOWN | ENTER | ESC", Graphics.TEXT_JUSTIFY_CENTER);
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
            if (workout != null && workout.completedAt == null) {
                app.startWorkout(selectedIndex, selectedIndex);
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
