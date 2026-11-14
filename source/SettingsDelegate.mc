import Toybox.Application;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.WatchUi;

class SettingsDelegate extends WatchUi.Menu2InputDelegate {

    private var _model as LightwellModel;

    function initialize(model as LightwellModel) {
        Menu2InputDelegate.initialize();
        _model = model;
    }

    // The value shown under a setting's name.
    static function label(id as Symbol) as String {
        if (id == :goal) {
            return (Day.goalSecs() / 60).format("%d") + " min";
        }
        if (id == :words) {
            return ["Walk", "Roll", "Window"][Day.num("words") % 3];
        }
        return ["Buzz and tone", "Soft buzz", "Screen only"][Day.num("buzz") % 3];
    }

    // Each press steps a setting to its next value: there are only three of each.
    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Symbol;
        if (id == :clear) {
            _model.resetToday();
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return;
        }
        if (id == :preview) {
            // The app underneath shows the card as soon as the menu closes.
            _model.nudge(60);
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return;
        }
        if (id == :month) {
            DemoData.month();
            _model.load();
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            if (WatchUi has :showToast) {
                WatchUi.showToast("A month later", null);
            }
            return;
        }
        if (id == :fresh) {
            Application.Storage.clearValues();
            _model.load();
        }
        if (id == :setup || id == :fresh) {
            var setup = new SetupView();
            WatchUi.switchToView(setup, new SetupDelegate(setup, _model, true), WatchUi.SLIDE_LEFT);
            return;
        }
        if (id == :goal) {
            var mins = Day.goalSecs() / 60 + 10;
            Application.Storage.setValue("goal", (mins > 30) ? 10 : mins);
            _model.goalSecs = Day.goalSecs();
        } else if (id == :words) {
            Application.Storage.setValue("words", (Day.num("words") + 1) % 3);
        } else {
            Application.Storage.setValue("buzz", (Day.num("buzz") + 1) % 3);
            // Plays the new level so the choice can be felt and heard.
            _model.alert(Attention.TONE_ALERT_HI);
        }
        item.setSubLabel(label(id));
        WatchUi.requestUpdate();
    }

}
