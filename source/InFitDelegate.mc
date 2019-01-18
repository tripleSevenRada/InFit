using Toybox.WatchUi;
using Toybox.Application as App;

class InFitDelegate extends WatchUi.BehaviorDelegate {

	var app;
	
    function initialize() {
        BehaviorDelegate.initialize();
        app = App.getApp();
    }

    function onMenu() {
        //WatchUi.pushView(new Rez.Menus.MainMenu(), new InFitMenuDelegate(), WatchUi.SLIDE_UP);
        app.webRequestForCourses();
        return true;
    }
    
    function onSelect() {
    	//WatchUi.pushView(new Rez.Menus.MainMenu(), new InFitMenuDelegate(), WatchUi.SLIDE_UP);
    	app.webRequestForCourses();
    	return true;
    }
}