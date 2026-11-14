import Toybox.Lang;
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

    // START steps the demo light level; hold UP opens the settings.
    function onSelect() as Boolean {
        _model.cycleDemo();
        WatchUi.requestUpdate();
        return true;
    }

    function onMenu() as Boolean {
        var menu = new WatchUi.Menu2({ :title => "Settings" });
        menu.addItem(new WatchUi.MenuItem("Daily goal", SettingsDelegate.label(:goal), :goal, null));
        menu.addItem(new WatchUi.MenuItem("Wording", SettingsDelegate.label(:words), :words, null));
        menu.addItem(new WatchUi.MenuItem("Nudges", SettingsDelegate.label(:buzz), :buzz, null));
        menu.addItem(new WatchUi.MenuItem("Run setup again", null, :setup, null));
        menu.addItem(new WatchUi.MenuItem("Clear today", null, :clear, null));
        menu.addItem(new WatchUi.MenuItem("Demo: new user", "Wipes everything", :fresh, null));
        menu.addItem(new WatchUi.MenuItem("Demo: month later", "Loads sample data", :month, null));
        WatchUi.pushView(menu, new SettingsDelegate(_model), WatchUi.SLIDE_LEFT);
        return true;
    }

}
