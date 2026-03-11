import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class SettingsView extends WatchUi.View {
    
    var app as CoachroxApp;
    var selectedOption as Number = 0;
    
    var options as Array<String> = ["Level: Beginner", "Level: Intermediate", "Level: Advanced", "Reset Progress"];
    
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        
        updateOptions();
    }
    
    function updateOptions() as Void {
        var planWeeks = 8;
        var planStored = app.sessionStorage.getValue("planType");
        if (planStored != null && planStored == 12) {
            planWeeks = 12;
        }
        
        options = [
            "Plan: " + planWeeks + " Week",
            "Level: " + getLevelName(app.userLevel),
            "Reset Progress"
        ];
    }
    
    function getLevelName(level as Number) as String {
        if (level == 0) { return "Beginner"; }
        else if (level == 1) { return "Intermediate"; }
        else { return "Advanced"; }
    }
    
    function onUpdate(dc as Dc) as Void {
        updateOptions();
        
        var w = dc.getWidth();
        var h = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 4, Graphics.FONT_TINY, "SETTINGS", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Current settings
        var planWeeks = 8;
        var planStored = app.sessionStorage.getValue("planType");
        if (planStored != null && planStored == 12) {
            planWeeks = 12;
        }
        
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 22, Graphics.FONT_TINY, planWeeks + "w | " + getLevelName(app.userLevel), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Options
        var y = 45;
        var itemHeight = 25;
        
        for (var i = 0; i < options.size(); i++) {
            if (i == selectedOption) {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE);
                dc.fillRectangle(5, y, w - 10, itemHeight);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
            }
            
            dc.drawText(w/2, y + 4, Graphics.FONT_TINY, options[i], Graphics.TEXT_JUSTIFY_CENTER);
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
            // Toggle plan type
            var currentPlan = storage.getValue("planType");
            if (currentPlan != null && currentPlan == 12) {
                storage.setValue("planType", 8);
            } else {
                storage.setValue("planType", 12);
            }
            // Reset progress when changing plan
            storage.setValue("completedWeeks", 0);
            app.completedWeeks = 0;
        } else if (selectedOption == 1) {
            // Cycle through levels
            var newLevel = (app.userLevel + 1) % 3;
            storage.setValue("userLevel", newLevel);
            storage.setValue("completedWeeks", 0);
            app.userLevel = newLevel;
            app.completedWeeks = 0;
        } else if (selectedOption == 2) {
            // Reset everything
            storage.setValue("userLevel", 0);
            storage.setValue("planType", 8);
            storage.setValue("completedWeeks", 0);
            storage.setValue("adapt_success", 0);
            storage.setValue("adapt_fail", 0);
            app.userLevel = 0;
            app.completedWeeks = 0;
        }
        
        WatchUi.requestUpdate();
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
