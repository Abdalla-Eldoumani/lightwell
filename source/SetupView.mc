import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

// The first-run guide: a small sun asks three questions, one per screen, then shows the plan.
class SetupView extends WatchUi.View {

    var step as Number = 0;     // 0 to 2 are the questions, 3 is the plan
    var sel as Number = 0;      // highlighted answer

    private const ASK = ["How do you get around?", "Daylight on a workday?", "How should I nudge you?"];
    private const ANSWERS = [["On foot", "By wheelchair", "Mostly indoors"],
                             ["Almost none", "Some", "Plenty"],
                             ["Buzz and tone", "Soft buzz", "Screen only"]];

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        sun(dc, cx, 44);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (step > 2) {
            put(dc, 90, Graphics.FONT_MEDIUM, "You are set");
            put(dc, 124, Graphics.FONT_TINY, (Day.goalSecs() / 60).format("%d") + " min of light a day");
            put(dc, 150, Graphics.FONT_TINY, "Nudge: " + Day.action());
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            put(dc, 196, Graphics.FONT_TINY, "Press START");
            return;
        }

        put(dc, 86, Graphics.FONT_TINY, ASK[step]);
        for (var i = 0; i < 3; i++) {
            var y = 120 + i * 32;
            if (i == sel) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(cx - 90, y - 14, 180, 28, 14);
            }
            dc.setColor((i == sel) ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            put(dc, y, Graphics.FONT_TINY, ANSWERS[step][i]);
        }
        for (var i = 0; i < 3; i++) {
            dc.setColor((i == step) ? Graphics.COLOR_YELLOW : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx - 12 + i * 12, 226, 3);
        }
    }

    // The guide: a sun with a face.
    private function sun(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        for (var k = 0; k < 8; k++) {
            var a = k * Math.PI / 4;
            dc.drawLine(x + (19 * Math.cos(a)).toNumber(), y + (19 * Math.sin(a)).toNumber(),
                x + (25 * Math.cos(a)).toNumber(), y + (25 * Math.sin(a)).toNumber());
        }
        dc.fillCircle(x, y, 15);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 5, y - 3, 2);
        dc.fillCircle(x + 5, y - 3, 2);
        dc.setPenWidth(2);
        dc.drawArc(x, y + 1, 7, Graphics.ARC_COUNTER_CLOCKWISE, 200, 340);
        dc.setPenWidth(1);
    }

    private function put(dc as Dc, y as Number, font as Graphics.FontType, s as String) as Void {
        dc.drawText(dc.getWidth() / 2, y, font, s, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

}
