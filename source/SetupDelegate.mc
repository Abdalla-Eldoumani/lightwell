import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// First-run setup: three questions, one screen each. Every answer is one of the
// settings, so the same values can be changed later from the settings menu.
class SetupDelegate extends WatchUi.Menu2InputDelegate {

    private var _model as LightwellModel;
    private var _step as Number;
    private var _rerun as Boolean;   // opened from settings, so the app is already underneath

    function initialize(model as LightwellModel, step as Number, rerun as Boolean) {
        Menu2InputDelegate.initialize();
        _model = model;
        _step = step;
        _rerun = rerun;
    }

    // Each title starts a sentence and each option finishes it. An option's id is the value stored.
    static function menu(step as Number) as WatchUi.Menu2 {
        if (step == 0) {
            var m = new WatchUi.Menu2({ :title => "I get around" });
            m.addItem(new WatchUi.MenuItem("On foot", "Step outside", 0, null));
            m.addItem(new WatchUi.MenuItem("By wheelchair", "Roll outside", 1, null));
            m.addItem(new WatchUi.MenuItem("Mostly indoors", "Find a window", 2, null));
            return m;
        }
        if (step == 1) {
            var m = new WatchUi.Menu2({ :title => "On workdays I get" });
            m.addItem(new WatchUi.MenuItem("Almost no daylight", "Start at 10 min", 10, null));
            m.addItem(new WatchUi.MenuItem("Some daylight", "Aim for 20 min", 20, null));
            m.addItem(new WatchUi.MenuItem("Plenty", "Aim for 30 min", 30, null));
            return m;
        }
        var m = new WatchUi.Menu2({ :title => "Nudge me with" });
        m.addItem(new WatchUi.MenuItem("Buzz and tone", null, 0, null));
        m.addItem(new WatchUi.MenuItem("Soft buzz", null, 1, null));
        m.addItem(new WatchUi.MenuItem("Screen only", null, 2, null));
        return m;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        Application.Storage.setValue(["words", "goal", "buzz"][_step], item.getId() as Number);
        if (_step < 2) {
            show(_step + 1, WatchUi.SLIDE_LEFT);
            return;
        }
        Application.Storage.setValue("setup", 1);
        _model.goalSecs = Day.goalSecs();
        if (_rerun) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        } else {
            var view = new LightwellView(_model);
            WatchUi.switchToView(view, new LightwellDelegate(view, _model), WatchUi.SLIDE_LEFT);
        }
        if (WatchUi has :showToast) {
            WatchUi.showToast((Day.goalSecs() / 60).format("%d") + " min a day. " + Day.action(), null);
        }
    }

    // BACK returns to the previous question; on the first one it leaves as usual.
    function onBack() as Void {
        if (_step > 0) {
            show(_step - 1, WatchUi.SLIDE_RIGHT);
        } else {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
    }

    private function show(step as Number, slide as WatchUi.SlideType) as Void {
        WatchUi.switchToView(menu(step), new SetupDelegate(_model, step, _rerun), slide);
    }

}
