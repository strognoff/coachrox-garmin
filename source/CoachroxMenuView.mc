import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

//! Main menu view for COACHROX app
class CoachroxMenuView extends WatchUi.Scrollable {
    
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
    
    //! Color constants - vibrant palette
    const COLOR_ORANGE = 0xFF6B00;
    const COLOR_BLUE = 0x00A3E0;
    const COLOR_GREEN = 0x00C853;
    const COLOR_YELLOW = 0xFFD600;
    
    function initialize(application as CoachroxApp) {
        WatchUi.Scrollable.initialize({
            :scrollable => true
        });
        app = application;
        
        menuItems = [
            "Start Workout",
            "View Plan",
            "Progress",
            "Settings"
        ];
    }
    
    function onLayout(dc as Dc) as Void {
        // Custom drawn view - no layout needed
    }
    
    function onShow() as Void {
        // Refresh data
    }
    
    function onUpdate(dc as Dc) as Void {
        // Clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Draw header with orange accent
        dc.setColor(COLOR_ORANGE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 8, Graphics.FONT_SMALL, "COACHROX", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Decorative line under header
        dc.setColor(COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.fillRectangle(20, 28, dc.getWidth() - 40, 2);
        
        // Draw menu items
        var startY = 45;
        var itemHeight = 38;
        
        for (var i = 0; i < menuItems.size(); i++) {
            var y = startY + (i * itemHeight);
            
            // Highlight selected with blue accent
            if (i == selectedItem) {
                dc.setColor(COLOR_BLUE, Graphics.COLOR_DK_GRAY);
                dc.fillRectangle(5, y, dc.getWidth() - 10, itemHeight - 3);
                dc.setColor(COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            }
            
            dc.drawText(dc.getWidth() / 2, y + 8, Graphics.FONT_SMALL, menuItems[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw footer with week info - use tiny font
        var plan = app.getCurrentPlan();
        if (plan != null) {
            var completion = plan.getCompletionRate();
            var weekText = "Week " + plan.getWeekNumber() + " | " + completion + "%";
            
            // Color code the completion
            if (completion >= 100) {
                dc.setColor(COLOR_GREEN, Graphics.COLOR_BLACK);
            } else if (completion >= 50) {
                dc.setColor(COLOR_YELLOW, Graphics.COLOR_BLACK);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
            }
            dc.drawText(dc.getWidth() / 2, dc.getHeight() - 18, Graphics.FONT_TINY, weekText, Graphics.TEXT_JUSTIFY_CENTER);
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
            var view = new WorkoutListView(app);
            var delegate = new WorkoutListDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_VIEW_PLAN) {
            // Show plan view
            var view = new PlanView(app);
            var delegate = new PlanDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_PROGRESS) {
            // Show progress view
            var view = new ProgressView(app);
            var delegate = new ProgressDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        } else if (selectedItem == ITEM_SETTINGS) {
            // Show settings view
            var view = new SettingsView(app);
            var delegate = new SettingsDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
        }
    }
}
