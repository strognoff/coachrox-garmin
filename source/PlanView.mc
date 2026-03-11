import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class PlanView extends WatchUi.View {
    
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
        var w = dc.getWidth();
        var h = dc.getHeight();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Use tiny fonts everywhere to fit small round/low-res watches
        var headerFont = Graphics.FONT_TINY;
        var labelFont  = Graphics.FONT_TINY;
        var itemFont   = Graphics.FONT_TINY;

        var headerH = dc.getFontHeight(headerFont);
        var labelH  = dc.getFontHeight(labelFont);
        var itemH   = dc.getFontHeight(itemFont);

        var topPad  = 2;
        var sidePad = 6;
        var gap     = 2;

        // Footer kept minimal
        var footerH = labelH + 2;
        var footerY = h - footerH;

        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, topPad, headerFont, "PLAN", Graphics.TEXT_JUSTIFY_CENTER);

        var y = topPad + headerH + gap;
        var contentBottom = footerY - 1;

        var plan = app.getCurrentPlan();
        if (plan != null) {

            // Week + percent on one line
            var completion = plan.getCompletionRate().toNumber();
            if (completion < 0) { completion = 0; }
            if (completion > 100) { completion = 100; }

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, y, labelFont, "W" + plan.getWeekNumber() + "  " + completion + "%", Graphics.TEXT_JUSTIFY_CENTER);
            y += labelH + gap;

            // Thin progress bar
            var barW = w - (sidePad * 2);
            var barH = 4;
            var barX = sidePad;
            var barY = y;

            var barColor = completion >= 100 ? COLOR_GREEN : (completion >= 50 ? COLOR_YELLOW : COLOR_BLUE);

            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.fillRectangle(barX, barY, barW, barH);
            dc.setColor(barColor, Graphics.COLOR_BLACK);
            dc.fillRectangle(barX, barY, (barW * completion / 100).toNumber(), barH);

            y += barH + (gap + 1);

            // Workout list (as many as fit)
            var workoutNames = ["Intervals 1", "Intervals 2", "Tempo", "Long", "Recovery"];

            var remainingH = contentBottom - y;
            var rowH = itemH + 2;
            var maxRows = (remainingH / rowH).toNumber();
            if (maxRows > workoutNames.size()) { maxRows = workoutNames.size(); }
            if (maxRows < 0) { maxRows = 0; }

            var doneCount = (completion / 20).toNumber();
            if (doneCount > workoutNames.size()) { doneCount = workoutNames.size(); }

            for (var i = 0; i < maxRows; i++) {
                var done = i < doneCount;
                dc.setColor(done ? COLOR_GREEN : Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

                // Compact: "1 Intervals 1"
                dc.drawText(sidePad, y, itemFont, (i + 1) + " " + workoutNames[i], Graphics.TEXT_JUSTIFY_LEFT);
                y += rowH;
            }

        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, y + 4, labelFont, "No plan", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Footer (short)
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, footerY, labelFont, "ESC Back", Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class PlanDelegate extends WatchUi.InputDelegate {
    var view as PlanView;
    
    function initialize(planView as PlanView) {
        WatchUi.InputDelegate.initialize();
        view = planView;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        if (key.getKey() == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
}