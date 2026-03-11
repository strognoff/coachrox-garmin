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
    
    // Touch handling disabled - SDK 8.x API changed
    // function onTap(event as WatchUi.TapEvent) as Boolean {
    //     view.selectItem();
    //     return true;
    // }
}
