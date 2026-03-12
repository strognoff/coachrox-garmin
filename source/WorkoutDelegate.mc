using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;

//! Input delegate for active workout
class WorkoutDelegate extends WatchUi.InputDelegate {
    
    var app as CoachroxApp;
    var lastEscTime as Number = 0;
    
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
            // Skip step forward
            session.skipStep();
            WatchUi.requestUpdate();
            return true;
        } else if (key.getKey() == WatchUi.KEY_DOWN) {
            // Pause/Resume
            session.togglePause();
            WatchUi.requestUpdate();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ESC) {
            // Go to previous step (backward navigation)
            // If pressed again within 2 seconds, exit workout
            var currentTime = Time.now().value();
            if (currentTime - lastEscTime < 2) {
                // Exit workout (mark as incomplete)
                session.complete(false);
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
            } else {
                session.previousStep();
                WatchUi.requestUpdate();
            }
            lastEscTime = currentTime;
            return true;
        } else if (key.getKey() == WatchUi.KEY_ENTER) {
            // Complete workout
            session.complete(true);
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        
        return false;
    }
}
