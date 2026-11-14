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
