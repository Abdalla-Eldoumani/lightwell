import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Position;
import Toybox.Sensor;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

class DaylightModel {

    // solarIntensity runs 0 to 100. 5 is a first guess for "brighter than a room";
    // the real cut-off needs a watch under office light and under open sky.
    private const LIGHT_MIN = 5;

    var goalSecs as Number = 1200;

    // Light (solar sensor)
    var lightPct as Number = 0;
    var lightSecs as Number = 0;
    var inLight as Boolean = false;
    var hasSolar as Boolean = false;
    var demo as Number = -1;        // -1 reads the sensor, 0..100 forces a level and runs 60x

    // Movement (accelerometer, steps)
    var moving as Boolean = false;
    var moveSecs as Number = 0;

    // Heart rate
    var hr as Number = 0;
    var hrBefore as Number = 0;

    // Place (GPS) and the sun worked out from it
    var hasFix as Boolean = false;
    var gpsQuality as Number = 0;
    var lat as Float = 0.0;
    var lon as Float = 0.0;
    var sunEl as Float = 0.0;       // degrees above the horizon
    var sunAz as Float = 0.0;       // degrees clockwise from north
    var riseMin as Number = 0;      // local minute of the day
    var setMin as Number = 0;

    // Compass
    var hasHeading as Boolean = false;
    var heading as Float = 0.0;

    // Barometer
    var hasBaro as Boolean = false;
    var baroDelta as Float = 0.0;   // hPa change over the last 3 hours

    var streak as Number = 0;
    var note as String = "";

    private var _ticks as Number = 0;
    private var _noteTicks as Number = 0;
    private var _motion as Float = 0.0;
    private var _lastSteps as Number = -1;
    private var _stepTicks as Number = 0;
    private var _darkMoveSecs as Number = 0;
    private var _probe as Boolean = false;
    private var _lastNudge as Number = -1800;
    private var _lastSleeve as Number = -600;
    private var _day as Number = 0;
    private var _lastGoalDay as Number = 0;
    private var _offMin as Number = 0;

    function initialize() {
    }

    function start() as Void {
        updateClock();
        load();
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE] as Array<Sensor.SensorType>);
        onPosition(Position.getInfo());
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
        readPressureTrend();
    }

    function stop() as Void {
        save();
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        Sensor.setEnabledSensors([] as Array<Sensor.SensorType>);
    }

    // Called once a second by the view.
    function tick() as Void {
        _ticks += 1;
        readLight();
        readBody();
        if (_ticks % 30 == 1) {
            updateSun();
        }
        if (_ticks % 300 == 0) {
            readPressureTrend();
        }

        var wasIn = inLight;
        inLight = lightPct >= LIGHT_MIN;
        if (inLight && !wasIn) {
            hrBefore = hr;
        }
        if (inLight) {
            var step = (demo >= 0) ? 60 : 1;
            var before = lightSecs;
            lightSecs += step;
            if (moving) {
                moveSecs += step;
            }
            if (before < goalSecs && lightSecs >= goalSecs) {
                goalReached();
            }
        }

        checkSleeve();
        if (_ticks % 10 == 0) {
            checkNudge();
        }
        if (_noteTicks > 0) {
            _noteTicks -= 1;
            if (_noteTicks == 0) {
                note = "";
            }
        }
        if (_ticks % 60 == 0) {
            save();
        }
    }

    // START cycles: sensor, then forced 0, 15, 60, 100.
    function cycleDemo() as Void {
        if (demo < 0) {
            demo = 0;
        } else if (demo == 0) {
            demo = 15;
        } else if (demo == 15) {
            demo = 60;
        } else if (demo == 60) {
            demo = 100;
        } else {
            demo = -1;
        }
    }

    function resetToday() as Void {
        lightSecs = 0;
        moveSecs = 0;
        hrBefore = 0;
        setNote("Day reset");
        save();
    }

    function sunUp() as Boolean {
        return hasFix && sunEl > 0.0;
    }

    function nowMin() as Number {
        var c = System.getClockTime();
        return c.hour * 60 + c.min;
    }

    function onPosition(info as Position.Info) as Void {
        var q = info.accuracy;
        if (q != null) {
            gpsQuality = q as Number;
        }
        var loc = info.position;
        if (loc != null) {
            var d = loc.toDegrees();
            lat = d[0].toFloat();
            lon = d[1].toFloat();
            hasFix = true;
            updateSun();
        }
        // A good fix while moving in the dark with the sun up means the watch is outside but covered.
        if (_probe) {
            _probe = false;
            if (gpsQuality >= Position.QUALITY_USABLE && !inLight && sunEl > 3.0) {
                setNote("Sleeve over watch?");
                buzz();
            }
        }
    }

    private function readLight() as Void {
        var stats = System.getSystemStats();
        var s = null;
        if (stats has :solarIntensity) {
            s = stats.solarIntensity;
        }
        hasSolar = (s != null);
        if (demo >= 0) {
            lightPct = demo;
        } else if (s != null && s > 0) {
            lightPct = s as Number;
        } else {
            lightPct = 0;
        }
    }

    private function readBody() as Void {
        var info = Sensor.getInfo();

        var h = info.heartRate;
        if (h != null) {
            hr = h as Number;
        }

        var hd = info.heading;
        if (hd != null) {
            heading = fmod(Math.toDegrees(hd), 360.0);
            hasHeading = true;
        }

        // How far the pull on the wrist is from a still 1 g, smoothed.
        var a = info.accel;
        if (a != null && a.size() >= 3) {
            var mag = Math.sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
            var dev = mag - 1000;
            if (dev < 0) {
                dev = -dev;
            }
            _motion = (_motion * 0.8 + dev * 0.2).toFloat();
        }

        var st = ActivityMonitor.getInfo().steps;
        if (st != null) {
            if (_lastSteps >= 0 && st > _lastSteps) {
                _stepTicks = 5;
            }
            _lastSteps = st as Number;
        }
        if (_stepTicks > 0) {
            _stepTicks -= 1;
        }
        moving = (_motion > 60.0) || (_stepTicks > 0);
    }

    private function checkSleeve() as Void {
        if (!inLight && moving && sunUp()) {
            _darkMoveSecs += 1;
        } else {
            _darkMoveSecs = 0;
        }
        if (_darkMoveSecs == 20 && _ticks - _lastSleeve > 600) {
            _lastSleeve = _ticks;
            _probe = true;
            Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
        }
    }

    private function checkNudge() as Void {
        var mb = ActivityMonitor.getInfo().moveBarLevel;
        if (mb != null && mb >= 1 && sunUp() && !inLight && lightSecs < goalSecs && _ticks - _lastNudge > 1800) {
            _lastNudge = _ticks;
            setNote("Sun is up. Step out.");
            buzz();
        }
    }

    private function goalReached() as Void {
        if (_lastGoalDay != _day) {
            // One missed day does not break the streak.
            if (_lastGoalDay >= _day - 2) {
                streak += 1;
            } else {
                streak = 1;
            }
            _lastGoalDay = _day;
        }
        setNote("Goal reached");
        buzz();
        save();
    }

    private function readPressureTrend() as Void {
        if ((Toybox has :SensorHistory) && (SensorHistory has :getPressureHistory)) {
            var it = SensorHistory.getPressureHistory({ :period => new Time.Duration(10800) });
            if (it == null) {
                return;
            }
            var newest = 0.0;
            var oldest = 0.0;
            var count = 0;
            var sample = it.next();
            while (sample != null) {
                var v = sample.data;
                if (v != null) {
                    var f = v.toFloat();
                    if (count == 0) {
                        newest = f;
                    }
                    oldest = f;
                    count += 1;
                }
                sample = it.next();
            }
            if (count >= 2) {
                baroDelta = (newest - oldest) / 100.0;
                hasBaro = true;
            }
        }
    }

    private function updateClock() as Void {
        var now = Time.now().value();
        var utcMin = (now % 86400) / 60;
        var off = nowMin() - utcMin;
        if (off > 720) {
            off -= 1440;
        }
        if (off < -720) {
            off += 1440;
        }
        _offMin = off;
        _day = (now + off * 60) / 86400;
    }

    // NOAA's short solar position formulas. Checked against Calgary: Nov 14 gives 8:50 and 17:51.
    private function updateSun() as Void {
        updateClock();
        if (!hasFix) {
            return;
        }
        var g = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var daysBefore = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
        var doy = daysBefore[(g.month as Number) - 1] + g.day;
        var utcMin = (Time.now().value() % 86400) / 60.0;

        var y = 2.0 * Math.PI / 365.0 * (doy - 1 + (utcMin / 60.0 - 12.0) / 24.0);
        var eot = 229.18 * (0.000075 + 0.001868 * Math.cos(y) - 0.032077 * Math.sin(y)
            - 0.014615 * Math.cos(2 * y) - 0.040849 * Math.sin(2 * y));
        var dec = 0.006918 - 0.399912 * Math.cos(y) + 0.070257 * Math.sin(y)
            - 0.006758 * Math.cos(2 * y) + 0.000907 * Math.sin(2 * y)
            - 0.002697 * Math.cos(3 * y) + 0.00148 * Math.sin(3 * y);

        var la = Math.toRadians(lat);
        var ha = Math.toRadians(fmod(utcMin + eot + 4.0 * lon, 1440.0) / 4.0 - 180.0);
        var cosZen = clamp(Math.sin(la) * Math.sin(dec) + Math.cos(la) * Math.cos(dec) * Math.cos(ha));
        sunEl = (90.0 - Math.toDegrees(Math.acos(cosZen))).toFloat();
        var az = Math.toDegrees(Math.atan2(Math.sin(ha),
            Math.cos(ha) * Math.sin(la) - Math.tan(dec) * Math.cos(la))) + 180.0;
        sunAz = fmod(az, 360.0);

        var cosH0 = clamp((Math.sin(Math.toRadians(-0.833)) - Math.sin(la) * Math.sin(dec))
            / (Math.cos(la) * Math.cos(dec)));
        var h0 = Math.toDegrees(Math.acos(cosH0));
        var noon = 720.0 - 4.0 * lon - eot + _offMin;
        riseMin = fmod(noon - 4.0 * h0, 1440.0).toNumber();
        setMin = fmod(noon + 4.0 * h0, 1440.0).toNumber();
    }

    private function clamp(x as Decimal) as Decimal {
        if (x > 1.0) {
            return 1.0;
        }
        if (x < -1.0) {
            return -1.0;
        }
        return x;
    }

    private function fmod(a as Decimal, m as Float) as Float {
        var r = a - m * Math.floor(a / m);
        return r.toFloat();
    }

    private function setNote(text as String) as Void {
        note = text;
        _noteTicks = 15;
    }

    private function buzz() as Void {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(60, 400)] as Array<Attention.VibeProfile>);
        }
    }

    private function load() as Void {
        var d = Application.Storage.getValue("day");
        var ls = Application.Storage.getValue("light");
        var ms = Application.Storage.getValue("move");
        var sk = Application.Storage.getValue("streak");
        var gd = Application.Storage.getValue("goalDay");
        if (sk instanceof Number) {
            streak = sk as Number;
        }
        if (gd instanceof Number) {
            _lastGoalDay = gd as Number;
        }
        if ((d instanceof Number) && (d as Number) == _day) {
            if (ls instanceof Number) {
                lightSecs = ls as Number;
            }
            if (ms instanceof Number) {
                moveSecs = ms as Number;
            }
        }
    }

    function save() as Void {
        Application.Storage.setValue("day", _day);
        Application.Storage.setValue("light", lightSecs);
        Application.Storage.setValue("move", moveSecs);
        Application.Storage.setValue("streak", streak);
        Application.Storage.setValue("goalDay", _lastGoalDay);
    }

}
