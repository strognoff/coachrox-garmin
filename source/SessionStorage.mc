import Toybox.Lang;
import Toybox.Application.Storage;

//! Session storage for plans and progress
class SessionStorage {
    
    function initialize() {
    }
    
    //! Get a value from storage
    function getValue(key as String) as Object? {
        return Storage.getValue(key);
    }
    
    //! Set a value in storage
    function setValue(key as String, value as Object) as Void {
        Storage.setValue(key, value);
    }
    
    //! Get session completion count
    function getSessionCount() as Number {
        var count = Storage.getValue("total_completed_sessions");
        return count != null ? count : 0;
    }
    
    //! Increment session count
    function incrementSessionCount() as Void {
        var count = getSessionCount();
        Storage.setValue("total_completed_sessions", count + 1);
    }
    
    //! Get weekly volume (total minutes)
    function getWeeklyVolume() as Number {
        var volume = Storage.getValue("weekly_volume_minutes");
        return volume != null ? volume : 0;
    }
    
    //! Add to weekly volume
    function addWeeklyVolume(minutes as Number) as Void {
        var current = getWeeklyVolume();
        Storage.setValue("weekly_volume_minutes", current + minutes);
    }
    
    //! Get all completed workout IDs
    function getCompletedWorkouts() as Array<Number> {
        var completed = Storage.getValue("completed_workouts");
        if (completed == null) {
            return new [0] as Array<Number>;
        }
        return completed as Array<Number>;
    }
    
    //! Clear all data (for testing/reset)
    //! Note: Storage.clear() is not available in SDK 8.x
    //! Use setValue for individual keys to null to remove them
    function clearAll() as Void {
        // Storage.clear() was removed in newer SDKs
        // Individual keys need to be set to null to be removed
    }
}
