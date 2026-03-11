import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class CoachroxMenuView extends WatchUi.View {
    
    var app as CoachroxApp;
    
    enum {
        ITEM_START_WORKOUT,
        ITEM_VIEW_PLAN,
        ITEM_PROGRESS,
        ITEM_SETTINGS
    }
    
    var selectedItem as Number = 0;
    var menuItems as Array<String>;
    
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    
    function initialize(application as CoachroxApp) {
        WatchUi.View.initialize();
        app = application;
        
        menuItems = ["Start Workout", "View Plan", "Progress", "Settings"];
    }
    
    function onLayout(dc as Dc) as Void {
    }
    
    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header at top
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(w/2, 2, Graphics.FONT_TINY, "COACHROX", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 16, w - 40, 1);
        
        // Menu items centered vertically
        var itemHeight = 22;
        var totalHeight = menuItems.size() * itemHeight;
        var startY = (h - totalHeight) / 2 - 10;
        
        for (var i = 0; i < menuItems.size(); i++) {
            var y = startY + (i * itemHeight);
            
            if (i == selectedItem) {
                dc.setColor(COLOR_BLUE, Graphics.COLOR_WHITE);
                dc.fillRectangle(5, y, w - 10, itemHeight - 1);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            }
            
            dc.drawText(w/2, y + 3, Graphics.FONT_TINY, menuItems[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Footer at bottom
        var plan = app.getCurrentPlan();
        if (plan != null) {
            var weekText = "W" + plan.getWeekNumber() + " | " + plan.getCompletionRate() + "%";
            dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
            dc.drawText(w/2, h - 12, Graphics.FONT_TINY, weekText, Graphics.TEXT_JUSTIFY_CENTER);
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
            WatchUi.pushView(new WorkoutListView(app), new WorkoutListDelegate(new WorkoutListView(app)), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_VIEW_PLAN) {
            WatchUi.pushView(new PlanView(app), new PlanDelegate(new PlanView(app)), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_PROGRESS) {
            WatchUi.pushView(new ProgressView(app), new ProgressDelegate(new ProgressView(app)), WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_SETTINGS) {
            WatchUi.pushView(new SettingsView(app), new SettingsDelegate(new SettingsView(app)), WatchUi.SLIDE_LEFT);
        }
    }
}
