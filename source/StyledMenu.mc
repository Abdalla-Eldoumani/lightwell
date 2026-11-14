import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// A menu drawn in the wizard's colours: navy background, gold title, gold pill on the focused row.
class StyledMenu extends WatchUi.CustomMenu {

    private var _title as String;

    function initialize(title as String) {
        CustomMenu.initialize(56, Palette.NAVY, {});
        _title = title;
    }

    function drawTitle(dc as Dc) as Void {
        dc.setColor(Palette.NAVY, Palette.NAVY);
        dc.clear();
        dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 + 8, Graphics.FONT_TINY, _title,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

}

// One row of a StyledMenu: a label with an optional line under it.
class StyledItem extends WatchUi.CustomMenuItem {

    private var _label as String;
    private var _sub as String?;

    function initialize(label as String, sub as String?, id as Object) {
        CustomMenuItem.initialize(id, {});
        _label = label;
        _sub = sub;
    }

    function getLabel() as String {
        return _label;
    }

    function setSubLabel(sub as String or ResourceId or Null) as Void {
        _sub = sub as String?;
        WatchUi.requestUpdate();
    }

    function draw(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var focused = isFocused();
        if (focused) {
            dc.setColor(Palette.GOLD, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(10, 4, w - 20, h - 8, (h - 8) / 2);
        }
        var sub = _sub;
        var labelY = (sub != null) ? h / 2 - 10 : h / 2;
        dc.setColor(focused ? Palette.NAVY : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, labelY, fit(dc, _label, Graphics.FONT_TINY), _label,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        if (sub != null) {
            dc.setColor(focused ? Palette.NAVY : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h / 2 + 12, Graphics.FONT_XTINY, sub, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // The given font, or the smallest one when the text would run past the pill.
    private function fit(dc as Dc, s as String, font as Graphics.FontType) as Graphics.FontType {
        return (dc.getTextWidthInPixels(s, font) > dc.getWidth() - 40) ? Graphics.FONT_XTINY : font;
    }

}
