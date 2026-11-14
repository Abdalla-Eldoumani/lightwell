import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class LightwellDelegate extends WatchUi.BehaviorDelegate {

    private var _view as LightwellView;
    private var _model as LightwellModel;

    function initialize(view as LightwellView, model as LightwellModel) {
        BehaviorDelegate.initialize();
        _view = view;
        _model = model;
    }

    // DOWN or swipe up
    function onNextPage() as Boolean {
        _view.turn(1);
        return true;
    }

    // UP or swipe down
    function onPreviousPage() as Boolean {
        _view.turn(-1);
        return true;
    }

    // On the drinks page a tap on the left adds a coffee, on the right a water.
    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        if (_view.page() != 2) {
            return false;
        }
        if (clickEvent.getCoordinates()[0] < System.getDeviceSettings().screenWidth / 2) {
            _model.addCup(1);
        } else {
            _model.addGlass(1);
        }
        WatchUi.requestUpdate();
        return true;
    }

    // START steps the demo light level, or opens the log on the drinks page; hold UP opens the settings.
    function onSelect() as Boolean {
        if (_view.page() == 2) {
            var log = new WatchUi.Menu2({ :title => "Log a drink" });
            log.addItem(new WatchUi.MenuItem("Coffee", "Add one", :coffee, null));
            log.addItem(new WatchUi.MenuItem("Water", "Add one", :water, null));
            log.addItem(new WatchUi.MenuItem("Coffee", "Take one off", :lessCoffee, null));
            log.addItem(new WatchUi.MenuItem("Water", "Take one off", :lessWater, null));
            WatchUi.pushView(log, new SettingsDelegate(_model), WatchUi.SLIDE_LEFT);
            return true;
        }
        _model.cycleDemo();
        WatchUi.requestUpdate();
        return true;
    }

    function onMenu() as Boolean {
        var menu = new WatchUi.Menu2({ :title => "Settings" });
        menu.addItem(new WatchUi.MenuItem("Daily goal", SettingsDelegate.label(:goal), :goal, null));
        menu.addItem(new WatchUi.MenuItem("Wording", SettingsDelegate.label(:words), :words, null));
        menu.addItem(new WatchUi.MenuItem("Nudges", SettingsDelegate.label(:buzz), :buzz, null));
        menu.addItem(new WatchUi.MenuItem("Last coffee", SettingsDelegate.label(:cutoff), :cutoff, null));
        menu.addItem(new WatchUi.MenuItem("Water goal", SettingsDelegate.label(:h2o), :h2o, null));
        menu.addItem(new WatchUi.MenuItem("Stress nudge", SettingsDelegate.label(:calm), :calm, null));
        menu.addItem(new WatchUi.MenuItem("Night nudges", SettingsDelegate.label(:night), :night, null));
        menu.addItem(new WatchUi.MenuItem("Preview nudge", null, :preview, null));
        menu.addItem(new WatchUi.MenuItem("Run setup again", null, :setup, null));
        menu.addItem(new WatchUi.MenuItem("Clear today", null, :clear, null));
        menu.addItem(new WatchUi.MenuItem("Demo: new user", "Wipes everything", :fresh, null));
        menu.addItem(new WatchUi.MenuItem("Demo: month later", "Loads sample data", :month, null));
        menu.addItem(new WatchUi.MenuItem("Demo: tense spell", "20 min at a desk", :tense, null));
        WatchUi.pushView(menu, new SettingsDelegate(_model), WatchUi.SLIDE_LEFT);
        return true;
    }

}
