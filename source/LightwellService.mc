import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

(:background)
class LightwellService extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    // Runs every 5 minutes while the app is closed. One reading stands for the whole gap.
    function onTemporalEvent() as Void {
        // The open app counts every second and saves once a minute; counting here too would double it.
        if (Time.now().value() - Day.num("seen") < 120) {
            Background.exit(null);
            return;
        }
        Day.roll();
        var light = Day.num("light");
        var goal = Day.goalSecs();
        var stats = System.getSystemStats();
        var s = (stats has :solarIntensity) ? stats.solarIntensity : null;
        if (s != null && s >= Day.LIGHT_MIN) {
            Application.Storage.setValue("light", light + 300);
            if (light < goal && light + 300 >= goal) {
                Background.requestApplicationWake("Lightwell goal reached");
            }
        } else if (light < goal) {
            nudge();
        }
        Background.exit(null);
    }

    // Sitting, sun up, ring not full: ask, at most once an hour.
    private function nudge() as Void {
        var c = System.getClockTime();
        var nowMin = c.hour * 60 + c.min;
        var now = Time.now().value();
        var mb = ActivityMonitor.getInfo().moveBarLevel;
        if (mb != null && mb >= 1 && nowMin > Day.num("rise") && nowMin < Day.num("set")
                && now - Day.num("nudge") > 3600) {
            Application.Storage.setValue("nudge", now);
            Background.requestApplicationWake("Sun is up. " + Day.action() + "?");
        }
    }

}
