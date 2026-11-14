import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Timer;
import Toybox.WatchUi;

class LightwellView extends WatchUi.View {

    private const PAGES = 8;
    const DRINKS_PAGE = 2;
    const SETTINGS_PAGE = 7;

    private var _model as LightwellModel;
    private var _timer as Timer.Timer?;
    var page as Number = 0;
    var focus as Number = 0;    // on the settings page: 0 the settings button, 1 the setup button
    const BUTTON_Y = [158, 198];

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
        var m = _model;
        m.tick();
        if (m.card != 0) {
            var kind = m.card;
            m.card = 0;
            // Sit nudges and tense spells can be put off; the other two only inform.
            var nudge = kind == 1 || kind == 3 || kind == 5;
            var title = Day.action();
            var lines = [m.why, m.sunUp() ? "Sun left " + m.hm(m.setMin - m.nowMin()) : ""];
            if (kind == 2) {
                title = "Well is full";
                lines = [(m.goalSecs / 60).format("%d") + " min of daylight", "Streak " + m.streak().format("%d")];
            } else if (kind == 3) {
                lines = ["Tense and still", "for " + m.spell.format("%d") + " min"];
            } else if (kind == 5) {
                title = "Midday check-in";
                lines = ["The day is half over", "and your well is low.",
                    ((Day.num("wheel") == 1)
                        ? ["A while in the sun?", "A while in the sun?", "A while by the window?",
                           "A while in the sun?", "Open the blinds a while?"]
                        : ["A short stroll outside?", "A short stroll outside?", "A while by the window?",
                           "A step outside the door?", "Open the blinds a while?"])[Day.num("words") % 5]];
            } else if (kind == 4) {
                title = "Coffee limit";
                lines = [m.cups.format("%d") + " cups today", "Water instead?"];
            }
            WatchUi.pushView(new CardView(title, lines, nudge), new CardDelegate(m, nudge), WatchUi.SLIDE_UP);
            return;
        }
        WatchUi.requestUpdate();
    }

    // On the settings page UP and DOWN first move between its two buttons, then leave the page.
    function turn(by as Number) as Void {
        if (page == SETTINGS_PAGE && focus == ((by > 0) ? 0 : 1)) {
            focus = (by > 0) ? 1 : 0;
            WatchUi.requestUpdate();
            return;
        }
        page = (page + by + PAGES) % PAGES;
        focus = (by > 0) ? 0 : 1;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Palette.NAVY, Palette.NAVY);
        dc.clear();
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        if (page == 0) {
            drawRing(dc);
        } else if (page == 1) {
            drawSun(dc);
        } else if (page == 2) {
            drawDrinks(dc);
        } else if (page == 3) {
            drawStress(dc);
        } else if (page == 4) {
            drawWeek(dc);
        } else if (page == 5) {
            drawMonth(dc);
        } else if (page == 6) {
            drawSensors(dc);
        } else {
            drawSettings(dc);
        }
        drawDots(dc);
    }

    // Page 1: today's light against the goal, as a well that fills from the bottom.
    private function drawRing(dc as Dc) as Void {
        var m = _model;
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        // Pulled in from the bezel so the page dots fit outside it.
        var r = w / 2 - 18;

        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, r);
        dc.setPenWidth(1);

        var level = 2 * r * m.lightSecs / m.goalSecs;
        if (level > 2 * r) {
            level = 2 * r;
        }
        var surface = cy + r - level;
        // The fill warms through five bands as it rises, and turns green once the goal is met.
        var full = m.lightSecs >= m.goalSecs;
        for (var i = 0; i < 5; i++) {
            var bottom = cy + r - i * 2 * r / 5;
            var top = cy + r - (i + 1) * 2 * r / 5;
            if (top < surface) {
                top = surface;
            }
            if (top >= bottom) {
                break;
            }
            dc.setClip(cx - r, top, 2 * r, bottom - top);
            dc.setColor(full ? Palette.DONE : Palette.WELL[i], Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx, cy, r - 4);
        }

        // The words are drawn twice so they stay readable on both sides of the surface:
        // light on the empty part, navy on the filled part.
        dc.setClip(0, 0, w, surface);
        ringText(dc, false);
        if (level > 0) {
            dc.setClip(0, surface, w, h - surface);
            ringText(dc, true);
        }
        dc.clearClip();
    }

    private function ringText(dc as Dc, onFill as Boolean) as Void {
        var m = _model;
        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;
        var h = dc.getHeight();
        var nudging = !m.why.equals("");
        var bright = onFill ? Palette.NAVY : Graphics.COLOR_WHITE;
        var soft = onFill ? Palette.NAVY : Graphics.COLOR_LT_GRAY;
        var accent = onFill ? Palette.NAVY : Palette.GOLD;

        var state = "INDOORS";
        if (nudging) {
            state = m.hm(m.setMin - m.nowMin()) + " of sun left";
        } else if (m.inLight) {
            state = "LIGHT " + m.lightPct.format("%d") + "%";
        } else if (m.hasFix && !m.sunUp()) {
            state = "SUN DOWN";
        }
        dc.setColor((m.inLight || nudging) ? accent : soft, Graphics.COLOR_TRANSPARENT);
        line(dc, 60, state, 100);

        dc.setColor(bright, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, cy - 8, Graphics.FONT_NUMBER_THAI_HOT, (m.lightSecs / 60).format("%d"));
        dc.setColor(soft, Graphics.COLOR_TRANSPARENT);
        line(dc, cy + 38, nudging ? m.why : "of " + (m.goalSecs / 60).format("%d") + " min", 100);

        var info = "Waiting for GPS";
        if (!m.note.equals("")) {
            info = m.note;
        } else if (m.hasFix) {
            var now = m.nowMin();
            if (m.sunUp()) {
                info = "Sun left " + m.hm(m.setMin - now);
            } else if (now < m.riseMin) {
                info = "Sunrise " + clock(m.riseMin);
            } else {
                info = "Sun is down";
            }
        }
        dc.setColor(bright, Graphics.COLOR_TRANSPARENT);
        line(dc, h - 64, info, 100);

        if (m.demo >= 0) {
            dc.setColor(onFill ? Palette.NAVY : Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            text(dc, cx, h - 38, Graphics.FONT_XTINY, "DEMO x60");
        } else {
            dc.setColor(soft, Graphics.COLOR_TRANSPARENT);
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
            dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
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
        var goalMin = m.goalSecs / 60;
        var base = 168;
        var maxH = 84;
        // A bar is full height at one and a half times the goal.
        var top = goalMin * 3 / 2;

        dc.setColor(m.seeded ? Graphics.COLOR_RED : Palette.GOLD, Graphics.COLOR_TRANSPARENT);
        line(dc, 46, m.seeded ? "7 DAYS (DEMO)" : "LAST 7 DAYS", 122);

        var met = 0;
        for (var i = 0; i < 7; i++) {
            // Left to right: six days ago up to today.
            var mins = m.lightSecs / 60;
            if (i < 6) {
                mins = m.hist[5 - i];
            }
            var color = Graphics.COLOR_DK_GRAY;
            if (mins >= goalMin) {
                met += 1;
                color = Palette.GOLD;
            } else if (i == 6) {
                color = Palette.DIM;
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

    // Page 4: the month as a grid of days. A full dot is a day at goal.
    private function drawMonth(dc as Dc) as Void {
        var m = _model;
        var goalMin = m.goalSecs / 60;

        dc.setColor(m.seeded ? Graphics.COLOR_RED : Palette.GOLD, Graphics.COLOR_TRANSPARENT);
        line(dc, 40, m.seeded ? "30 DAYS (DEMO)" : "LAST 30 DAYS", 122);

        var met = 0;
        var early = 0;
        var late = 0;
        for (var i = 0; i < 30; i++) {
            // Reading order: 29 days ago at the top left, today at the bottom right.
            var mins = (i == 29) ? m.lightSecs / 60 : m.hist[28 - i];
            if (i < 7) {
                early += mins;
            } else if (i >= 23) {
                late += mins;
            }
            var x = 55 + (i % 6) * 30;
            var y = 72 + (i / 6) * 26;
            if (mins >= goalMin) {
                met += 1;
                dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, 10);
            } else if (mins > 0) {
                dc.setColor(Palette.DIM, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, 5);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(x, y, 5);
            }
            if (i == 29) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(x, y, 12);
            }
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        line(dc, 204, met.format("%d") + " of 30 days at goal", 122);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        text(dc, dc.getWidth() / 2, 226, Graphics.FONT_XTINY,
            (early / 7).format("%d") + " min then, " + (late / 7).format("%d") + " now");
    }

    // Page 5: the six sensors and what each one says right now, in words.
    private function drawSensors(dc as Dc) as Void {
        var m = _model;

        dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
        line(dc, 40, "SENSORS", 122);

        var trend = "Steady";
        if (m.baroDelta <= -1.5) {
            trend = "Falling";
        } else if (m.baroDelta >= 1.5) {
            trend = "Rising";
        }
        row(dc, 66, "SOLAR", (m.hasSolar || m.demo >= 0) ? m.lightPct.format("%d") + "%" : "None");
        row(dc, 89, "HEART", (m.hr > 0) ? m.hr.format("%d") + " bpm" : "...");
        row(dc, 112, "GPS", m.hasFix ? m.lat.format("%.2f") + ", " + m.lon.format("%.2f") : "Searching");
        row(dc, 135, "COMPASS", m.hasHeading ? compassWord(m.heading) : "...");
        row(dc, 158, "PRESSURE", m.hasBaro ? trend : "...");
        row(dc, 181, "MOTION", m.moving ? "Moving" : "Still");
        row(dc, 204, "STRESS", (m.stress >= 0) ? m.stress.format("%d") : "...");
    }

    // Coffee and water, logged by hand. A tap on either side adds one.
    private function drawDrinks(dc as Dc) as Void {
        var m = _model;
        var cx = dc.getWidth() / 2;
        var late = m.overCups();

        dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
        line(dc, 40, "DRINKS", 122);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx, 70, cx, 178);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        text(dc, cx - 56, 78, Graphics.FONT_XTINY, "COFFEE");
        text(dc, cx + 56, 78, Graphics.FONT_XTINY, "WATER");
        text(dc, cx + 56, 164, Graphics.FONT_XTINY, "of " + Day.opt("h2o", 8).format("%d"));
        line(dc, 204, "Tap a side to add", 122);

        dc.setColor(Palette.SKY, Graphics.COLOR_TRANSPARENT);
        text(dc, cx + 56, 122, Graphics.FONT_NUMBER_HOT, m.glasses.format("%d"));

        // Coffee turns red once today's cups reach the user's limit.
        dc.setColor(late ? Graphics.COLOR_RED : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        text(dc, cx - 56, 122, Graphics.FONT_NUMBER_HOT, m.cups.format("%d"));
        dc.setColor(late ? Graphics.COLOR_RED : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        text(dc, cx - 56, 164, Graphics.FONT_XTINY,
            (Day.cupLimit() < 0) ? "no coffee" : (late ? "over " : "under ") + Day.cupLimit().format("%d"));
    }

    // Minutes spent tense while sitting still today, and the spell running now.
    private function drawStress(dc as Dc) as Void {
        var m = _model;
        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;
        var h = dc.getHeight();

        dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
        line(dc, 40, "STRESS", 122);

        var now = "No reading";
        if (m.stress >= 0) {
            now = "Stress " + m.stress.format("%d") + (m.moving ? ", moving" : ", still");
        } else if (m.hr > 0) {
            now = "Pulse " + m.hr.format("%d") + (m.moving ? ", moving" : ", still");
        }
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, 64, Graphics.FONT_XTINY, now);

        dc.setColor((m.stretch > 0) ? Palette.DIM : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, cy - 6, Graphics.FONT_NUMBER_THAI_HOT, (m.tenseSecs / 60).format("%d"));
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        line(dc, cy + 38, "min tense and still", 122);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        line(dc, h - 64, (m.stretch > 0) ? "This spell " + (m.stretch / 60).format("%d") + " min" : "No spell right now", 122);
        var after = Day.opt("calm", 15);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        text(dc, cx, h - 40, Graphics.FONT_XTINY, (after > 0) ? "Nudge after " + after.format("%d") + " min" : "Nudge off");
    }

    // What is set now, and two buttons: the settings menu and the setup wizard.
    private function drawSettings(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;
        dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
        line(dc, 40, "SETTINGS", 122);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        line(dc, 72, (Day.goalSecs() / 60).format("%d") + " min a day", 122);
        line(dc, 96, "\"" + Day.action() + "\"", 122);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        line(dc, 120, SettingsDelegate.label(:buzz), 122);
        var names = ["Settings", "Run setup"];
        for (var i = 0; i < 2; i++) {
            var y = BUTTON_Y[i];
            if (i == focus) {
                dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(cx - 75, y - 16, 150, 32, 16);
                dc.setColor(Palette.NAVY, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawRoundedRectangle(cx - 75, y - 16, 150, 32, 16);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }
            text(dc, cx, y, Graphics.FONT_TINY, names[i]);
        }
    }

    // Name on the left of the centre line in grey, reading on the right in white.
    private function row(dc as Dc, y as Number, name as String, value as String) as Void {
        var cx = dc.getWidth() / 2;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 8, y, Graphics.FONT_XTINY, name, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // Coordinates are too long for the usual size.
        var font = (dc.getTextWidthInPixels(value, Graphics.FONT_TINY) > 100) ? Graphics.FONT_XTINY : Graphics.FONT_TINY;
        dc.drawText(cx + 8, y, font, value, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawDots(dc as Dc) as Void {
        var cy = dc.getHeight() / 2;
        for (var i = 0; i < PAGES; i++) {
            dc.setColor((i == page) ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(7, cy - (PAGES - 1) * 6 + i * 12, 3);
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

    private function compassWord(az as Float) as String {
        var names = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
        var i = ((az + 22.5) / 45.0).toNumber() % 8;
        return names[i];
    }

}
