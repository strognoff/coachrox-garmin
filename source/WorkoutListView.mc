import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class WorkoutListView extends WatchUi.View {
    
    var app as CoachroxApp;
    var plan as Plan;
    var selectedIndex as Number = 0;
    
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;

    // Conservative average width for FONT_TINY on Garmin devices (px/char)
    // Used because some device profiles don’t expose text measurement APIs.
    const AVG_TINY_CHAR_PX = 6;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        plan = app.getCurrentPlan();
    }
    
    function onLayout(dc as Dc) as Void {
    }

    function _truncateByWidthEstimate(text as String, maxPx as Number) as String {
        if (maxPx <= 0) { return ""; }

        var maxChars = (maxPx / AVG_TINY_CHAR_PX).toNumber();
        if (maxChars <= 0) { return ""; }

        if (text.length() <= maxChars) {
            return text;
        }

        if (maxChars <= 3) {
            return "...";
        }

        return text.substring(0, maxChars - 3) + "...";
    }
    
    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        var marginX = 10;
        var headerY = 6;

        var rowH = 24; // slightly taller to match FONT_TINY on round devices
        var highlightInsetX = 6;
        var highlightInsetY = 2;

        // Footer positioning for round screens (bring it up)
        var footerH = 14;
        var footerBottomPad = 34;
        var footerY = h - footerBottomPad;

        // Center the 5-row list between header and footer
        var headerBlockH = 24;
        var listAreaTop = headerY + headerBlockH;
        var listAreaBottom = footerY - footerH;
        var listAreaH = listAreaBottom - listAreaTop;

        var listH = (5 * rowH);
        var listTopY = listAreaTop + ((listAreaH - listH) / 2);

        if (listTopY < listAreaTop) { listTopY = listAreaTop; }
        if (listTopY + listH > listAreaBottom) { listTopY = listAreaBottom - listH; }

        // Reserve a fixed column for duration on the right to prevent overlapping text
        var durationColW = 46;
        var durationRightX = w - marginX;

        // Name text area ends before duration column (with a gap)
        var gapBetweenCols = 10;
        var nameLeftX = marginX;
        var nameRightX = durationRightX - durationColW - gapBetweenCols;
        if (nameRightX < nameLeftX + 20) {
            nameRightX = nameLeftX + 20;
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, headerY, Graphics.FONT_TINY, "WORKOUTS", Graphics.TEXT_JUSTIFY_CENTER);

        if (plan == null) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(w/2, h/2, Graphics.FONT_TINY, "No plan", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        // Draw 5 workouts
        for (var i = 0; i < 5; i++) {
            var workout = plan.getWorkout(i);
            if (workout != null) {
                var done = workout.completedAt != null;

                // Row box
                var rowTop = listTopY + (i * rowH);
                var rowBottom = rowTop + rowH;

                // Text baseline inside row (tuned for FONT_TINY)
                var textY = rowTop + 5;

                // Highlight row (use row box, not text baseline)
                if (i == selectedIndex) {
                    dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
                    dc.fillRectangle(
                        highlightInsetX,
                        rowTop + highlightInsetY,
                        w - (highlightInsetX * 2),
                        rowH - (highlightInsetY * 2)
                    );
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(done ? COLOR_GREEN : Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                }

                // Left column: workout name (truncate so it can't collide with duration)
                var baseName = (i+1) + ". " + workout.name;
                if (done) { baseName = "[D] " + baseName; }

                var namePx = nameRightX - nameLeftX;
                var displayName = _truncateByWidthEstimate(baseName, namePx);
                dc.drawText(nameLeftX, textY, Graphics.FONT_TINY, displayName, Graphics.TEXT_JUSTIFY_LEFT);

                // Right column: duration
                dc.setColor((i == selectedIndex) ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(durationRightX, textY, Graphics.FONT_TINY, workout.durationMinutes + "m", Graphics.TEXT_JUSTIFY_RIGHT);
            }
        }

        // Footer
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w/2, footerY, Graphics.FONT_TINY, "UP/DOWN | ENTER | ESC", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function selectNext() as Void {
        selectedIndex = (selectedIndex + 1) % 5;
        WatchUi.requestUpdate();
    }
    
    function selectPrevious() as Void {
        selectedIndex = (selectedIndex - 1 + 5) % 5;
        WatchUi.requestUpdate();
    }
    
    function startSelected() as Void {
        if (plan != null) {
            var workout = plan.getWorkout(selectedIndex);
            if (workout != null && workout.completedAt == null) {
                app.startWorkout(selectedIndex, selectedIndex);
            }
        }
    }
}

class WorkoutListDelegate extends WatchUi.InputDelegate {
    
    var view as WorkoutListView;
    
    function initialize(wView as WorkoutListView) {
        WatchUi.InputDelegate.initialize();
        view = wView;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        if (key.getKey() == WatchUi.KEY_UP) {
            view.selectPrevious();
            return true;
        } else if (key.getKey() == WatchUi.KEY_DOWN) {
            view.selectNext();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ENTER) {
            view.startSelected();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
}