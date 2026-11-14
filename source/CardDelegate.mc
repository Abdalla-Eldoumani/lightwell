import Toybox.Lang;
import Toybox.WatchUi;

// START or a tap closes the card. On a nudge, BACK means "later" and asks again sooner.
class CardDelegate extends WatchUi.BehaviorDelegate {

    private var _model as LightwellModel;
    private var _nudge as Boolean;

    function initialize(model as LightwellModel, nudge as Boolean) {
        BehaviorDelegate.initialize();
        _model = model;
        _nudge = nudge;
    }

    function onSelect() as Boolean {
        close(_nudge ? "Enjoy the light" : null);
        return true;
    }

    function onBack() as Boolean {
        if (_nudge) {
            _model.snooze();
        }
        close(_nudge ? "Again in 10 min" : null);
        return true;
    }

    private function close(toast as String?) as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        if (toast != null && (WatchUi has :showToast)) {
            WatchUi.showToast(toast, null);
        }
    }

}
