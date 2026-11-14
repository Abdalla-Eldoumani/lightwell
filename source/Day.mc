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
    const GOAL_SECS = 1200;

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

    function num(key as String) as Number {
        var v = Application.Storage.getValue(key);
        return (v instanceof Number) ? v : 0;
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
            if (light >= GOAL_SECS) {
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
            var hist = [0, 0, 0, 0, 0, 0] as Array<Application.Storage.ValueType>;
            for (var i = 0; i < 6; i++) {
                var src = i - gap;
                if (i == gap - 1) {
                    hist[i] = light / 60;
                } else if (src >= 0 && src < 6 && (old instanceof Array) && old.size() == 6) {
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
    }

}
