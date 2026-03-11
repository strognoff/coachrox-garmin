import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Activity;

//! Main application entry point for COACHROX
class CoachroxApp extends Application.AppBase {

    //! Current workout session
    var currentWorkout as WorkoutSession?;
    
    //! Plan engine instance
    var planEngine as PlanEngine?;
    
    //! Session storage
    var sessionStorage as SessionStorage?;
    
    //! Current user level (Beginner, Intermediate, Advanced)
    var userLevel as Number = 0; // 0=Beginner, 1=Intermediate, 2=Advanced
    
    //! Current plan weeks completed
    var completedWeeks as Number = 0;
    
    function initialize() {
        AppBase.initialize();
        
        // Initialize storage
        sessionStorage = new SessionStorage();
        
        // Initialize plan engine
        planEngine = new PlanEngine(sessionStorage);
        
        // Load user settings
        userLevel = sessionStorage.getValue("userLevel") != null ? sessionStorage.getValue("userLevel") : 0;
        completedWeeks = sessionStorage.getValue("completedWeeks") != null ? sessionStorage.getValue("completedWeeks") : 0;
    }

    function getInitialView() {
        // Return the main menu view with its delegate
        var menuView = new CoachroxMenuView(self);
        return [ menuView, new CoachroxMenuDelegate(menuView) ] as [WatchUi.View, WatchUi.InputDelegate];
    }

    function onStart(state) {
        // App started
    }

    function onStop(state) {
        // App stopped - save state
        if (sessionStorage != null) {
            sessionStorage.setValue("userLevel", userLevel);
            sessionStorage.setValue("completedWeeks", completedWeeks);
        }
    }
    
    //! Get the current training plan
    function getCurrentPlan() as Plan? {
        if (planEngine != null) {
            return planEngine.getPlan(userLevel, completedWeeks);
        }
        return null;
    }
    
    //! Start a workout session
    function startWorkout(workoutId as Number, workoutIndex as Number) as Void {
        var plan = getCurrentPlan();
        if (plan != null) {
            var workout = plan.getWorkout(workoutId);
            if (workout != null) {
                currentWorkout = new WorkoutSession(workout, sessionStorage, workoutIndex);
                WatchUi.pushView(currentWorkout, new WorkoutDelegate(self), WatchUi.SLIDE_LEFT);
            }
        }
    }
    
    //! Complete a workout
    function completeWorkout(success as Boolean) as Void {
        if (currentWorkout != null) {
            currentWorkout.complete(success);
            currentWorkout = null;
            
            // Update weekly stats
            completedWeeks++;
            sessionStorage.setValue("completedWeeks", completedWeeks);
        }
    }
}
