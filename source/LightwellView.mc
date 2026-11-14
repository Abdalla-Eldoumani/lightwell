import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Timer;
import Toybox.WatchUi;

class LightwellView extends WatchUi.View {

    private const PAGES = 4;
    // Stand-in history for demo mode, yesterday first. Shown under a SAMPLE label.
    private const SAMPLE = [22, 8, 25, 0, 21, 24] as Array<Number>;

    private var _model as LightwellModel;
    private var _timer as Timer.Timer?;
    private var _page as Number = 0;

    function initialize(model as LightwellModel) {
        View.initialize();
        _model = model;
    }

    function onShow() as Void {
        var t = new Timer.Timer();
        t.start(method(:tick), 1000, true);
        _timer = t;
    }

    function onHide() as Void {
        var t = _timer;
        if (t != null) {
            t.stop();
        }
        _timer = null;
    }

    function tick() as Void {
        _model.tick();
        WatchUi.requestUpdate();
    }

    function turn(by as Number) as Void {
        _page = (_page + by + PAGES) % PAGES;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (_page == 0) {
            drawRing(dc);
        } else if (_page == 1) {
            drawSun(dc);
        } else if (_page == 2) {
            drawWeek(dc);
        } else {
            drawSensors(dc);
        }
        drawDots(dc);
    }

    // Page 1: today's light against the goal.
    private function drawRing(dc as Dc) as Void {
        var m = _model;
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        // Pulled in from the bezel so the page dots fit outside it.
        var r = w / 2 - 18;

        dc.setPenWidth(12);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, r);

        var deg = (360.0 * m.lightSecs / m.goalSecs).toNumber();
        dc.setColor(m.inLight ? Graphics.COLOR_YELLOW : Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        if (deg >= 360) {
            dc.drawCircle(cx, cy, r);
        } else if (deg >= 1) {
            dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, 90, (450 - deg) % 360);
        }
        dc.setPenWidth(1);

        var state = "INDOORS";
        if (m.inLight) {
            state = "LIGHT " + m.lightPct.format("%d") + "%";
        } else if (m.hasFix && !m.sunUp()) {
            state = "SUN DOWN";
        }
        dc.setColor(m.inLight ? Graphics.COLOR_YELLOW : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        line(dc, 60, state, 100);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, cy - 8, Graphics.FONT_NUMBER_THAI_HOT, (m.lightSecs / 60).format("%d"));
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        line(dc, cy + 38, "of " + (m.goalSecs / 60).format("%d") + " min", 100);

        var info = "";
        if (!m.note.equals("")) {
            info = m.note;
        } else if (m.hasFix) {
            var now = m.nowMin();
            if (m.sunUp()) {
                info = "Sun left " + span(m.setMin - now);
            } else if (now < m.riseMin) {
                info = "Sunrise " + clock(m.riseMin);
            } else {
                info = "Sun is down";
            }
        } else {
            info = "Waiting for GPS";
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        line(dc, h - 64, info, 100);

        if (m.demo >= 0) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            text(dc, cx, h - 38, Graphics.FONT_XTINY, "DEMO x60");
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            text(dc, cx, h - 38, Graphics.FONT_XTINY, "Streak " + m.streak().format("%d"));
        }
    }

    // Page 2: where the sun is, turned to match the way the watch is facing.
    private function drawSun(dc as Dc) as Void {
        var m = _model;
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var r = w / 2 - 34;

        if (!m.hasFix) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            line(dc, cy, "Waiting for GPS", 122);
            return;
        }

        dc.setPenWidth(2);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, r);

        var north = Math.toRadians(0.0 - m.heading);
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        text(dc, cx + ((r + 13) * Math.sin(north)).toNumber(), cy - ((r + 13) * Math.cos(north)).toNumber(),
            Graphics.FONT_XTINY, "N");

        var a = Math.toRadians(m.sunAz - m.heading);
        var sx = cx + (r * Math.sin(a)).toNumber();
        var sy = cy - (r * Math.cos(a)).toNumber();
        if (m.sunUp()) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            // The ray starts outside the text in the middle.
            dc.drawLine(cx + (66 * Math.sin(a)).toNumber(), cy - (66 * Math.cos(a)).toNumber(), sx, sy);
            dc.fillCircle(sx, sy, 11);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(sx, sy, 11);
        }
        dc.setPenWidth(1);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, cy - 26, Graphics.FONT_MEDIUM, compassWord(m.sunAz) + " " + m.sunAz.format("%.0f") + "°");
        if (m.sunUp()) {
            text(dc, cx, cy + 2, Graphics.FONT_TINY, m.sunEl.format("%.0f") + "° up");
            text(dc, cx, cy + 26, Graphics.FONT_TINY, "Sets " + clock(m.setMin));
        } else {
            text(dc, cx, cy + 2, Graphics.FONT_TINY, "Sun is down");
            text(dc, cx, cy + 26, Graphics.FONT_TINY, "Rises " + clock(m.riseMin));
        }
        if (!m.hasHeading) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            text(dc, cx, h - 22, Graphics.FONT_XTINY, "north up");
        }
    }

    // Page 3: the habit. Six finished days and today, against the goal line.
    private function drawWeek(dc as Dc) as Void {
        var m = _model;
        var demo = m.demo >= 0;
        var goalMin = m.goalSecs / 60;
        var base = 168;
        var maxH = 84;
        // A bar is full height at one and a half times the goal.
        var top = goalMin * 3 / 2;

        dc.setColor(demo ? Graphics.COLOR_RED : Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        line(dc, 46, demo ? "SAMPLE WEEK" : "LAST 7 DAYS", 122);

        var met = 0;
        for (var i = 0; i < 7; i++) {
            // Left to right: six days ago up to today.
            var mins = m.lightSecs / 60;
            if (i < 6) {
                mins = demo ? SAMPLE[5 - i] : m.hist[5 - i];
            }
            var color = Graphics.COLOR_DK_GRAY;
            if (mins >= goalMin) {
                met += 1;
                color = Graphics.COLOR_YELLOW;
            } else if (i == 6) {
                color = Graphics.COLOR_ORANGE;
            }
            var bar = ((mins > top) ? top : mins) * maxH / top;
            if (bar < 2) {
                bar = 2;
            }
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(58 + i * 22, base - bar, 14, bar);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var goalY = base - goalMin * maxH / top;
        dc.drawLine(50, goalY, 212, goalY);
        line(dc, 190, met.format("%d") + " of 7 days at goal", 122);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        line(dc, 214, "Streak " + m.streak().format("%d"), 122);
    }

    // Page 4: what each sensor is reading and what it is used for.
    private function drawSensors(dc as Dc) as Void {
        var m = _model;

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        line(dc, 38, "SENSORS", 122);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var solar = "No solar sensor";
        if (m.hasSolar || m.demo >= 0) {
            solar = "Solar " + m.lightPct.format("%d") + "%, " + (m.lightSecs / 60).format("%d") + " min";
        }
        line(dc, 65, solar, 122);

        var heart = "HR waiting";
        if (m.hrBefore > 0) {
            heart = "HR " + m.hrBefore.format("%d") + " in, " + m.hr.format("%d") + " now";
        } else if (m.hr > 0) {
            heart = "HR " + m.hr.format("%d");
        }
        line(dc, 92, heart, 122);

        var gps = "GPS waiting";
        if (m.hasFix) {
            gps = "GPS " + m.lat.format("%.2f") + ", " + m.lon.format("%.2f");
        }
        line(dc, 119, gps, 122);

        var baro = "Baro waiting";
        if (m.hasBaro) {
            baro = "Baro " + m.baroDelta.format("%.1f") + " hPa";
            if (m.baroDelta <= -1.5) {
                baro = baro + ", go now";
            }
        }
        line(dc, 146, baro, 122);

        line(dc, 173, "Moving " + (m.moveSecs / 60).format("%d") + " min" + (m.moving ? " (now)" : ""), 122);

        var comp = "Compass waiting";
        if (m.hasHeading) {
            comp = "Compass " + m.heading.format("%.0f") + "°";
        }
        line(dc, 200, comp, 122);
    }

    private function drawDots(dc as Dc) as Void {
        var cy = dc.getHeight() / 2;
        for (var i = 0; i < PAGES; i++) {
            dc.setColor((i == _page) ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(7, cy - 18 + i * 12, 3);
        }
    }

    private function text(dc as Dc, x as Number, y as Number, font as Graphics.FontType, s as String) as Void {
        dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // A centred line that drops to the small font when it would not fit inside
    // a circle of the given radius at that height.
    private function line(dc as Dc, y as Number, s as String, radius as Number) as Void {
        var dy = y - dc.getHeight() / 2;
        var room = 2 * Math.sqrt(radius * radius - dy * dy) - 8;
        var font = Graphics.FONT_TINY;
        if (dc.getTextWidthInPixels(s, font) > room) {
            font = Graphics.FONT_XTINY;
        }
        text(dc, dc.getWidth() / 2, y, font, s);
    }

    private function clock(mins as Number) as String {
        var hh = mins / 60;
        var mm = mins % 60;
        var ampm = (hh >= 12) ? "PM" : "AM";
        hh = hh % 12;
        if (hh == 0) {
            hh = 12;
        }
        return hh.format("%d") + ":" + mm.format("%02d") + " " + ampm;
    }

    private function span(mins as Number) as String {
        if (mins < 0) {
            mins = 0;
        }
        return (mins / 60).format("%d") + "h " + (mins % 60).format("%02d") + "m";
    }

    private function compassWord(az as Float) as String {
        var names = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
        var i = ((az + 22.5) / 45.0).toNumber() % 8;
        return names[i];
    }

}
