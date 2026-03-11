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
        var w = dc.getWidth();
        var h = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 4, Graphics.FONT_TINY, "SETTINGS", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Current level
        var levelName = "Beginner";
        if (app.userLevel == 1) { levelName = "Intermediate"; }
        if (app.userLevel == 2) { levelName = "Advanced"; }
        
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 22, Graphics.FONT_TINY, "Current: " + levelName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Options
        var y = 45;
        var itemHeight = 22;
        
        for (var i = 0; i < options.size(); i++) {
            if (i == selectedOption) {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE);
                dc.fillRectangle(5, y, w - 10, itemHeight);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            }
            
            dc.drawText(w/2, y + 3, Graphics.FONT_TINY, options[i], Graphics.TEXT_JUSTIFY_CENTER);
            y += itemHeight + 2;
        }
        
        // Help text
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w/2, h - 8, Graphics.FONT_TINY, "UP/DOWN | ENTER | ESC", Graphics.TEXT_JUSTIFY_CENTER);
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
            // Beginner - reset progress too
            storage.setValue("userLevel", 0);
            storage.setValue("completedWeeks", 0);
            app.userLevel = 0;
            app.completedWeeks = 0;
        } else if (selectedOption == 1) {
            // Intermediate - reset progress
            storage.setValue("userLevel", 1);
            storage.setValue("completedWeeks", 0);
            app.userLevel = 1;
            app.completedWeeks = 0;
        } else if (selectedOption == 2) {
            // Advanced - reset progress
            storage.setValue("userLevel", 2);
            storage.setValue("completedWeeks", 0);
            app.userLevel = 2;
            app.completedWeeks = 0;
        } else if (selectedOption == 3) {
            // Reset everything
            storage.setValue("userLevel", 0);
            storage.setValue("completedWeeks", 0);
            app.userLevel = 0;
            app.completedWeeks = 0;
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
