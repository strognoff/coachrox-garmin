import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

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
        
        // If showing summary, any key exits
        if (session.showSummary) {
            session.finishAndExit();
            return true;
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
            // Complete workout and show summary
            session.complete(true);
            WatchUi.requestUpdate();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ESC) {
            // Exit (mark as incomplete) and show summary
            session.complete(false);
            WatchUi.requestUpdate();
            return true;
        }
        
        return false;
    }
}
