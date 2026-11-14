import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class DaylightApp extends Application.AppBase {

    private var _model as DaylightModel;

    function initialize() {
        AppBase.initialize();
        _model = new DaylightModel();
    }

    function onStart(state as Dictionary?) as Void {
        _model.start();
    }

    function onStop(state as Dictionary?) as Void {
        _model.stop();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new DaylightView(_model);
        return [ view, new DaylightDelegate(view, _model) ];
    }

}
