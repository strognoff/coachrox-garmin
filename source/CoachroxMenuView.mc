using Toybox.WatchUi;
using Toybox.Graphics;

//! Main menu view for COACHROX app
class CoachroxMenuView extends WatchUi.View {
    
    var app as CoachroxApp;
    
    //! Menu items
    enum {
        ITEM_START_WORKOUT,
        ITEM_VIEW_PLAN,
        ITEM_PROGRESS,
        ITEM_SETTINGS
    }
    
    var selectedItem as Number = 0;
    var menuItems as Array<String>;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        
        menuItems = [
            "Start Workout",
            "View Plan",
            "Progress",
            "Settings"
        ];
    }
    
    function onLayout(dc as Dc) as Void {
        setLayout(dc);
    }
    
    function onShow() as Void {
        // Refresh data
    }
    
    function onUpdate(dc as Dc) as Void {
        // Clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Draw header
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 10, Graphics.FONT_MEDIUM, "COACHROX", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw menu items
        var startY = 50;
        var itemHeight = 40;
        
        for (var i = 0; i < menuItems.size(); i++) {
            var y = startY + (i * itemHeight);
            
            // Highlight selected
            if (i == selectedItem) {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
                dc.fillRectangle(5, y, dc.getWidth() - 10, itemHeight - 5);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            }
            
            dc.drawText(dc.getWidth() / 2, y + 10, Graphics.FONT_MEDIUM, menuItems[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw footer with week info
        var plan = app.getCurrentPlan();
        if (plan != null) {
            var weekText = "Week " + plan.getWeekNumber() + " | " + plan.getCompletionRate() + "%";
            dc.setColor(Graphics.COLOR_GRAY, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() - 30, Graphics.FONT_SMALL, weekText, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
    
    function selectNext() as Void {
        selectedItem = (selectedItem + 1) % menuItems.size();
        WatchUi.requestUpdate();
    }
    
    function selectPrevious() as Void {
        selectedItem = (selectedItem - 1 + menuItems.size()) % menuItems.size();
        WatchUi.requestUpdate();
    }
    
    function selectItem() as Void {
        if (selectedItem == ITEM_START_WORKOUT) {
            // Show workout list
            WatchUi.pushView(new WorkoutListView(app), new WorkoutListDelegate(app), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_VIEW_PLAN) {
            // Show plan view
            WatchUi.pushView(new PlanView(app), new PlanDelegate(app), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_PROGRESS) {
            // Show progress view
            WatchUi.pushView(new ProgressView(app), new ProgressDelegate(app), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_SETTINGS) {
            // Show settings view
            WatchUi.pushView(new SettingsView(app), new SettingsDelegate(app), WatchUi.SLIDE_LEFT);
        }
    }
}
