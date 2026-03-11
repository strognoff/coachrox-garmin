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
        
        // Header with orange
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_MEDIUM, "SETTINGS", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Current level
        var currentLevel = app.userLevel;
        var levelName = "Beginner";
        if (currentLevel == 1) { levelName = "Intermediate"; }
        if (currentLevel == 2) { levelName = "Advanced"; }
        
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 38, Graphics.FONT_TINY, "Current: " + levelName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Options
        var y = 60;
        var itemHeight = 28;
        
        for (var i = 0; i < options.size(); i++) {
            if (i == selectedOption) {
                // Gray background with white text
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE);
                dc.fillRectangle(5, y, dc.getWidth() - 10, itemHeight);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            }
            
            dc.drawText(dc.getWidth() / 2, y + 5, Graphics.FONT_SMALL, options[i], Graphics.TEXT_JUSTIFY_CENTER);
            y += itemHeight + 3;
        }
        
        // Instructions
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 15, Graphics.FONT_TINY, "UP/DOWN: Select | ENTER | ESC", Graphics.TEXT_JUSTIFY_CENTER);
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
            storage.clearAll();
            app.completedWeeks = 0;
            app.userLevel = 0;
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
