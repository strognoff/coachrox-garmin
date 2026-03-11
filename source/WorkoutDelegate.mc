using Toybox.WatchUi;
using Toybox.Graphics;

//! Input delegate for active workout
class WorkoutDelegate extends WatchUi.InputDelegate {
    
    var app as CoachroxApp;
    
    function initialize(application as CoachroxApp) {
        WatchUi.InputDelegate.initialize();
        app = application;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        var session = app.currentWorkout;
        
        if (session == null) {
            return false;
        }
        
        if (key.getKey() == WatchUi.KEY_UP) {
            // Skip step
            session.skipStep();
            WatchUi.requestUpdate();
            return true;
        } else if (key.getKey() == WatchUi.KEY_DOWN) {
            // Pause/Resume
            session.togglePause();
            WatchUi.requestUpdate();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ENTER) {
            // Complete workout
            session.complete(true);
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        } else if (key.getKey() == WatchUi.KEY_ESC) {
            // Exit (mark as incomplete)
            session.complete(false);
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        
        return false;
    }
}
