using Toybox.Application;
using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;

class InFitApp extends Application.AppBase {

    hidden var label;
    hidden var status;
    hidden var bluetoothTimer;
    hidden var blockWebAsyncCall;
    hidden var courses;
    hidden var progressBar;
    hidden var progressBarRunning = false;

    function getLabelViewContent(){return label;}
    function getStatusViewContent(){return status;}
    
    function initialize() {
        AppBase.initialize();
        label = "";
        status = "";
        bluetoothTimer = new Timer.Timer();
        blockWebAsyncCall = false;
        courses = null;
    }

    // onStart() is called on application start up
    function onStart(state) {
        label = Rez.Strings.app_name;
        status = Rez.Strings.start_prompt;
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new InFitView(), new InFitDelegate() ];
    }

    function onProgressBarBackPress(){progressBarRunning = false;}
    function ridProgressBar(){
         progressBarRunning = false;
         WatchUi.popView( WatchUi.SLIDE_UP );
    }

    function webRequestForCourses(){
        if (! System.getDeviceSettings().phoneConnected) {
            bluetoothTimer.stop();
            label = "";
            status = Rez.Strings.waiting_for_bt;
            Ui.requestUpdate();
            if(!progressBarRunning){
                progressBar = new WatchUi.ProgressBar(
                    Ui.loadResource(Rez.Strings.waiting_for_bt),
                    null
                );
                Ui.pushView(
                    progressBar,
                    new MyProgressDelegate(),
                    Ui.SLIDE_DOWN
                );
                progressBarRunning = true;
            }
            bluetoothTimer.start(method(:webRequestForCourses), 2600, false);
            return;
        }
        if(progressBarRunning){ridProgressBar();}
        if (blockWebAsyncCall){
            System.println("webRequestForCourses SHORT CIRCUITED by blockWebAsyncCall");
            return;
        }
        System.println("webRequestForCourses");
        label = "";
        status = Rez.Strings.loading_courses;
        Ui.requestUpdate();
        blockWebAsyncCall = true;
        var myTimer = new Timer.Timer();
        myTimer.start(method(:webRequestForCoursesTriger), 800, false);
    }
    
    function webRequestForCoursesTriger(){
        try{
            Comm.makeWebRequest(
            "http://localhost:22333/outfit-dir.json",
            null,
            {       :method => Comm.HTTP_REQUEST_METHOD_GET,
                    :headers => {"Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON},
                    :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
            },
            method(:onReceiveCourses)
            );
        }catch(ex){
            blockWebAsyncCall = false;
            onConnectionError();
        }
    }
    
    function onReceiveCourses(responseCode, data){
        blockWebAsyncCall = false;
        System.println("onReceiveCourses responseCode: " + responseCode);
        if (responseCode == Comm.BLE_CONNECTION_UNAVAILABLE) {
            System.println("Bluetooth disconnected");
            status = Rez.Strings.bt_disconnected;
            Ui.requestUpdate();
            return;
        }
        if(responseCode == 1001){
            System.println("responseCode == 1001 - https device requirements");
            //TODO
            //TODO
            label = responseCode.toString();
            onConnectionError();
            return;
        }
        if(responseCode != 200){
            label = responseCode.toString();
            onConnectionError();
            return;
        }
        if (!(data instanceof Toybox.Lang.Dictionary)) {
            System.println("data is not Dict");
            onConnectionError();
            return;
        }

        if (!data.hasKey("courses")) {
            System.println("data has no courses key");
            onConnectionError();
            return;
        }

        courses = data["courses"];
        
        if (courses == null) {
            System.println("courses == null");
            onConnectionError();
            return;
        }

        if (!(courses instanceof Toybox.Lang.Array)) {
            System.println("courses != Array");
            courses = null;
            onConnectionError();
            return;
        }
        
        System.println(courses.toString());
        status = Rez.Strings.lorem_ipsum;
        Ui.requestUpdate();
        
    }
    
    function onConnectionError(){
        status = Rez.Strings.connection_error;
        Ui.requestUpdate();
    }
}
