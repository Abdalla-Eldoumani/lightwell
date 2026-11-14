# Demo and presentation plan

How we finish Daylight before the **4:00 PM** deadline and how we present it. What we are building and why is in [debrief.md](debrief.md).

**Rule:** build on the app that already works. Each new feature must be demoable in the simulator in under 30 seconds, using demo mode. If a feature can't be, cut it.

## Phase 0: shared foundation (blocks everything else)

About 45 minutes, done by one person. Everyone else designs screens, writes copy or starts the slides. Phase 0 is merged before any track starts. Its job is to fix the data contract and decide who owns which file, so that no two people edit the same file.

1. **Settings schema.** Create `resources/settings/properties.xml` and `settings.xml` with every key, its type and its default value:
   `trackLight`, `trackStress`, `trackCoffee`, `trackWater`, `workStart`, `workEnd`, `outdoorLevel`, `nightNotifs`, `coffeeLimit`, `waterGoal`, `coffeeAtNight`, `bedtime`, `cutoffHours`, `tone` (gentle/coach/direct), `mobilityMode` (none/wheelchair/limited/sensory/undisclosed), `hapticLevel`, `wizardDone`.
2. **`source/Config.mc`.** One typed getter per key, reading `Application.Properties` with defaults. All config reads go through this file.
3. **Storage and rollover in `source/Day.mc`.** Add the keys `coffee`, `water`, `stressMin` and `lastBreath`, reset them in `Day.roll()`, and keep a history array for each pillar. List every key name in a comment at the top of the file. That comment is the contract.
4. **Model fields in `source/DaylightModel.mc`.** Add public fields (`stress`, `stressHighMin`, `coffee`, `water`, …) and empty stub methods: `readStress()`, `logCoffee()`, `logWater()`, `checkCombos()`. Call the stubs from `tick()` now, so the tracks only fill in method bodies.
5. **One file per page.** Move each `draw*` function out of `DaylightView.mc` into `source/pages/` (`RingPage.mc`, `SunPage.mc`, `WeekPage.mc`, `SensorsPage.mc`), and add stubs for `StressPage.mc` and `DrinksPage.mc`. Each file is a module with `draw(dc, model)`. The view only picks the page by index.
6. **`source/Nudge.mc`.** `Nudge.send(id)` looks up the message for that id and the user's tone, respects quiet hours and `hapticLevel`, and vibrates. Add a placeholder message table to `strings.xml`.

**Done when:** the app builds and runs on `fenix7pro` in the simulator and behaves as before, with the two new pages present but empty.

## Phase 1: parallel tracks

Each track owns its files. To change a file you don't own, ask its owner first.

| Track | Owns | Delivers | Time |
|---|---|---|---|
| **A. Visualization** | `source/pages/*` | Multi-ring Today page, Stress page (4-hour trend), Coffee & water page ("2 of 3 coffees", "5 of 8 waters", cutoff countdown), Week page with every pillar, wording that changes with `mobilityMode` | 2 h |
| **B. Configuration** | `source/Wizard*.mc`, `resources/settings/*` | First-run `Menu2` setup with every question from the debrief (adaptation question, coffee limit, water goal and tone included), answers saved to Properties, option to rerun setup from the menu | 2 h |
| **C. Data and logging** | stub bodies in `DaylightModel.mc`, `DaylightDelegate.mc` | `readStress()` with `getStressHistory` (checked with `has` first), START quick-log menu (+1 coffee, +1 water, undo, breathe), 60-second breathing session paced by vibration, demo mode that fakes stress and time of day | 2 h |
| **D. Notifications** | `Nudge.mc`, `strings.xml`, `DaylightService.mc` | Gentle, coach and direct message tables; combined rules in `checkCombos()` (Lunchtime Trifecta, Stress-Walk, coffee after cutoff); quiet hours; background wake messages | 2 h |
| **E. Pitch** | `docs/`, slides | Script, slides, backup screen recording | Ongoing |

If there are fewer people than tracks, combine C with D first, then A with B.

### Checkpoints

| Time | What happens |
|---|---|
| Phase 0 merged | Tracks start |
| ~2:30 PM | Merge all tracks and run the full demo path in the simulator |
| ~3:15 PM | Code freeze. Only fixes for bugs that break the demo after this |
| 3:15–4:00 PM | Record the backup video and rehearse twice |

Stretch goals, only once everything above works: glance view, weighted vitality score.

## Presentation (3 to 5 minutes)

1. **Hook, 30 s.** Today in Calgary: sunrise 8:50, sunset 5:51, sun never above 21°. "Your watch already measures sunlight so it can charge itself."
2. **Problem, 30 s.** Desk workers ignore reminders that fire on a timer, and many separate alerts lead to notification fatigue.
3. **Live demo, 2 min.** Simulator on the projector, real watch in hand:
   - The light ring fills in demo mode at 60× speed.
   - A faked stress spike starts the breathing guide, which vibrates the watch.
   - The combined Stress-Walk nudge fires.
   - A coffee logged after the cutoff gets a warning, and the count changes (for example 3 of 3).
   - The sun finder turns with the compass.
4. **Configuration and inclusivity, 45 s.** Setup screens, including the adaptation question; the three tones; wheelchair and sensory-sensitive modes.
5. **Limits and next steps, 30 s.** `solarIntensity` is not lux or UV and still needs calibration. Next: setup as a conversation backed by a language model.

**Backup:** a screen recording of the demo path, in case the simulator or the watch fails on stage.
