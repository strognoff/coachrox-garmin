import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class ProgressView extends WatchUi.View {
    
    var app as CoachroxApp;
    
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    const COLOR_YELLOW = 0xFFD600;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
    }
    
    function onLayout(dc as Dc) as Void {
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_MEDIUM, "PROGRESS", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Get completion
        var plan = app.getCurrentPlan();
        var completion = plan != null ? plan.getCompletionRate().toNumber() : 0;
        
        // Success message at top
        if (completion >= 100) {
            dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 40, Graphics.FONT_TINY, "ALL COMPLETED!", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Progress bar (full width)
        var barColor = completion >= 100 ? COLOR_GREEN : (completion >= 50 ? COLOR_YELLOW : COLOR_BLUE);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(15, 55, dc.getWidth() - 30, 12);
        dc.setColor(barColor, Graphics.COLOR_BLACK);
        dc.fillRectangle(15, 55, (dc.getWidth() - 30) * completion / 100, 12);
        
        // Percentage
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 72, Graphics.FONT_TINY, completion + "%", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Stats section - simple 2 columns
        var y = 100;
        
        // Workouts done
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(20, y, Graphics.FONT_SMALL, "Done:", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() - 20, y, Graphics.FONT_SMALL, "" + app.completedWeeks, Graphics.TEXT_JUSTIFY_RIGHT);
        
        // Level
        var levelName = "Beginner";
        if (app.userLevel == 1) { levelName = "Intermed"; }
        else if (app.userLevel == 2) { levelName = "Advanced"; }
        
        y += 25;
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(20, y, Graphics.FONT_SMALL, "Level:", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() - 20, y, Graphics.FONT_SMALL, levelName, Graphics.TEXT_JUSTIFY_RIGHT);
        
        // Suggestion
        y += 35;
        var suggestionText = "Keep training!";
        var suggestionColor = Graphics.COLOR_WHITE;
        
        if (completion >= 100) {
            suggestionText = "Level up!";
            suggestionColor = COLOR_GREEN;
        } else if (completion < 30) {
            suggestionText = "Easy does it";
            suggestionColor = COLOR_YELLOW;
        }
        
        dc.setColor(suggestionColor, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, y, Graphics.FONT_SMALL, suggestionText, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Footer
        y = dc.getHeight() - 15;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, y, Graphics.FONT_TINY, "ESC to go back", Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class ProgressDelegate extends WatchUi.InputDelegate {
    var view as ProgressView;
    
    function initialize(progressView as ProgressView) {
        WatchUi.InputDelegate.initialize();
        view = progressView;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        if (key.getKey() == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
}
