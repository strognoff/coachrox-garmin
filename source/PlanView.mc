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

        var headerFont = Graphics.FONT_XTINY;
        var labelFont  = Graphics.FONT_XTINY;

        // Increase ONLY the list font by 1 step
        var itemFont   = Graphics.FONT_TINY;

        var headerH = dc.getFontHeight(headerFont);
        var labelH  = dc.getFontHeight(labelFont);
        var itemH   = dc.getFontHeight(itemFont);

        var sidePad = 8;
        var gap     = 3;
        var topPad  = 4;

        var plan = app.getCurrentPlan();
        if (plan != null) {
            // Workout list config
            var workoutNames = ["Intervals 1", "Intervals 2", "Tempo", "Long", "Recovery"];
            var rowH = itemH + 3;
            var listHeight = rowH * workoutNames.size();

            // Center list on the FULL screen (clamped so header doesn't overlap)
            var listY = (h - listHeight) / 2;

            // Header block height we draw at the top
            var headerBlockH = topPad
                + headerH + gap + 2
                + labelH + gap + 1
                + 3 + gap + 4; // progress bar height (3) + spacing

            // Ensure the list starts below the header block
            if (listY < headerBlockH) { listY = headerBlockH; }
            // Ensure the list doesn't go off the bottom
            if (listY + listHeight > h) { listY = h - listHeight; }
            if (listY < headerBlockH) { listY = headerBlockH; }

            // --- Draw header/progress (kept at top) ---
            var y = topPad;

            dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, y, headerFont, "PLAN", Graphics.TEXT_JUSTIFY_CENTER);
            y += headerH + gap + 2;

            var completion = plan.getCompletionRate().toNumber();
            if (completion < 0) { completion = 0; }
            if (completion > 100) { completion = 100; }

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, y, labelFont, "W" + plan.getWeekNumber() + "  " + completion + "%", Graphics.TEXT_JUSTIFY_CENTER);
            y += labelH + gap + 1;

            var barW = w - (sidePad * 2);
            var barH = 3;
            var barX = sidePad;
            var barY = y;

            var barColor = completion >= 100 ? COLOR_GREEN : (completion >= 50 ? COLOR_YELLOW : COLOR_BLUE);

            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.fillRectangle(barX, barY, barW, barH);
            dc.setColor(barColor, Graphics.COLOR_BLACK);
            dc.fillRectangle(barX, barY, (barW * completion / 100).toNumber(), barH);

            // --- Draw list centered (vertically + horizontally) ---
            y = listY;

            var doneCount = (completion / 20).toNumber();
            if (doneCount > workoutNames.size()) { doneCount = workoutNames.size(); }

            for (var i = 0; i < workoutNames.size(); i++) {
                var done = i < doneCount;
                dc.setColor(done ? COLOR_GREEN : Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

                var line = (i + 1) + " " + workoutNames[i];
                dc.drawText(w / 2, y, itemFont, line, Graphics.TEXT_JUSTIFY_CENTER);
                y += rowH;
            }

        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, h / 2 - labelH / 2, labelFont, "No plan", Graphics.TEXT_JUSTIFY_CENTER);
        }
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