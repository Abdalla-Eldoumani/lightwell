import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// The first-run guide: the logo sits above three questions, one per screen, then the plan.
class SetupView extends WatchUi.View {

    var step as Number = 0;     // 0 to 2 are the questions, 3 is the plan
    var sel as Number = 0;      // highlighted answer

    // The first question asks what kind of break suits the user, not what their body can do.
    private const ASK = ["My kind of light break", "Daylight on a workday?", "How should I nudge you?"];
    private const ANSWERS = [["A walk outside", "A roll outside", "A seat by a window"],
                             ["Almost none", "Some", "Plenty"],
                             ["Buzz and tone", "Soft buzz", "Screen only"]];

    private var _logo as WatchUi.BitmapResource or Graphics.BitmapReference or Null;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        _logo = WatchUi.loadResource(Rez.Drawables.Logo) as WatchUi.BitmapResource or Graphics.BitmapReference;
    }

    function onUpdate(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        var logo = _logo;
        if (logo != null) {
            dc.drawBitmap(cx - 38, 10, logo);
        }

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

    private function put(dc as Dc, y as Number, font as Graphics.FontType, s as String) as Void {
        dc.drawText(dc.getWidth() / 2, y, font, s, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

}
