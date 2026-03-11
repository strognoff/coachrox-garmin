import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class SettingsView extends WatchUi.View {
    
    var app as CoachroxApp;
    var selectedOption as Number = 0;
    
    var options as Array<String>;
    
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        
        options = [
            "Level: Beginner",
            "Level: Intermediate", 
            "Level: Advanced",
            "Reset Progress"
        ];
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();

        // Treat top/bottom as "unsafe" on many round faces
        var safeTop = 10;
        var safeBottom = 26;

        var padX = 12;
        var contentLeft = padX;
        var contentRight = w - padX;
        var contentWidth = contentRight - contentLeft;

        var titleFont = Graphics.FONT_MEDIUM;
        var subFont = Graphics.FONT_TINY;
        var itemFont = Graphics.FONT_SMALL;
        var footerFont = Graphics.FONT_TINY;

        var titleH = dc.getFontHeight(titleFont);
        var subH = dc.getFontHeight(subFont);
        var itemHFont = dc.getFontHeight(itemFont);
        var footerH = dc.getFontHeight(footerFont);

        // Header block
        var titleY = safeTop;
        var subY = titleY + titleH + 2;

        // Footer pinned using actual font height (more conservative)
        var footerPadBottom = 10;
        var footerY = h - safeBottom - footerPadBottom - footerH;

        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, titleY, titleFont, "SETTINGS", Graphics.TEXT_JUSTIFY_CENTER);

        var currentLevel = app.userLevel;
        var levelName = "Beginner";
        if (currentLevel == 1) { levelName = "Intermediate"; }
        if (currentLevel == 2) { levelName = "Advanced"; }

        // Brighter subtitle for readability
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w / 2, subY, subFont, "Current: " + levelName, Graphics.TEXT_JUSTIFY_CENTER);

        // List area between subtitle and footer, respecting safe areas
        var listTop = subY + subH + 10;
        var listBottom = footerY - 12;

        if (listBottom < listTop) {
            listBottom = listTop;
        }

        var available = listBottom - listTop;

        var count = options.size();
        var gap = 5;

        var itemHeight = (available - (gap * (count - 1))) / count;
        if (itemHeight > 32) { itemHeight = 32; }
        if (itemHeight < (itemHFont + 8)) { itemHeight = itemHFont + 8; }

        var listHeight = (itemHeight * count) + (gap * (count - 1));
        var y = listTop + ((available - listHeight) / 2);
        if (y < listTop) { y = listTop; }

        // Options
        for (var i = 0; i < count; i++) {
            if (i == selectedOption) {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE);
                dc.fillRectangle(contentLeft, y, contentWidth, itemHeight);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }

            var textY = y + ((itemHeight - itemHFont) / 2) - 1;
            dc.drawText(w / 2, textY, itemFont, options[i], Graphics.TEXT_JUSTIFY_CENTER);

            y += itemHeight + gap;
        }

        // True end of list (after loop)
        var listEndY = y - gap;

        // Footer only if it won't overlap list AND is fully inside safe area
        if ((footerY >= listEndY + 4) && (footerY + footerH <= h - safeBottom)) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(w / 2, footerY, footerFont, "UP/DOWN: Select | ENTER | ESC", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
    
    function selectNext() as Void {
        selectedOption = (selectedOption + 1) % options.size();
        WatchUi.requestUpdate();
    }
    
    function selectPrevious() as Void {
        selectedOption = (selectedOption - 1 + options.size()) % options.size();
        WatchUi.requestUpdate();
    }
    
    function applySetting() as Void {
        var storage = app.sessionStorage;
        
        if (selectedOption == 0) {
            app.userLevel = 0;
            storage.setValue("userLevel", 0);
        } else if (selectedOption == 1) {
            app.userLevel = 1;
            storage.setValue("userLevel", 1);
        } else if (selectedOption == 2) {
            app.userLevel = 2;
            storage.setValue("userLevel", 2);
        } else if (selectedOption == 3) {
            // Reset overall progress markers
            app.completedWeeks = 0;
            storage.setValue("completedWeeks", 0);

            // Reset per-week completion used by PlanEngine.getPlan() -> Plan.completedSessions -> getCompletionRate()
            for (var week = 0; week < 12; week++) {
                storage.setValue("week_" + week + "_completed", 0);
            }
        }
        
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class SettingsDelegate extends WatchUi.InputDelegate {
    
    var view as SettingsView;
    
    function initialize(sView as SettingsView) {
        WatchUi.InputDelegate.initialize();
        view = sView;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        if (key.getKey() == WatchUi.KEY_UP) {
            view.selectPrevious();
            return true;
        } else if (key.getKey() == WatchUi.KEY_DOWN) {
            view.selectNext();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ENTER) {
            view.applySetting();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
}