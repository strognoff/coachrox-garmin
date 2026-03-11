import Toybox.Lang;
import Toybox.WatchUi;

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
        var y = event.getY();
        var screenHeight = WatchUi.View.getCurrentLayout().getHeight();
        
        // Top third = up, bottom third = down, middle = select
        if (y < screenHeight / 3) {
            view.selectPrevious();
        } else if (y > screenHeight * 2 / 3) {
            view.selectNext();
        } else {
            view.selectItem();
        }
        return true;
    }
}
