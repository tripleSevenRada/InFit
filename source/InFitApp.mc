using Toybox.Application;
using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.PersistedContent as Pc;

class InFitApp extends Application.AppBase {

    // https://drive.google.com/open?id=1SZp8NZe27bqRasrfkHgtXxNbRH34V7E0

    hidden var label;
    hidden var status;
    hidden var timer;
    hidden var blockWebRequestsForCourses;
    hidden var courses;
    hidden var progressBar;
    hidden var progressBarRunning = false;

    function getLabelViewContent(){return label;}
    function getStatusViewContent(){return status;}
    
    function initialize() {
        AppBase.initialize();
        label = "";
        status = "";
        timer = new Timer.Timer();
        blockWebRequestsForCourses = false;
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
    function showProgressBar(title){
        if(progressBarRunning == true){return;}
        progressBarRunning = true;
        progressBar = new WatchUi.ProgressBar(
            title,
            null
            );
            Ui.pushView(
                progressBar,
                new MyProgressDelegate(),
                Ui.SLIDE_IMMEDIATE
            );
    }
    function ridProgressBar(){
        if(progressBarRunning == false){return;}
        progressBarRunning = false;
        WatchUi.popView( WatchUi.SLIDE_IMMEDIATE );
    }

    function webRequestForCourses(){
        if (! System.getDeviceSettings().phoneConnected) {
            label = "";
            status = Rez.Strings.waiting_for_bt;
            Ui.requestUpdate();
            showProgressBar(Ui.loadResource(Rez.Strings.waiting_for_bt));
            timer.start(method(:webRequestForCourses), 2000, false);
            return;
        }
        ridProgressBar();
        if (blockWebRequestsForCourses){
            System.println("webRequestForCourses SHORT CIRCUITED by blockWebRequestsForCourses");
            return;
        }
        System.println("webRequestForCourses");
        label = "";
        status = Rez.Strings.loading_courses;
        Ui.requestUpdate();
        blockWebRequestsForCourses = true;
        timer.start(method(:webRequestForCoursesTriger), 1000, false);
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
            blockWebRequestsForCourses = false;
            onConnectionError();
        }
    }
    
    function onReceiveCourses(responseCode, data){
        blockWebRequestsForCourses = false;
        System.println("onReceiveCourses responseCode: " + responseCode);
        if (responseCode == Comm.BLE_CONNECTION_UNAVAILABLE) {
            onBLEConnectionError();
            return;
        }
        if(responseCode == -1001){
            System.println("responseCode == -1001 - https device requirements");
            //TODO https device requirements on a real device, maybe ask to switch off
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
        status = Rez.Strings.start_prompt;
        Ui.requestUpdate();
        Ui.pushView( new InFitMenu(), new InFitMenuDelegate(), Ui.SLIDE_IMMEDIATE );
    }
    
    function getCourses(){ return courses; }
    
    var symbToInt = { :ITEM_0=>0, :ITEM_1=>1, :ITEM_2=>2, :ITEM_3=>3, :ITEM_4=>4, :ITEM_5=>5, :ITEM_6=>6 };
    var fullUrl = null;
    var courseName = null;

    function onItemChosen(item){
        blockWebRequestsForCourses = true;
        System.println("onItemChosen: " + symbToInt[item]);
        status = Rez.Strings.downloading;
        Ui.requestUpdate();
        showProgressBar(Ui.loadResource(Rez.Strings.downloading));
        var courseUrl = courses[symbToInt[item]]["url"];
        courseName = courses[symbToInt[item]]["name"];
        fullUrl = "http://localhost:22333/outfit-data" + courseUrl;
        timer.start(method(:webRequestForCourseDownload), 1000, false);
    }
    
    function webRequestForCourseDownload(){
        if(fullUrl != null){
            System.println("request url " + fullUrl);
            try{
                Comm.makeWebRequest(
                fullUrl,
                null,
                {       :method => Comm.HTTP_REQUEST_METHOD_GET,
                        :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_FIT
                },
                method(:onDownloadFinished)
                );
            }catch(ex){
                onConnectionError();
                return;
            }
        }
    }
    
    function onDownloadFinished(responseCode, data){
    	ridProgressBar();
        if (responseCode == Comm.BLE_CONNECTION_UNAVAILABLE) {
            onBLEConnectionError();
            return;
        }
        else if (responseCode != 200) {
            label = responseCode.toString();
            onConnectionError();
            return;
        }
        else if (data == null) {
            System.println("data == null");
            onConnectionError();
            return;
        }
        else {
            if(courseName == null) {
                // should never happen
                onGenericError();
                return;
            }
            // search for the course in persistent content and make use of it
            status = Rez.Strings.downloaded;
            Ui.requestUpdate();
            var iteratorCourses = Pc.getCourses(); // Get the Iterator
            while(true){
                var courseNow = iteratorCourses.next();
                if(courseNow == null){
                    onPersistedContentError();
                    break;
                } else {
                    System.println("course: " + courseNow.getName());
                }
            }
            
            
            
            
            
            blockWebRequestsForCourses = false;
            
            
            
            
            
            
        }
    }
    function onGenericError(){
        status = Rez.Strings.error;
        Ui.requestUpdate();
    }
    
    function onPersistedContentError(){
        status = Rez.Strings.persisted_content_error;
        Ui.requestUpdate();
    }
    
    function onConnectionError(){
        status = Rez.Strings.connection_error;
        Ui.requestUpdate();
    }
    function onBLEConnectionError(){
        System.println("Bluetooth disconnected");
        status = Rez.Strings.bt_disconnected;
        Ui.requestUpdate();
    }
}
