# Handoff: build (Abdalla)

You are the only person who edits source/ and resources/, and the only one who merges to main. Everyone else's work feeds yours.

## Now

1. In Git Bash: git pull. The docs were merged on GitHub, so main moved.
2. Run the app with Yaseen and look at his screenshots of all four pages. Fix what is wrong before adding anything.

## Build, 1:15 to 2:15, in this order

1. **Settings menu on hold UP.** Goal: 10, 20, 30. Wording: walk, roll, window. Vibration: normal, soft, off. "Clear today" moves into this menu. Store the values with Application.Storage and read them through one small Config file. No settings.xml.
2. **Nudge with its reason.** "Sitting 1h, 4h of sun left", then the action line from the wording table in handoff-mentor.md. The triggers stay as they are.
3. **Rename.** If the team has settled on Lightwell, change AppName in resources/strings/strings.xml and the README title. Leave class and file names alone.
4. **Threshold.** When Josh's numbers arrive, change LIGHT_MIN in source/Day.mc. It is one constant.
5. **Only if 1 to 4 are done by 2:00:** current stress as a second trigger for the nudge.

## Rules

- One file per commit. Never commit bin/.
- Build with no warnings before every push. Tell Yaseen after every push so he reruns his checklist.
- 2:30 is the feature freeze. After that, only fixes for something that breaks the demo.

## Done when

Yaseen has seen every change run in the simulator, and the full demo path works twice in a row.
