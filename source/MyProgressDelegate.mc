using Toybox.WatchUi;
using Toybox.Application as App;

class MyProgressDelegate extends WatchUi.BehaviorDelegate {
    
    var app;
    
    function initialize() {
        BehaviorDelegate.initialize();
        app = App.getApp();
    }

    function onBack() {
        app.onProgressBarBackPress();
        return true;
    }
}