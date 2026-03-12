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
        
        // Safer vertical positions for round/bezel screens
        var headerY = 24;       // SETTINGS
        var subHeaderY = 56;    // move "8w | Beginner" down so it doesn't overlap visually
        var helpY = h - 26;
        
        // Header
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, headerY, Graphics.FONT_TINY, "SETTINGS", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Current settings
        var planWeeks = 8;
        var planStored = app.sessionStorage.getValue("planType");
        if (planStored != null && planStored == 12) {
            planWeeks = 12;
        }
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w/2, subHeaderY, Graphics.FONT_TINY, planWeeks + "w | " + getLevelName(app.userLevel), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Options layout
        var itemHeight = 30; // taller so the highlight frames the text
        var itemGap = 6;
        var listHeight = (options.size() * itemHeight) + ((options.size() - 1) * itemGap);
        
        var topY = 74;              // push list down a bit to preserve spacing under subheader
        var bottomY = helpY - 14;
        var available = bottomY - topY;
        
        var y = topY + ((available - listHeight) / 2);
        if (y < topY) { y = topY; }
        
        // Keep inside round safe area horizontally
        var insetX = 24;
        var rowW = w - (insetX * 2);
        
        // Vertically center text inside row
        var textOffsetY = (itemHeight / 2) - 10; // tuned for FONT_TINY on round Garmin screens
        if (textOffsetY < 4) { textOffsetY = 4; }
        
        for (var i = 0; i < options.size(); i++) {
            if (i == selectedOption) {
                // Clear selected state: light fill + dark text
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
                dc.fillRectangle(insetX, y, rowW, itemHeight);
                
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            } else {
                // Dim non-selected to reduce glare / improve contrast with selection
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            }
            
            dc.drawText(w/2, y + textOffsetY, Graphics.FONT_TINY, options[i], Graphics.TEXT_JUSTIFY_CENTER);
            y += itemHeight + itemGap;
        }
        
        // Help text: smaller font so it fits on round/bezel screens
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(w/2, helpY, Graphics.FONT_XTINY, "UP/DOWN | ENTER | ESC", Graphics.TEXT_JUSTIFY_CENTER);
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
            var currentPlan = storage.getValue("planType");
            if (currentPlan != null && currentPlan == 12) {
                storage.setValue("planType", 8);
            } else {
                storage.setValue("planType", 12);
            }
            storage.setValue("completedWeeks", 0);
            app.completedWeeks = 0;
        } else if (selectedOption == 1) {
            var newLevel = (app.userLevel + 1) % 3;
            storage.setValue("userLevel", newLevel);
            storage.setValue("completedWeeks", 0);
            app.userLevel = newLevel;
            app.completedWeeks = 0;
        } else if (selectedOption == 2) {
            // Reset all workout completion history
            var maxWeeks = 12; // Cover both 8-week and 12-week plans
            var maxSessions = 5; // Maximum sessions per week
            
            // Clear individual workout completion keys
            for (var week = 0; week < maxWeeks; week++) {
                for (var session = 0; session < maxSessions; session++) {
                    var key = "w" + week + "s" + session;
                    storage.setValue(key, 0);
                }
                // Clear weekly completion counter (THIS IS THE KEY!)
                storage.setValue("week_" + week + "_completed", 0);
                // Clear weekly adherence tracking
                storage.setValue("week_" + week + "_adherence", 0);
            }
            
            // Reset all user progress values
            storage.setValue("userLevel", 0);
            storage.setValue("planType", 8);
            storage.setValue("completedWeeks", 0);
            storage.setValue("adapt_success", 0);
            storage.setValue("adapt_fail", 0);
            storage.setValue("progression_suggested", 0);
            storage.setValue("prev_week_load", 0);
            
            // Reset app state
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