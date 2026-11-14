import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// A full-screen notice: the nudge to go outside, or the goal being reached.
class CardView extends WatchUi.View {

    private var _title as String;
    private var _lines as Array<String>;
    private var _nudge as Boolean;
    private var _logo as WatchUi.BitmapResource or Graphics.BitmapReference or Null;

    function initialize(title as String, lines as Array<String>, nudge as Boolean) {
        View.initialize();
        _title = title;
        _lines = lines;
        _nudge = nudge;
    }

    function onLayout(dc as Dc) as Void {
        _logo = WatchUi.loadResource(Rez.Drawables.Logo) as WatchUi.BitmapResource or Graphics.BitmapReference;
    }

    function onUpdate(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;
        var mid = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(Palette.NAVY, Palette.NAVY);
        dc.clear();
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        var logo = _logo;
        if (logo != null) {
            dc.drawBitmap(cx - 38, 14, logo);
        }

        dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(cx - 104, 91, 208, 30, 15);
        dc.setColor(Palette.NAVY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 106, Graphics.FONT_SMALL, _title, mid);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var gap = (_lines.size() > 2) ? 23 : 26;
        for (var i = 0; i < _lines.size(); i++) {
            dc.drawText(cx, 142 + i * gap, Graphics.FONT_TINY, _lines[i], mid);
        }
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 211, Graphics.FONT_XTINY, _nudge ? "START: going   BACK: later" : "Press START", mid);
    }

}
