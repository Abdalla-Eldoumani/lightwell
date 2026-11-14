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
    static const WORDS = [0, 2, 3, 4];  // "words" values offered; 1 is retired

    private var _model as LightwellModel;
    private var _menu as WatchUi.Menu2?;   // the settings menu; null for the drink log and session menu

    static function open(model as LightwellModel) as Void {
        var menu = new StyledMenu("Settings");
        menu.addItem(new StyledItem("Daily goal", label(:goal), :goal));
        menu.addItem(new StyledItem("Nudge text", label(:words), :words));
        menu.addItem(new StyledItem("Nudge style", label(:buzz), :buzz));
        menu.addItem(new StyledItem("Coffee a day", label(:cups), :cups));
        menu.addItem(new StyledItem("Water goal", label(:h2o), :h2o));
        menu.addItem(new StyledItem("Stress nudge", label(:calm), :calm));
        menu.addItem(new StyledItem("Night nudges", label(:night), :night));
        menu.addItem(new StyledItem("Accessibility", wheelLabel(), :access));
        menu.addItem(new StyledItem("Preview nudge", null, :preview));
        menu.addItem(new StyledItem("Run setup again", "Go through the wizard", :setup));
        menu.addItem(new StyledItem("Clear today", "Resets today's light", :clear));
        menu.addItem(new StyledItem("Demo: new user", "Wipes everything", :fresh));
        menu.addItem(new StyledItem("Demo: month later", "Loads sample data", :month));
        menu.addItem(new StyledItem("Demo: tense spell", "20 min at a desk", :tense));
        menu.addItem(new StyledItem("Demo: midday check", "The gentle reminder", :midday));
        WatchUi.pushView(menu, new SettingsDelegate(model, menu), WatchUi.SLIDE_LEFT);
    }

    // True for the settings that open a list of choices.
    static function picks(id as Symbol) as Boolean {
        return id == :goal || id == :words || id == :buzz || id == :cups || id == :h2o || id == :calm || id == :night;
    }

    static function wheelLabel() as String {
        return (Day.num("wheel") == 1) ? "Wheelchair: on" : "Wheelchair: off";
    }

    // The storage key behind a setting.
    static function key(id as Symbol) as String {
        var keys = { :goal => "goal", :words => "words", :buzz => "buzz", :cups => "cups",
                     :h2o => "h2o", :calm => "calm", :night => "night" };
        return keys[id] as String;
    }

    // The stored value of each choice. Words and buzz store the position in the list.
    static function values(id as Symbol) as Array<Number> {
        if (id == :goal) {
            return GOALS;
        }
        if (id == :cups) {
            return [2, 4, -1];   // -1: no coffee
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
        return (id == :words) ? WORDS : [0, 1, 2];
    }

    // The shown name of each choice, in the same order as values().
    static function names(id as Symbol) as Array<String> {
        if (id == :words) {
            var list = (Day.num("wheel") == 1) ? Day.WHEEL_ACTIONS : Day.ACTIONS;
            var out = [] as Array<String>;
            for (var i = 0; i < WORDS.size(); i++) {
                out.add(list[WORDS[i]]);
            }
            return out;
        }
        if (id == :buzz) {
            return BUZZ;
        }
        if (id == :cups) {
            return ["Less than 2", "Less than 4", "No coffee"];
        }
        if (id == :calm) {
            return ["After 15 min", "After 30 min", "Off"];
        }
        if (id == :night) {
            return ["Off at night", "On"];
        }
        var vals = values(id);
        var out = [] as Array<String>;
        for (var i = 0; i < vals.size(); i++) {
            out.add(vals[i].format("%d") + ((id == :goal) ? " min" : " glasses"));
        }
        return out;
    }

    // Which choice is current; a setting nobody has touched shows its default.
    // The retired "words" value 1 is not in the list, so it shows as the walk choice.
    static function current(id as Symbol) as Number {
        var defaults = { :goal => 20, :cups => 4, :h2o => 8, :calm => 15 };
        var dflt = defaults[id];
        var now = (dflt != null) ? Day.opt(key(id), dflt as Number) : Day.num(key(id));
        var i = values(id).indexOf(now);
        return (i >= 0) ? i : 0;
    }

    // The value shown under a setting's name.
    static function label(id as Symbol) as String {
        return names(id)[current(id)];
    }

    function initialize(model as LightwellModel, menu as WatchUi.Menu2?) {
        Menu2InputDelegate.initialize();
        _model = model;
        _menu = menu;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Symbol;
        if (picks(id)) {
            var list = names(id);
            var menu = new StyledMenu(item.getLabel() as String);
            for (var i = 0; i < list.size(); i++) {
                menu.addItem(new StyledItem(list[i], (i == current(id)) ? "Selected" : null, i));
            }
            menu.setFocus(current(id));
            WatchUi.pushView(menu, new PickDelegate(id, item, _model), WatchUi.SLIDE_LEFT);
            return;
        }
        if (id == :access) {
            var menu = new StyledMenu("Accessibility");
            menu.addItem(new StyledItem("Wheelchair user", wheelLabel(), :wheel));
            var main = _menu as WatchUi.Menu2;
            var words = main.getItem(main.findItemById(:words)) as WatchUi.MenuItem;
            WatchUi.pushView(menu, new AccessDelegate(item, words), WatchUi.SLIDE_LEFT);
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

// Accessibility options. Pressing the wheelchair row flips it and saves at once.
class AccessDelegate extends WatchUi.Menu2InputDelegate {

    private var _parent as WatchUi.MenuItem;
    private var _words as WatchUi.MenuItem;   // its wording changes with the toggle

    function initialize(parent as WatchUi.MenuItem, words as WatchUi.MenuItem) {
        Menu2InputDelegate.initialize();
        _parent = parent;
        _words = words;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        if (item.getId() == :wheel) {
            Application.Storage.setValue("wheel", 1 - Day.num("wheel"));
            item.setSubLabel(SettingsDelegate.wheelLabel());
            _parent.setSubLabel(SettingsDelegate.wheelLabel());
            _words.setSubLabel(SettingsDelegate.label(:words));
        }
    }

}
