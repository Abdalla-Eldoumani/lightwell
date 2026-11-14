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

    // A tap picks a button on the settings page. On the drinks page a tap on the left
    // adds a coffee and on the right a water.
    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var at = clickEvent.getCoordinates();
        if (_view.page == _view.SETTINGS_PAGE) {
            for (var i = 0; i < 2; i++) {
                if (at[1] >= _view.BUTTON_Y[i] - 18 && at[1] <= _view.BUTTON_Y[i] + 18) {
                    _view.focus = i;
                    return onSelect();
                }
            }
            return true;
        }
        if (_view.page != _view.DRINKS_PAGE) {
            return false;
        }
        if (at[0] < System.getDeviceSettings().screenWidth / 2) {
            _model.addCup(1);
        } else {
            _model.addGlass(1);
        }
        WatchUi.requestUpdate();
        return true;
    }

    // START opens the focused button on the settings page and the log on the drinks page,
    // and steps the demo light level elsewhere. Hold UP opens the settings from any page.
    function onSelect() as Boolean {
        if (_view.page == _view.SETTINGS_PAGE) {
            if (_view.focus == 0) {
                SettingsDelegate.open(_model);
            } else {
                var setup = new SetupView();
                WatchUi.pushView(setup, new SetupDelegate(setup, _model, true), WatchUi.SLIDE_LEFT);
            }
            return true;
        }
        if (_view.page == _view.DRINKS_PAGE) {
            var log = new WatchUi.Menu2({ :title => "Log a drink" });
            log.addItem(new WatchUi.MenuItem("Coffee", "Add one", :coffee, null));
            log.addItem(new WatchUi.MenuItem("Water", "Add one", :water, null));
            log.addItem(new WatchUi.MenuItem("Coffee", "Take one off", :lessCoffee, null));
            log.addItem(new WatchUi.MenuItem("Water", "Take one off", :lessWater, null));
            WatchUi.pushView(log, new SettingsDelegate(_model, null), WatchUi.SLIDE_LEFT);
            return true;
        }
        _model.cycleDemo();
        WatchUi.requestUpdate();
        return true;
    }

    // BACK asks before leaving, and is also where the day can be reset.
    function onBack() as Boolean {
        var menu = new WatchUi.Menu2({ :title => "Session" });
        menu.addItem(new WatchUi.MenuItem("Keep going", null, :keep, null));
        menu.addItem(new WatchUi.MenuItem("Reset today", "Empties the well", :clear, null));
        menu.addItem(new WatchUi.MenuItem("End session", "Save and exit", :exit, null));
        WatchUi.pushView(menu, new SettingsDelegate(_model, null), WatchUi.SLIDE_LEFT);
        return true;
    }

    function onMenu() as Boolean {
        SettingsDelegate.open(_model);
        return true;
    }

}
