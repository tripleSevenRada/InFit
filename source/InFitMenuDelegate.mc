using Toybox.WatchUi;
using Toybox.System;
using Toybox.Application as App;

class InFitMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        WatchUi.popView( WatchUi.SLIDE_IMMEDIATE );
        var app = App.getApp();
        app.onItemChosen(item);
    }
}