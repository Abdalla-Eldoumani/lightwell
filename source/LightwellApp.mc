import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

(:background)
class LightwellApp extends Application.AppBase {

    // Stays null in the background process, which never builds a view.
    private var _model as LightwellModel?;

    function initialize() {
        AppBase.initialize();
    }

    // Only ever runs in the app, never in the background service.
    (:typecheck(disableBackgroundCheck))
    function onStop(state as Dictionary?) as Void {
        var m = _model;
        if (m != null) {
            m.stop();
        }
    }

    // Only ever runs in the app, never in the background service.
    (:typecheck(disableBackgroundCheck))
    function getInitialView() as [Views] or [Views, InputDelegates] {
        try {
            Background.registerForTemporalEvent(new Time.Duration(300));
        } catch (e) {
            // Without the schedule the app still counts while it is open.
        }
        var m = new LightwellModel();
        m.start();
        _model = m;
        if (Day.num("setup") == 0) {
            return [ SetupDelegate.menu(0), new SetupDelegate(m, 0, false) ];
        }
        var view = new LightwellView(m);
        return [ view, new LightwellDelegate(view, m) ];
    }

    function getServiceDelegate() as [System.ServiceDelegate] {
        return [ new LightwellService() ];
    }

}
