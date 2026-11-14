import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// The first-run guide: a welcome, one question per screen, then the plan.
class SetupView extends WatchUi.View {

    var step as Number = 0;     // 0 is the welcome, then one per question, then the plan
    var sel as Number = 0;      // highlighted answer

    // Wheelchair wording lives only in settings.
    private const ASK = ["How do you get light?", "Daylight on a workday?", "How should I nudge you?",
                         "Coffee a day?", "Water a day?", "Tense and sitting still?", "Nudges at night?"];
    private const ANSWERS = [["Walk outside", "Sitting by a window", "I don't get much sunlight"],
                             ["Almost none", "Some", "Plenty"],
                             ["Buzz and tone", "Soft buzz", "Screen only"],
                             ["Less than 2 cups", "Less than 4 cups", "I don't drink coffee"],
                             ["6 glasses", "8 glasses", "10 glasses"],
                             ["Nudge after 15 min", "Nudge after 30 min", "Don't nudge"],
                             ["No, let me sleep", "Yes"]];
    // The setting each question stores, and the value behind each answer.
    // For "words", little sun gets "Step outside".
    const KEYS = ["words", "goal", "buzz", "cups", "h2o", "calm", "night"];
    const VALUES = [[0, 2, 3], [10, 20, 30], [0, 1, 2], [2, 4, -1], [6, 8, 10], [15, 30, -1], [0, 1]];
    const ROW_Y = 112;          // centre of the first answer row
    const ROW_H = 28;

    // How many answers the current question has.
    function count() as Number {
        return asking() ? ANSWERS[step - 1].size() : 1;
    }

    // True while a question is on screen.
    function asking() as Boolean {
        return step >= 1 && step <= ASK.size();
    }

    private var _logo as WatchUi.BitmapResource or Graphics.BitmapReference or Null;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        _logo = WatchUi.loadResource(Rez.Drawables.Logo) as WatchUi.BitmapResource or Graphics.BitmapReference;
    }

    function onUpdate(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;
        dc.setColor(Palette.NAVY, Palette.NAVY);
        dc.clear();
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        var logo = _logo;
        if (logo != null) {
            dc.drawBitmap(cx - 38, 10, logo);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (step == 0) {
            put(dc, 88, Graphics.FONT_TINY, "Welcome to");
            put(dc, 114, Graphics.FONT_MEDIUM, "Lightwell");
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            put(dc, 146, Graphics.FONT_XTINY, "Let's personalize");
            put(dc, 164, Graphics.FONT_XTINY, "your app");
            button(dc, 204, "Start");
            return;
        }
        if (step > ASK.size()) {
            put(dc, 90, Graphics.FONT_MEDIUM, "You are set");
            put(dc, 124, Graphics.FONT_TINY, (Day.goalSecs() / 60).format("%d") + " min of light a day");
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            put(dc, 152, Graphics.FONT_XTINY, "Change it in Settings");
            put(dc, 170, Graphics.FONT_XTINY, "at any time");
            button(dc, 204, "Done");
            return;
        }

        var answers = ANSWERS[step - 1];
        put(dc, 84, Graphics.FONT_TINY, ASK[step - 1]);
        for (var i = 0; i < answers.size(); i++) {
            var y = ROW_Y + i * ROW_H;
            if (i == sel) {
                dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
                var pw = dc.getTextWidthInPixels(answers[i], Graphics.FONT_TINY) + 28;
                if (pw < 180) {
                    pw = 180;   // long answers get a wider highlight
                }
                dc.fillRoundedRectangle(cx - pw / 2, y - 13, pw, 26, 13);
            }
            dc.setColor((i == sel) ? Palette.NAVY : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            put(dc, y, Graphics.FONT_TINY, answers[i]);
        }
        var n = ASK.size();
        for (var i = 0; i < n; i++) {
            dc.setColor((i == step - 1) ? Palette.GOLD : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx - (n - 1) * 6 + i * 12, 226, 3);
        }
    }

    private function button(dc as Dc, y as Number, s as String) as Void {
        dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(dc.getWidth() / 2 - 60, y - 15, 120, 30, 15);
        dc.setColor(Palette.NAVY, Graphics.COLOR_TRANSPARENT);
        put(dc, y, Graphics.FONT_TINY, s);
    }

    private function put(dc as Dc, y as Number, font as Graphics.FontType, s as String) as Void {
        dc.drawText(dc.getWidth() / 2, y, font, s, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

}
