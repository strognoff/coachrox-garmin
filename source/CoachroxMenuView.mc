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
        
        menuItems = [
            "Start Workout",
            "View Plan",
            "Progress",
            "Settings"
        ];
    }
    
    function onLayout(dc as Dc) as Void {
    }
    
    function onShow() as Void {
    }
    
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Header - smaller
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 3, Graphics.FONT_TINY, "COACHROX", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Decorative line
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 18, dc.getWidth() - 40, 1);
        
        // Menu items - smaller fonts, more spacing
        var startY = 28;
        var itemHeight = 28;
        
        for (var i = 0; i < menuItems.size(); i++) {
            var y = startY + (i * itemHeight);
            
            if (i == selectedItem) {
                dc.setColor(COLOR_BLUE, Graphics.COLOR_WHITE);
                dc.fillRectangle(3, y, dc.getWidth() - 6, itemHeight - 2);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            }
            
            dc.drawText(dc.getWidth() / 2, y + 5, Graphics.FONT_TINY, menuItems[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Footer
        var plan = app.getCurrentPlan();
        if (plan != null) {
            var weekText = "W" + plan.getWeekNumber() + " | " + plan.getCompletionRate() + "%";
            dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() - 10, Graphics.FONT_TINY, weekText, Graphics.TEXT_JUSTIFY_CENTER);
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
            var view = new WorkoutListView(app);
            var delegate = new WorkoutListDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_VIEW_PLAN) {
            var view = new PlanView(app);
            var delegate = new PlanDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_PROGRESS) {
            var view = new ProgressView(app);
            var delegate = new ProgressDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_SETTINGS) {
            var view = new SettingsView(app);
            var delegate = new SettingsDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        }
    }
}
