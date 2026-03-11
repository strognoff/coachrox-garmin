using Toybox.WatchUi;
using Toybox.Graphics;

//! View for displaying progress and stats
class ProgressView extends WatchUi.View {
    
    var app as CoachroxApp;
    var sessionStorage as SessionStorage;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        sessionStorage = Application.getApp().sessionStorage;
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 10, Graphics.FONT_MEDIUM, "Progress", Graphics.TEXT_JUSTIFY_CENTER);
        
        var totalSessions = sessionStorage.getSessionCount();
        var weeklyVolume = sessionStorage.getWeeklyVolume();
        
        // Stats
        dc.drawText(dc.getWidth() / 2, 50, Graphics.FONT_SMALL, "Total Sessions", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, 75, Graphics.FONT_LARGE, totalSessions.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.drawText(dc.getWidth() / 2, 110, Graphics.FONT_SMALL, "Weekly Volume", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, 135, Graphics.FONT_LARGE, weeklyVolume + " min", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Adaptation suggestion
        var adaptation = app.planEngine.getAdaptationSuggestion();
        var suggestionText = "Keep going!";
        if (adaptation < 0) {
            suggestionText = "Consider downshifting";
        } else if (adaptation > 0) {
            suggestionText = "Ready to progress!";
        }
        
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 170, Graphics.FONT_SMALL, suggestionText, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Back hint
        dc.setColor(Graphics.COLOR_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 20, Graphics.FONT_TINY, "ESC: Back", Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class ProgressDelegate extends WatchUi.InputDelegate {
    
    var view as ProgressView;
    
    function initialize(pView as ProgressView) {
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
