using Toybox.WatchUi;

//! Input delegate for main menu
class CoachroxMenuDelegate extends WatchUi.InputDelegate {
    
    var view as CoachroxMenuView;
    
    function initialize(menuView as CoachroxMenuView) {
        WatchUi.InputDelegate.initialize();
        view = menuView;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        if (key.getKey() == WatchUi.KEY_UP) {
            view.selectPrevious();
            return true;
        } else if (key.getKey() == WatchUi.KEY_DOWN) {
            view.selectNext();
            return true;
        } else if (key.getKey() == WatchUi.KEY_ENTER) {
            view.selectItem();
            return true;
        }
        return false;
    }
    
    function onTap(event as WatchUi.TapEvent) as Boolean {
        var x = event.getX();
        var y = event.getY();
        
        // Simple tap zones
        if (y < 90) {
            view.selectPrevious();
        } else if (y > 130) {
            view.selectNext();
        } else {
            view.selectItem();
        }
        return true;
    }
}
