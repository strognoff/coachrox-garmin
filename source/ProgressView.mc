import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

module Progress {

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
    
    var width = dc.getWidth();
    var height = dc.getHeight();
    
    // Calculate vertical spacing based on screen height
    var lineHeight = height / 10; // Divide screen into sections
    var y = lineHeight / 2;
    
    // Header
    dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
    dc.drawText(width / 2, y, Graphics.FONT_SMALL, "PROGRESS", Graphics.TEXT_JUSTIFY_CENTER);
    y += lineHeight;
    
    // Get completion
    var plan = app.getCurrentPlan();
    var completion = plan != null ? plan.getCompletionRate().toNumber() : 0;
    
    // Success message at top
    if (completion >= 100) {
        dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.drawText(width / 2, y, Graphics.FONT_XTINY, "ALL COMPLETED!", Graphics.TEXT_JUSTIFY_CENTER);
        y += lineHeight * 0.7;
    }
    
    // Progress bar (full width)
    // Match PlanView thickness (thinner than previous 10px)
    var barHeight = 6;
    var barColor = completion >= 100 ? COLOR_GREEN : (completion >= 50 ? COLOR_YELLOW : COLOR_BLUE);
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
    dc.fillRectangle(15, y, width - 30, barHeight);
    dc.setColor(barColor, Graphics.COLOR_BLACK);
    dc.fillRectangle(15, y, (width - 30) * completion / 100, barHeight);
    y += lineHeight * 0.6;
    
    // Percentage (1x bigger font)
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.drawText(width / 2, y, Graphics.FONT_TINY, completion + "%", Graphics.TEXT_JUSTIFY_CENTER);
    y += lineHeight;
    
    // Stats section - simple 2 columns
    // Workouts done
    dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
    dc.drawText(20, y, Graphics.FONT_XTINY, "Done:", Graphics.TEXT_JUSTIFY_LEFT);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.drawText(width - 20, y, Graphics.FONT_TINY, "" + app.completedWeeks, Graphics.TEXT_JUSTIFY_RIGHT);
    y += lineHeight * 0.8;
    
    // Level
    var levelName = "Beginner";
    if (app.userLevel == 1) { levelName = "Intermed"; }
    else if (app.userLevel == 2) { levelName = "Advanced"; }
    
    dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
    dc.drawText(20, y, Graphics.FONT_XTINY, "Level:", Graphics.TEXT_JUSTIFY_LEFT);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.drawText(width - 20, y, Graphics.FONT_XTINY, levelName, Graphics.TEXT_JUSTIFY_RIGHT);
    y += lineHeight * 1.2;
    
    // Suggestion
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
    dc.drawText(width / 2, y, Graphics.FONT_TINY, suggestionText, Graphics.TEXT_JUSTIFY_CENTER);
    
    // Footer
    y = height - lineHeight;
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
    dc.drawText(width / 2, y, Graphics.FONT_XTINY, "ESC to go back", Graphics.TEXT_JUSTIFY_CENTER);
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

}