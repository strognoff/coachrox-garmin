import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

//! View for listing available workouts
class WorkoutListView extends WatchUi.View {
    
    var app as CoachroxApp;
    var plan as Plan;
    var selectedIndex as Number = 0;
    
    //! Color constants - vibrant palette
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    const COLOR_YELLOW = 0xFFD600;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        plan = app.getCurrentPlan();
    }
    
    function onLayout(dc as Dc) as Void {
        // Custom drawn view - no layout needed
    }
    
function onUpdate(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();

    var w = dc.getWidth();
    var h = dc.getHeight();
    var leftPad = 8;
    var rightPad = 8;
    var contentW = w - leftPad - rightPad;

    // Header
    dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
    dc.drawText(w / 2, 4, Graphics.FONT_TINY, "Workouts", Graphics.TEXT_JUSTIFY_CENTER);

    if (plan == null) {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, h / 2, Graphics.FONT_TINY, "No plan", Graphics.TEXT_JUSTIFY_CENTER);
        return;
    }

    var workoutCount = 5;

    // Fonts
    var listFont = Graphics.FONT_XTINY;
    var footerFont = Graphics.FONT_TINY;

    var listFontH = dc.getFontHeight(listFont);
    var footerFontH = dc.getFontHeight(footerFont);

    // Layout regions
    var headerH = 18;
    var footerH = footerFontH + 6;

    var listTop = headerH;
    var listBottom = h - footerH;
    var listH = listBottom - listTop;

    // Visible rows around the selected item (odd number works best)
    var visibleRows = 5;
    if (visibleRows > workoutCount) {
        visibleRows = workoutCount;
    }

    var rowH = (listH / visibleRows).toNumber();
    if (rowH < (listFontH + 2)) {
        rowH = listFontH + 2;
    }

    // Start Y so that the selected row is vertically centered in the list area
    var centerY = listTop + (listH / 2).toNumber();
    var selectedRowTop = centerY - (rowH / 2).toNumber();
    var firstRowTop = selectedRowTop - ((visibleRows / 2).toNumber() * rowH);

    var nameX = leftPad + 4;
    var durationX = w - rightPad - 4;

    // Draw rows from -half..+half around selectedIndex
    var half = (visibleRows / 2).toNumber();

    for (var offset = -half; offset <= half; offset++) {
        var i = (selectedIndex + offset + workoutCount) % workoutCount;
        var y = firstRowTop + ((offset + half) * rowH);

        // Skip drawing if outside screen bounds (safety)
        if (y + rowH < listTop || y > listBottom) {
            continue;
        }

        var workout = plan.getWorkout(i);

        // Selected row background
        if (offset == 0) {
            dc.setColor(COLOR_BLUE, Graphics.COLOR_DK_GRAY);
            dc.fillRectangle(leftPad, y, contentW, rowH);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        } else {
            // Dimmer rows for "rolling" feel
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        }

        var textY = y + ((rowH - listFontH) / 2).toNumber();

        if (workout != null) {
            var nameText = workout.name;
            if (workout.isCompleted()) {
                nameText = "[D] " + nameText;
            }
            dc.drawText(nameX, textY, listFont, nameText, Graphics.TEXT_JUSTIFY_LEFT);

            var durText = workout.durationMinutes + "m";
            dc.drawText(durationX, textY, listFont, durText, Graphics.TEXT_JUSTIFY_RIGHT);
        }
    }

    // Instructions at the bottom
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
    dc.drawText(w / 2, h - 10, footerFont, "UP/DOWN | ENTER Start", Graphics.TEXT_JUSTIFY_CENTER);
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
            if (workout != null && !workout.isCompleted()) {
                app.startWorkout(selectedIndex);
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
    
    function onSelect() as Boolean {
        view.startSelected();
        return true;
    }
}