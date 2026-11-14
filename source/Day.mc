import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

// Shared by the app and the background service, so both agree on what "today" is.
(:background)
module Day {

    // solarIntensity runs 0 to 100. 5 is a first guess for "brighter than a room";
    // the real cut-off needs a watch under office light and under open sky.
    const LIGHT_MIN = 5;
    // Finished days kept in the history. With today that makes a 30-day month.
    const DAYS = 29;

    // The daily goal is a setting; 20 minutes until the user picks another.
    function goalSecs() as Number {
        var mins = num("goal");
        return ((mins > 0) ? mins : 20) * 60;
    }

    // What a nudge asks for, indexed by the "words" setting: walk, (retired, reads as walk), window, doorstep or blinds.
    const ACTIONS = ["Go touch grass", "Go touch grass", "Find a window", "Step outside", "Open the blinds"];
    // The same nudges for a wheelchair user (accessibility setting "wheel").
    const WHEEL_ACTIONS = ["Soak in the sun", "Soak in the sun", "Find a window", "Soak in the sun", "Open the blinds"];

    function action() as String {
        var list = (num("wheel") == 1) ? WHEEL_ACTIONS : ACTIONS;
        return list[num("words") % list.size()];
    }

    // Minutes the local clock is ahead of UTC.
    function offsetMin() as Number {
        var c = System.getClockTime();
        var off = c.hour * 60 + c.min - (Time.now().value() % 86400) / 60;
        if (off > 720) {
            off -= 1440;
        }
        if (off < -720) {
            off += 1440;
        }
        return off;
    }

    function today() as Number {
        return (Time.now().value() + offsetMin() * 60) / 86400;
    }

    // A setting, or its default until the user picks one.
    function opt(key as String, dflt as Number) as Number {
        var v = num(key);
        return (v != 0) ? v : dflt;
    }

    // The last hour for coffee, as the clock shows it: 12, 14 or 16.
    function cutoffText() as String {
        var h = opt("cutoff", 14);
        return ((h > 12) ? h - 12 : h).format("%d") + " PM";
    }

    function num(key as String) as Number {
        var v = Application.Storage.getValue(key);
        return (v instanceof Number) ? v : 0;
    }

    // Minutes of light on each finished day, yesterday first, always DAYS long.
    function history() as Array<Number> {
        var stored = Application.Storage.getValue("hist");
        var hist = new [DAYS] as Array<Number>;
        for (var i = 0; i < DAYS; i++) {
            hist[i] = ((stored instanceof Array) && i < stored.size()) ? (stored as Array<Number>)[i] : 0;
        }
        return hist;
    }

    // On the first reading of a new day: file the finished day into the history,
    // settle the streak (one missed day is forgiven), and clear today's counters.
    function roll() as Void {
        var now = today();
        var stored = Application.Storage.getValue("day");
        if (stored instanceof Number) {
            var gap = now - stored;
            if (gap == 0) {
                return;
            }
            var light = num("light");
            var streak = num("streak");
            var miss = num("miss");
            if (light >= goalSecs()) {
                streak += 1;
                miss = 0;
            } else {
                miss += 1;
            }
            // Days the watch was off count as missed.
            if (gap > 1) {
                miss += gap - 1;
            }
            if (miss >= 2) {
                streak = 0;
            }
            var old = Application.Storage.getValue("hist");
            var hist = new [DAYS] as Array<Application.Storage.ValueType>;
            for (var i = 0; i < DAYS; i++) {
                var src = i - gap;
                hist[i] = 0;
                if (i == gap - 1) {
                    hist[i] = light / 60;
                } else if (src >= 0 && (old instanceof Array) && src < old.size()) {
                    hist[i] = (old as Array<Number>)[src];
                }
            }
            Application.Storage.setValue("streak", streak);
            Application.Storage.setValue("miss", miss);
            Application.Storage.setValue("hist", hist);
        }
        Application.Storage.setValue("day", now);
        Application.Storage.setValue("light", 0);
        Application.Storage.setValue("move", 0);
        Application.Storage.setValue("cups", 0);
        Application.Storage.setValue("glasses", 0);
        Application.Storage.setValue("tense", 0);
    }

}
