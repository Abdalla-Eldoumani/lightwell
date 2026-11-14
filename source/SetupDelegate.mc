import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Buttons for the first-run guide. Every answer is one of the settings,
// so the same values can be changed later from the settings menu.
class SetupDelegate extends WatchUi.BehaviorDelegate {

    private var _view as SetupView;
    private var _model as LightwellModel;
    private var _rerun as Boolean;   // opened from settings, so the app is already underneath

    function initialize(view as SetupView, model as LightwellModel, rerun as Boolean) {
        BehaviorDelegate.initialize();
        _view = view;
        _model = model;
        _rerun = rerun;
    }

    function onNextPage() as Boolean {
        _view.sel = (_view.sel + 1) % 3;
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        _view.sel = (_view.sel + 2) % 3;
        WatchUi.requestUpdate();
        return true;
    }

    // Tapping an answer picks it; the rows start at y 104 and are 32 high.
    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var y = clickEvent.getCoordinates()[1];
        if (_view.step < 3 && y >= 104 && y < 200) {
            _view.sel = (y - 104) / 32;
        }
        return onSelect();
    }

    function onSelect() as Boolean {
        var step = _view.step;
        if (step == 0) {
            Application.Storage.setValue("words", _view.sel);
        } else if (step == 1) {
            Application.Storage.setValue("goal", 10 + 10 * _view.sel);
        } else if (step == 2) {
            Application.Storage.setValue("buzz", _view.sel);
        } else {
            finish();
            return true;
        }
        _view.step = step + 1;
        _view.sel = 0;
        WatchUi.requestUpdate();
        return true;
    }

    // BACK returns to the previous question; on the first one it leaves as usual.
    function onBack() as Boolean {
        if (_view.step == 0) {
            return false;
        }
        _view.step -= 1;
        _view.sel = 0;
        WatchUi.requestUpdate();
        return true;
    }

    private function finish() as Void {
        Application.Storage.setValue("setup", 1);
        _model.goalSecs = Day.goalSecs();
        if (_rerun) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        } else {
            var view = new LightwellView(_model);
            WatchUi.switchToView(view, new LightwellDelegate(view, _model), WatchUi.SLIDE_LEFT);
        }
        if (WatchUi has :showToast) {
            WatchUi.showToast((Day.goalSecs() / 60).format("%d") + " min a day", null);
        }
    }

}
