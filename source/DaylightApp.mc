import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

(:background)
class DaylightApp extends Application.AppBase {

    // Stays null in the background process, which never builds a view.
    private var _model as DaylightModel?;

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
        var m = new DaylightModel();
        m.start();
        _model = m;
        var view = new DaylightView(m);
        return [ view, new DaylightDelegate(view, m) ];
    }

    function getServiceDelegate() as [System.ServiceDelegate] {
        return [ new DaylightService() ];
    }

}
