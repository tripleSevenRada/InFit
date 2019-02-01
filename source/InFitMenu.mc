using Toybox.System;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class InFitMenu extends Ui.Menu{

    var intToSymb = { 0=>:ITEM_0, 1=>:ITEM_1, 2=>:ITEM_2, 3=>:ITEM_3, 4=>:ITEM_4, 5=>:ITEM_5, 6=>:ITEM_6 };

    function initialize() {
        Menu.initialize();
        var app = App.getApp();
        var courses = app.getCourses();
        Menu.setTitle(Rez.Strings.menu_label);
        for( var i = 0; i < courses.size(); i++ ) {
            if(intToSymb[i] != null){
                Menu.addItem(courses[i]["title"], intToSymb[i]);
            }
        }
    }
}