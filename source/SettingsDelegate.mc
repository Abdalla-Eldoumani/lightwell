import Toybox.Application;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
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
            return ["Walk", "Roll", "Window", "Doorstep", "Blinds"][Day.num("words") % 5];
        }
        if (id == :cutoff) {
            return Day.cutoffText();
        }
        if (id == :h2o) {
            return Day.opt("h2o", 8).format("%d") + " glasses";
        }
        if (id == :calm) {
            var after = Day.opt("calm", 15);
            return (after > 0) ? "After " + after.format("%d") + " min" : "Off";
        }
        if (id == :night) {
            return (Day.num("night") == 1) ? "On" : "Off, 10 PM to 7 AM";
        }
        return ["Buzz and tone", "Soft buzz", "Screen only"][Day.num("buzz") % 3];
    }

    // Moves a setting to the next of its values.
    private function step(key as String, vals as Array<Number>, now as Number) as Void {
        Application.Storage.setValue(key, vals[(vals.indexOf(now) + 1) % vals.size()]);
    }

    // Each press steps a setting to its next value: three or five of each.
    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Symbol;
        if (id == :clear) {
            _model.resetToday();
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return;
        }
        // The drink log menu shares this delegate.
        if (id == :coffee || id == :lessCoffee) {
            _model.addCup((id == :coffee) ? 1 : -1);
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return;
        }
        if (id == :water || id == :lessWater) {
            _model.addGlass((id == :water) ? 1 : -1);
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return;
        }
        if (id == :keep) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return;
        }
        if (id == :exit) {
            // The app saves the day as it stops.
            System.exit();
        }
        if (id == :midday) {
            _model.midday();
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return;
        }
        if (id == :tense) {
            _model.demoTense();
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
            Application.Storage.setValue("words", (Day.num("words") + 1) % 5);
        } else if (id == :cutoff) {
            step("cutoff", [12, 14, 16], Day.opt("cutoff", 14));
        } else if (id == :h2o) {
            step("h2o", [6, 8, 10], Day.opt("h2o", 8));
        } else if (id == :calm) {
            step("calm", [15, 30, -1], Day.opt("calm", 15));
        } else if (id == :night) {
            Application.Storage.setValue("night", 1 - Day.num("night"));
        } else {
            Application.Storage.setValue("buzz", (Day.num("buzz") + 1) % 3);
            // Plays the new level so the choice can be felt and heard.
            _model.alert(Attention.TONE_ALERT_HI);
        }
        item.setSubLabel(label(id));
        WatchUi.requestUpdate();
    }

}
