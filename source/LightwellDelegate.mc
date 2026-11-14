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

    // START opens the settings on the settings page and steps the demo light level elsewhere;
    // hold UP opens the settings from any page.
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
        _model.cycleDemo();
        WatchUi.requestUpdate();
        return true;
    }

    // Tapping a button on the settings page picks and opens it.
    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        if (_view.page != _view.SETTINGS_PAGE) {
            return false;
        }
        var y = clickEvent.getCoordinates()[1];
        for (var i = 0; i < 2; i++) {
            if (y >= _view.BUTTON_Y[i] - 18 && y <= _view.BUTTON_Y[i] + 18) {
                _view.focus = i;
                return onSelect();
            }
        }
        return true;
    }

    function onMenu() as Boolean {
        SettingsDelegate.open(_model);
        return true;
    }

}
