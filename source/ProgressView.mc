import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

//! View for displaying progress and stats
class ProgressView extends WatchUi.Scrollable {
    
    var app as CoachroxApp;
    var sessionStorage as SessionStorage;
    
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
        sessionStorage = Application.getApp().sessionStorage;
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header with orange accent
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_SMALL, "Progress", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Decorative line
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 26, dc.getWidth() - 40, 2);
        
        var totalSessions = sessionStorage.getSessionCount();
        var weeklyVolume = sessionStorage.getWeeklyVolume();
        
        // All workouts completed message at TOP (in green)
        var plan = app.getCurrentPlan();
        var allCompleted = false;
        if (plan != null) {
            allCompleted = plan.getCompletionRate() >= 100;
        }
        
        if (allCompleted) {
            dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 40, Graphics.FONT_TINY, "All workouts completed!", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Stats with smaller fonts
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 60, Graphics.FONT_TINY, "Total Sessions", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 78, Graphics.FONT_MEDIUM, totalSessions.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Weekly volume
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 105, Graphics.FONT_TINY, "Weekly Volume", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 123, Graphics.FONT_MEDIUM, weeklyVolume + " min", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Adaptation suggestion with color coding
        var adaptation = app.planEngine.getAdaptationSuggestion();
        var suggestionText = "Keep going!";
        var suggestionColor = Graphics.COLOR_WHITE;
        
        if (adaptation < 0) {
            suggestionText = "Consider downshifting";
            suggestionColor = COLOR_YELLOW;
        } else if (adaptation > 0) {
            suggestionText = "Ready to progress!";
            suggestionColor = COLOR_GREEN;
        }
        
        // Separator
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 150, dc.getWidth() - 40, 1);
        
        dc.setColor(suggestionColor, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 165, Graphics.FONT_TINY, suggestionText, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Additional stats - total time
        var totalTime = sessionStorage.getTotalTime();
        if (totalTime > 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 185, Graphics.FONT_TINY, "Total Time", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 203, Graphics.FONT_SMALL, totalTime + " min", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Back hint
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 18, Graphics.FONT_TINY, "UP/DOWN: Scroll | ESC: Back", Graphics.TEXT_JUSTIFY_CENTER);
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
