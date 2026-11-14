import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Timer;
import Toybox.WatchUi;

class DaylightView extends WatchUi.View {

    private var _model as DaylightModel;
    private var _timer as Timer.Timer?;
    private var _page as Number = 0;

    function initialize(model as DaylightModel) {
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
        _page = (_page + by + 3) % 3;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (_page == 0) {
            drawRing(dc);
        } else if (_page == 1) {
            drawSun(dc);
        } else {
            drawToday(dc);
        }
    }

    // Page 1: today's light against the goal.
    private function drawRing(dc as Dc) as Void {
        var m = _model;
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var r = w / 2 - 10;

        dc.setPenWidth(14);
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
            state = "IN LIGHT " + m.lightPct.format("%d") + "%";
        } else if (m.hasFix && !m.sunUp()) {
            state = "SUN IS DOWN";
        }
        dc.setColor(m.inLight ? Graphics.COLOR_YELLOW : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, 52, Graphics.FONT_XTINY, state);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, cy - 10, Graphics.FONT_NUMBER_HOT, (m.lightSecs / 60).format("%d"));
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, cy + 42, Graphics.FONT_XTINY, "of " + (m.goalSecs / 60).format("%d") + " min");

        var line = "Streak " + m.streak.format("%d");
        if (!m.note.equals("")) {
            line = m.note;
        } else if (m.hasFix) {
            var now = m.nowMin();
            if (m.sunUp()) {
                line = "Sun left " + span(m.setMin - now);
            } else if (now < m.riseMin) {
                line = "Sunrise " + clock(m.riseMin);
            }
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, h - 62, Graphics.FONT_XTINY, line);

        if (m.demo >= 0) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            text(dc, cx, h - 38, Graphics.FONT_XTINY, "DEMO " + m.demo.format("%d") + "% x60");
        }
    }

    // Page 2: where the sun is, turned to match the way the watch is facing.
    private function drawSun(dc as Dc) as Void {
        var m = _model;
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var r = w / 2 - 28;

        if (!m.hasFix) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            text(dc, cx, cy, Graphics.FONT_SMALL, "Waiting for GPS");
            return;
        }

        dc.setPenWidth(2);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, r);

        var north = Math.toRadians(0.0 - m.heading);
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        text(dc, cx + ((r + 14) * Math.sin(north)).toNumber(), cy - ((r + 14) * Math.cos(north)).toNumber(),
            Graphics.FONT_XTINY, "N");

        var a = Math.toRadians(m.sunAz - m.heading);
        var sx = cx + (r * Math.sin(a)).toNumber();
        var sy = cy - (r * Math.cos(a)).toNumber();
        if (m.sunUp()) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(cx, cy, sx, sy);
            dc.fillCircle(sx, sy, 12);
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(sx, sy, 12);
        }
        dc.setPenWidth(1);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, 58);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, cy - 24, Graphics.FONT_MEDIUM, compassWord(m.sunAz) + " " + m.sunAz.format("%.0f") + "°");
        if (m.sunUp()) {
            text(dc, cx, cy + 4, Graphics.FONT_XTINY, m.sunEl.format("%.0f") + "° up");
            text(dc, cx, cy + 28, Graphics.FONT_XTINY, "Sets " + clock(m.setMin));
        } else {
            text(dc, cx, cy + 4, Graphics.FONT_XTINY, "Sun is down");
            text(dc, cx, cy + 28, Graphics.FONT_XTINY, "Rises " + clock(m.riseMin));
        }
        if (!m.hasHeading) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            text(dc, cx, h - 30, Graphics.FONT_XTINY, "north up");
        }
    }

    // Page 3: what each sensor contributed today.
    private function drawToday(dc as Dc) as Void {
        var m = _model;
        var cx = dc.getWidth() / 2;
        var y = 44;

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, y, Graphics.FONT_XTINY, "TODAY");
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        y += 28;
        var light = "Light " + (m.lightSecs / 60).format("%d") + " min, now " + m.lightPct.format("%d") + "%";
        if (!m.hasSolar && m.demo < 0) {
            light = "No solar sensor";
        }
        text(dc, cx, y, Graphics.FONT_XTINY, light);

        y += 28;
        text(dc, cx, y, Graphics.FONT_XTINY, "Moving " + (m.moveSecs / 60).format("%d") + " min" + (m.moving ? " (now)" : ""));

        y += 28;
        var heart = "HR " + m.hr.format("%d");
        if (m.hrBefore > 0) {
            heart = "HR before " + m.hrBefore.format("%d") + ", now " + m.hr.format("%d");
        }
        text(dc, cx, y, Graphics.FONT_XTINY, heart);

        y += 28;
        var gps = "GPS waiting";
        if (m.hasFix) {
            gps = "GPS " + m.lat.format("%.2f") + ", " + m.lon.format("%.2f");
        }
        text(dc, cx, y, Graphics.FONT_XTINY, gps);

        y += 28;
        var baro = "Baro no history";
        if (m.hasBaro) {
            baro = "Baro " + m.baroDelta.format("%.1f") + " hPa/3h";
            if (m.baroDelta <= -1.5) {
                baro = baro + ", go now";
            }
        }
        text(dc, cx, y, Graphics.FONT_XTINY, baro);

        y += 28;
        var comp = "Compass waiting";
        if (m.hasHeading) {
            comp = "Compass " + m.heading.format("%.0f") + "°";
        }
        text(dc, cx, y, Graphics.FONT_XTINY, comp);
    }

    private function text(dc as Dc, x as Number, y as Number, font as Graphics.FontType, s as String) as Void {
        dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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
