import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// The settings page. Each setting opens a list of its choices; the wizard writes the same keys.
class SettingsDelegate extends WatchUi.Menu2InputDelegate {

    // Stored value and shown name of every choice, per setting.
    static const GOALS = [10, 15, 20, 30, 45, 60];
    static const BUZZ = ["Buzz and tone", "Soft buzz", "Screen only"];

    private var _model as LightwellModel;

    static function open(model as LightwellModel) as Void {
        var menu = new WatchUi.Menu2({ :title => "Settings" });
        menu.addItem(new WatchUi.MenuItem("Daily goal", label(:goal), :goal, null));
        menu.addItem(new WatchUi.MenuItem("Nudge text", label(:words), :words, null));
        menu.addItem(new WatchUi.MenuItem("Nudge style", label(:buzz), :buzz, null));
        menu.addItem(new WatchUi.MenuItem("Run setup again", "Go through the wizard", :setup, null));
        menu.addItem(new WatchUi.MenuItem("Clear today", "Resets today's light", :clear, null));
        menu.addItem(new WatchUi.MenuItem("Demo: new user", "Wipes everything", :fresh, null));
        menu.addItem(new WatchUi.MenuItem("Demo: month later", "Loads sample data", :month, null));
        WatchUi.pushView(menu, new SettingsDelegate(model), WatchUi.SLIDE_LEFT);
    }

    // The names of a setting's choices, in stored-value order (goal is looked up through GOALS).
    static function names(id as Symbol) as Array<String> {
        if (id == :goal) {
            var out = [] as Array<String>;
            for (var i = 0; i < GOALS.size(); i++) {
                out.add(GOALS[i].format("%d") + " min");
            }
            return out;
        }
        return (id == :words) ? Day.ACTIONS : BUZZ;
    }

    // Which choice is current.
    static function current(id as Symbol) as Number {
        if (id == :goal) {
            var i = GOALS.indexOf(Day.goalSecs() / 60);
            return (i >= 0) ? i : 2;
        }
        return Day.num(id == :words ? "words" : "buzz") % names(id).size();
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
        if (id == :goal || id == :words || id == :buzz) {
            var list = names(id);
            var titles = { :goal => "Daily goal", :words => "Nudge text", :buzz => "Nudge style" };
            var menu = new WatchUi.Menu2({ :title => titles[id] });
            for (var i = 0; i < list.size(); i++) {
                menu.addItem(new WatchUi.MenuItem(list[i], (i == current(id)) ? "Selected" : null, i, null));
            }
            menu.setFocus(current(id));
            WatchUi.pushView(menu, new PickDelegate(id, item, _model), WatchUi.SLIDE_LEFT);
            return;
        }
        if (id == :clear) {
            _model.resetToday();
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
        // :setup or :fresh: the wizard replaces the settings page and returns to the app when done.
        var setup = new SetupView();
        WatchUi.switchToView(setup, new SetupDelegate(setup, _model, true), WatchUi.SLIDE_LEFT);
    }

}

// One setting's list of choices: picking one saves it and goes back to the settings page.
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
        if (_id == :goal) {
            Application.Storage.setValue("goal", SettingsDelegate.GOALS[i]);
            _model.goalSecs = Day.goalSecs();
        } else {
            Application.Storage.setValue(_id == :words ? "words" : "buzz", i);
        }
        _parent.setSubLabel(SettingsDelegate.label(_id));
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}
