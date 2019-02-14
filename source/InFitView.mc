using Toybox.WatchUi;
using Toybox.Application as App;

class InFitView extends WatchUi.View {

    var app;
    var labelContent;
    var labelTextColor;
    var statusContent;
    var labelDrawable;
    var statusDrawable;

    function initialize() {
        View.initialize();
        app = App.getApp();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        labelDrawable = findDrawableById("label");
        statusDrawable = findDrawableById("status");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        labelContent = app.getLabelViewContent();
        labelTextColor = app.getLabelTextColor();
        statusContent = app.getStatusViewContent();
        labelDrawable.setText(labelContent);
        labelDrawable.setColor(labelTextColor);
        statusDrawable.setText(statusContent);
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
}
