import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class ProgressView extends WatchUi.View {
    
    var app as CoachroxApp;
    var sessionStorage as SessionStorage?;
    
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    const COLOR_YELLOW = 0xFFD600;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        sessionStorage = app.sessionStorage;
    }
    
    function onLayout(dc as Dc) as Void {
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 5, Graphics.FONT_SMALL, "PROGRESS", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Completion rate
        var plan = app.getCurrentPlan();
        var completion = 0;
        if (plan != null) {
            completion = plan.getCompletionRate().toNumber();
        }
        
        // Completion message at top
        if (completion >= 100) {
            dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, 30, Graphics.FONT_SMALL, "All workouts completed!", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Progress bar
        var barColor = completion >= 100 ? COLOR_GREEN : (completion >= 50 ? COLOR_YELLOW : COLOR_BLUE);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 50, dc.getWidth() - 40, 10);
        dc.setColor(barColor, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 50, (dc.getWidth() - 40) * completion / 100, 10);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 65, Graphics.FONT_TINY, completion + "% Complete", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Stats
        var startY = 90;
        
        // Workouts completed
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(20, startY, Graphics.FONT_SMALL, "Workouts:", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() - 20, startY, Graphics.FONT_SMALL, "" + app.completedWeeks, Graphics.TEXT_JUSTIFY_RIGHT);
        
        // Level
        var levelName = "Beginner";
        if (app.userLevel == 1) { levelName = "Intermediate"; }
        else if (app.userLevel == 2) { levelName = "Advanced"; }
        
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(20, startY + 20, Graphics.FONT_SMALL, "Level:", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() - 20, startY + 20, Graphics.FONT_SMALL, levelName, Graphics.TEXT_JUSTIFY_RIGHT);
        
        // Adaptation suggestion
        var adaptation = completion - 50;
        var suggestionText = "Keep going!";
        var suggestionColor = Graphics.COLOR_WHITE;
        
        if (completion >= 100) {
            suggestionText = "Ready to progress!";
            suggestionColor = COLOR_GREEN;
        } else if (completion < 30) {
            suggestionText = "Start with easier workouts";
            suggestionColor = COLOR_YELLOW;
        }
        
        // Separator
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 140, dc.getWidth() - 40, 1);
        
        dc.setColor(suggestionColor, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 155, Graphics.FONT_SMALL, suggestionText, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Footer
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 12, Graphics.FONT_TINY, "ESC: Back", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function selectItem() as Void {
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
    
    function onSelect() as Boolean {
        view.selectItem();
        return true;
    }
}
