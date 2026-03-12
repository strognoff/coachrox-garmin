using Toybox.WatchUi;
using Toybox.Graphics;

//! Settings view for app configuration
class SettingsView extends WatchUi.View {
    
    var app as CoachroxApp;
    var selectedOption as Number = 0;
    
    var options as Array<String>;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        
        options = [
            "Level: Beginner",
            "Level: Intermediate", 
            "Level: Advanced",
            "Start from Phase",
            "Reset Progress"
        ];
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 10, Graphics.FONT_MEDIUM, "Settings", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Current level display
        var currentLevel = app.userLevel;
        var levelName = "Beginner";
        if (currentLevel == 1) { levelName = "Intermediate"; }
        if (currentLevel == 2) { levelName = "Advanced"; }
        
        dc.setColor(Graphics.COLOR_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 40, Graphics.FONT_SMALL, "Current: " + levelName, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Options
        var y = 70;
        for (var i = 0; i < options.size(); i++) {
            if (i == selectedOption) {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
                dc.fillRectangle(5, y, dc.getWidth() - 10, 30);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            }
            
            dc.drawText(dc.getWidth() / 2, y + 5, Graphics.FONT_SMALL, options[i], Graphics.TEXT_JUSTIFY_CENTER);
            y += 35;
        }
        
        // Instructions
        dc.setColor(Graphics.COLOR_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 30, Graphics.FONT_TINY, "UP/DOWN: Select | ENTER: Set", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 15, Graphics.FONT_TINY, "ESC: Back", Graphics.TEXT_JUSTIFY_CENTER);
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
            // Start from Phase - show phase selector
            WatchUi.pushView(new PhaseSelectorView(app), new PhaseSelectorDelegate(app), WatchUi.SLIDE_LEFT);
            return;
        } else if (selectedOption == 4) {
            // Reset progress
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

//! Phase selector view for choosing starting phase
class PhaseSelectorView extends WatchUi.View {
    
    var app as CoachroxApp;
    var selectedPhase as Number = 1; // Default to Phase 1
    const MAX_PHASE = 8; // 8-week plan
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        // Start from current phase or 1
        selectedPhase = app.completedWeeks + 1;
        if (selectedPhase < 1) { selectedPhase = 1; }
        if (selectedPhase > MAX_PHASE) { selectedPhase = MAX_PHASE; }
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 10, Graphics.FONT_MEDIUM, "Start from Phase", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Current phase info
        dc.setColor(Graphics.COLOR_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 40, Graphics.FONT_SMALL, "Current: Week " + (app.completedWeeks + 1), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Selected phase display
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 80, Graphics.FONT_LARGE, "Phase " + selectedPhase, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Instructions
        dc.setColor(Graphics.COLOR_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 120, Graphics.FONT_TINY, "UP/DOWN: Change", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, 140, Graphics.FONT_TINY, "ENTER: Confirm | ESC: Back", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Warning
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 25, Graphics.FONT_TINY, "This will reset all progress!", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function selectNext() as Void {
        if (selectedPhase < MAX_PHASE) {
            selectedPhase++;
            WatchUi.requestUpdate();
        }
    }
    
    function selectPrevious() as Void {
        if (selectedPhase > 1) {
            selectedPhase--;
            WatchUi.requestUpdate();
        }
    }
    
    function confirmSelection() as Void {
        var storage = app.sessionStorage;
        
        // Reset all progress
        storage.clearAll();
        
        // Set the starting phase (week - 1 because completedWeeks is 0-indexed)
        app.completedWeeks = selectedPhase - 1;
        storage.setValue("completedWeeks", app.completedWeeks);
        
        // Pop back to settings
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class PhaseSelectorDelegate extends WatchUi.InputDelegate {
    
    var view as PhaseSelectorView;
    
    function initialize(pView as PhaseSelectorView) {
        WatchUi.InputDelegate.initialize();
        view = pView;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        if (key.getKey() == WatchUi.KEY_UP) {
            view.selectPrevious();
            return true;
        } else if (key.getKey() == WatchUi.KEY_DOWN) {
            view.selectNext();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ENTER) {
            view.confirmSelection();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
}
