import Toybox.Lang;
import Toybox.WatchUi;

class DaylightDelegate extends WatchUi.BehaviorDelegate {

    private var _view as DaylightView;
    private var _model as DaylightModel;

    function initialize(view as DaylightView, model as DaylightModel) {
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

    // START steps the demo light level; hold UP (menu) clears today.
    function onSelect() as Boolean {
        _model.cycleDemo();
        WatchUi.requestUpdate();
        return true;
    }

    function onMenu() as Boolean {
        _model.resetToday();
        WatchUi.requestUpdate();
        return true;
    }

}
