import Toybox.Application;
import Toybox.Lang;

// Sample history for the pitch. It is only ever loaded from the settings menu,
// and the week and month pages label it as demo data while it is in place.
module DemoData {

    // One user's first month, in minutes of light, yesterday first: almost nothing
    // in week one, most days at goal by week four, with two missed days on the way.
    const MONTH = [25, 22, 19, 14, 0, 16, 12,
                   20, 18, 11, 15, 9, 12, 10,
                   14, 12, 10, 0, 11, 9, 5,
                   8, 6, 0, 3, 4, 0, 2, 1] as Array<Number>;

    function month() as Void {
        // Replay the month, oldest day first, with the streak rule Day.roll uses.
        var goal = Day.goalSecs() / 60;
        var streak = 0;
        var miss = 0;
        for (var i = MONTH.size() - 1; i >= 0; i--) {
            if (MONTH[i] >= goal) {
                streak += 1;
                miss = 0;
            } else {
                miss += 1;
                if (miss >= 2) {
                    streak = 0;
                }
            }
        }
        Application.Storage.setValue("hist", MONTH as Array<Application.Storage.ValueType>);
        Application.Storage.setValue("streak", streak);
        Application.Storage.setValue("miss", miss);
        Application.Storage.setValue("day", Day.today());
        Application.Storage.setValue("light", 420);
        Application.Storage.setValue("move", 180);
        Application.Storage.setValue("seeded", 1);
    }

}
