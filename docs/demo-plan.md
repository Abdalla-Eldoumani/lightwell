# Demo and presentation plan

How we finish Lightwell before pitching starts at 4:00 PM, and how we present it. What the app does and why is in debrief.md. Each person's task list is in the four handoff files in this folder.

Rule: build on the app that already works. Anything new must be showable in the simulator in under 30 seconds. If it can't be, cut it.

## What we are adding, and only this

1. **A nudge that says why it fired.** "Sitting an hour, 4h of sun left. Step outside." The triggers stay as they are (move bar up, sun up, ring not full). The reason goes in the text.
2. **Three settings on the watch**, reached by holding UP: goal (10, 20 or 30 minutes), wording (walk, roll, find a window), vibration (normal, soft, off). This is our answer to the mentor's question about people with disabilities and different lifestyles.
3. **Optional, only if 1 and 2 are done by 2:00:** current stress as a second trigger for the same nudge.

## What we cut, and why

- **Coffee, water and the caffeine cutoff.** They are typed in by hand and use no sensor, and a caffeine tracker is already in the Connect IQ store. Our pitch is that the watch measures the habit with no input.
- **The breathing guide.** Garmin watches already have breathing exercises.
- **The ten-question setup.** Ten screens before the user sees anything. The defaults work on first launch and the three settings cover the rest.
- **One file per page and the 17-key settings schema.** They rewrite code that works and give a judge nothing to see.
- **A stress page.** The fenix7pro simulator has no stress history, so the page would show invented data.
- **Three tones for every message.**

## Who does what

One person edits the files in source/. Everyone else works in the simulator, on the pitch, or with the mentor, so no two people change the same file.

| Who | Owns | Delivers | Handoff |
|---|---|---|---|
| Abdalla | Everything in source/ and resources/, every merge to main | Fixes from the first run-through, the settings menu, the nudge with its reason | handoff-build.md |
| Yaseen | Simulator and demo | Runs every build, screenshots each page, tests the background event, drives the demo, records the backup video | handoff-simulator.md |
| David | Pitch | 3-minute script, slides, answers to likely questions, docs updated to what shipped | handoff-pitch.md |
| TomCruiseTorpedo | Mentor and wording | Sensor readings from Josh for the light threshold, the walk, roll and window texts, the name check | handoff-mentor.md |

## Timeline

| Time | What happens |
|---|---|
| 1:00 to 1:15 | Everyone reads their handoff. Yaseen runs the current build and sends screenshots of all four pages to Abdalla |
| 1:15 to 2:15 | Build: fixes, settings menu, nudge with reason. Pitch draft. Josh's numbers |
| 2:15 to 2:30 | Everything on main. Full demo path in the simulator |
| 2:30 | Feature freeze. After this, only fixes for bugs that break the demo |
| 2:30 to 3:00 | Backup recording. Docs and README updated to what shipped |
| 3:00 to 3:45 | Three timed rehearsals |
| 4:00 | Pitch |

## Presentation: 3 minutes, then questions

| Time | Part |
|---|---|
| 0:00 | **Hook.** One true line from one of us about a day indoors. Then: "Today in Calgary the sun rose at 8:50, sets at 5:51, and never gets above 21 degrees." |
| 0:25 | **Idea.** "Garmin built a sensor that charges the watch with sunlight. We use it for the person wearing it." |
| 0:40 | **Live demo, 90 seconds.** The ring fills and the watch buzzes at the goal. The nudge fires and says why. The sun finder turns with the compass. The week page (say "sample data"). The sensors page, naming each sensor's job. The wording setting switched to "roll". |
| 2:10 | **Measuring it.** Days at goal per week, over 30 days. |
| 2:35 | **Limits.** Simulator only. The light threshold is not calibrated. In the background one reading stands for 5 minutes. |
| 2:50 | **Close.** One line to remember. |

Do not say:

- That we are the first app to read the solar sensor. A watch face called SolarDay already reads it.
- Anything about UV or vitamin D. The sensor cannot measure either.
- That light lowers stress. We have no source for it.

Backup: a screen recording of the demo path, in case the simulator fails on stage.
