import Toybox.Application;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// The settings menu. Each setting opens a list of its choices; the wizard writes the same keys.
// The drink log and the session menu are short menus that share this delegate.
class SettingsDelegate extends WatchUi.Menu2InputDelegate {

    static const GOALS = [10, 15, 20, 30, 45, 60];
    static const BUZZ = ["Buzz and tone", "Soft buzz", "Screen only"];

    private var _model as LightwellModel;

    static function open(model as LightwellModel) as Void {
        var menu = new WatchUi.Menu2({ :title => "Settings" });
        menu.addItem(new WatchUi.MenuItem("Daily goal", label(:goal), :goal, null));
        menu.addItem(new WatchUi.MenuItem("Nudge text", label(:words), :words, null));
        menu.addItem(new WatchUi.MenuItem("Nudge style", label(:buzz), :buzz, null));
        menu.addItem(new WatchUi.MenuItem("Last coffee", label(:cutoff), :cutoff, null));
        menu.addItem(new WatchUi.MenuItem("Water goal", label(:h2o), :h2o, null));
        menu.addItem(new WatchUi.MenuItem("Stress nudge", label(:calm), :calm, null));
        menu.addItem(new WatchUi.MenuItem("Night nudges", label(:night), :night, null));
        menu.addItem(new WatchUi.MenuItem("Preview nudge", null, :preview, null));
        menu.addItem(new WatchUi.MenuItem("Run setup again", "Go through the wizard", :setup, null));
        menu.addItem(new WatchUi.MenuItem("Clear today", "Resets today's light", :clear, null));
        menu.addItem(new WatchUi.MenuItem("Demo: new user", "Wipes everything", :fresh, null));
        menu.addItem(new WatchUi.MenuItem("Demo: month later", "Loads sample data", :month, null));
        menu.addItem(new WatchUi.MenuItem("Demo: tense spell", "20 min at a desk", :tense, null));
        menu.addItem(new WatchUi.MenuItem("Demo: midday check", "The gentle reminder", :midday, null));
        WatchUi.pushView(menu, new SettingsDelegate(model), WatchUi.SLIDE_LEFT);
    }

    // True for the settings that open a list of choices.
    static function picks(id as Symbol) as Boolean {
        return id == :goal || id == :words || id == :buzz || id == :cutoff || id == :h2o || id == :calm || id == :night;
    }

    // The storage key behind a setting.
    static function key(id as Symbol) as String {
        var keys = { :goal => "goal", :words => "words", :buzz => "buzz", :cutoff => "cutoff",
                     :h2o => "h2o", :calm => "calm", :night => "night" };
        return keys[id] as String;
    }

    // The stored value of each choice. Words and buzz store the position in the list.
    static function values(id as Symbol) as Array<Number> {
        if (id == :goal) {
            return GOALS;
        }
        if (id == :cutoff) {
            return [12, 14, 16];
        }
        if (id == :h2o) {
            return [6, 8, 10];
        }
        if (id == :calm) {
            return [15, 30, -1];
        }
        if (id == :night) {
            return [0, 1];
        }
        return (id == :words) ? [0, 1, 2, 3, 4] : [0, 1, 2];
    }

    // The shown name of each choice, in the same order as values().
    static function names(id as Symbol) as Array<String> {
        if (id == :words) {
            return Day.ACTIONS;
        }
        if (id == :buzz) {
            return BUZZ;
        }
        if (id == :cutoff) {
            return ["12 PM", "2 PM", "4 PM"];
        }
        if (id == :calm) {
            return ["After 15 min", "After 30 min", "Off"];
        }
        if (id == :night) {
            return ["Off, 10 PM to 7 AM", "On"];
        }
        var vals = values(id);
        var out = [] as Array<String>;
        for (var i = 0; i < vals.size(); i++) {
            out.add(vals[i].format("%d") + ((id == :goal) ? " min" : " glasses"));
        }
        return out;
    }

    // Which choice is current; a setting nobody has touched shows its default.
    static function current(id as Symbol) as Number {
        var defaults = { :goal => 20, :cutoff => 14, :h2o => 8, :calm => 15 };
        var dflt = defaults[id];
        var now = (dflt != null) ? Day.opt(key(id), dflt as Number) : Day.num(key(id));
        var i = values(id).indexOf(now);
        return (i >= 0) ? i : 0;
    }

    // The value shown under a setting's name.
    static function label(id as Symbol) as String {
        return names(id)[current(id)];
    }

    function initialize(model as LightwellModel) {
        Menu2InputDelegate.initialize();
        _model = model;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Symbol;
        if (picks(id)) {
            var list = names(id);
            var menu = new WatchUi.Menu2({ :title => item.getLabel() });
            for (var i = 0; i < list.size(); i++) {
                menu.addItem(new WatchUi.MenuItem(list[i], (i == current(id)) ? "Selected" : null, i, null));
            }
            menu.setFocus(current(id));
            WatchUi.pushView(menu, new PickDelegate(id, item, _model), WatchUi.SLIDE_LEFT);
            return;
        }
        if (id == :exit) {
            // The app saves the day as it stops.
            System.exit();
        }
        if (id == :coffee || id == :lessCoffee) {
            _model.addCup((id == :coffee) ? 1 : -1);
        } else if (id == :water || id == :lessWater) {
            _model.addGlass((id == :water) ? 1 : -1);
        } else if (id == :clear) {
            _model.resetToday();
        } else if (id == :tense) {
            _model.demoTense();
        } else if (id == :midday) {
            _model.midday();
        } else if (id == :preview) {
            _model.nudge(60);
        } else if (id == :month) {
            DemoData.month();
            _model.load();
        }
        // All of those, and "Keep going", return to the app; a card shows as soon as the menu closes.
        if (id != :setup && id != :fresh) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            if (id == :month && (WatchUi has :showToast)) {
                WatchUi.showToast("A month later", null);
            }
            return;
        }
        if (id == :fresh) {
            Application.Storage.clearValues();
            _model.load();
        }
        // The wizard replaces the settings menu and returns to the app when done.
        var setup = new SetupView();
        WatchUi.switchToView(setup, new SetupDelegate(setup, _model, true), WatchUi.SLIDE_LEFT);
    }

}

// One setting's list of choices: picking one saves it and goes back to the settings menu.
class PickDelegate extends WatchUi.Menu2InputDelegate {

    private var _id as Symbol;
    private var _parent as WatchUi.MenuItem;
    private var _model as LightwellModel;

    function initialize(id as Symbol, parent as WatchUi.MenuItem, model as LightwellModel) {
        Menu2InputDelegate.initialize();
        _id = id;
        _parent = parent;
        _model = model;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var i = item.getId() as Number;
        Application.Storage.setValue(SettingsDelegate.key(_id), SettingsDelegate.values(_id)[i]);
        if (_id == :goal) {
            _model.goalSecs = Day.goalSecs();
        } else if (_id == :buzz) {
            // Plays the new level so the choice can be felt and heard.
            _model.alert(Attention.TONE_ALERT_HI);
        }
        _parent.setSubLabel(SettingsDelegate.label(_id));
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}
