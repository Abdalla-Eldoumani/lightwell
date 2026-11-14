# Demo and presentation plan

How we finish Lightwell before pitching starts at 4:00 PM, and how we present it. What the app does and why is in debrief.md. Each person's task list is in the four handoff files in this folder.

Rule: build on the app that already works. Anything new must be showable in the simulator in under 30 seconds. If it can't be, cut it.

## What we are building

Three streams. The app streams are about polish: how it looks, how a nudge lands, and how setup fits the app to the person.

1. **Screens and nudges.** The four pages, the nudge that says why it fired, tone and vibration, and "goal met" shown as a change of shape.
2. **Setup and personal settings.** Three questions on first run (how you get around, how much daylight you get, how to nudge you) that set the wording, the goal and the alerts. The same values in settings on hold UP.
3. **Pitch.** Three slides and a 3-minute script built around the live demo.

## What we cut, and why

- **Coffee, water and the caffeine cutoff.** Typed in by hand, no sensor, and a caffeine tracker is already in the Connect IQ store.
- **The breathing guide and a stress page.** Garmin watches already have breathing exercises, and the fenix7pro simulator has no stress history.
- **A ten-question setup.** Three questions take ten seconds and change everything the user sees.
- **One file per page and a 17-key settings schema.**

## Who does what

| Who | Stream | Owns | Handoff |
|---|---|---|---|
| Abdalla | 1. Screens and nudges | LightwellView, LightwellModel, LightwellDelegate, LightwellApp, LightwellService, Day; every merge | handoff-build.md |
| David | 2. Setup and settings | SetupDelegate, SettingsDelegate | handoff-setup.md |
| TomCruiseTorpedo | 3. Pitch | Slides, script, rehearsals | handoff-pitch.md |
| Yaseen | Simulator for 1 and 2, live demo for 3 | Screenshots, checklist, backup recording | handoff-simulator.md |

Swap names if the roles do not suit. The file ownership is what matters: no two people edit the same file.

## Timeline

| Time | What happens |
|---|---|
| Now | Everyone pulls main and reads their handoff. Yaseen sends screenshots |
| to 2:45 | Build and polish. Slides and script |
| 2:45 | Feature freeze. After this, only fixes for bugs that break the demo |
| 2:45 to 3:05 | Backup recording. Docs updated to what shipped |
| 3:05 to 3:50 | Three timed rehearsals |
| 4:00 | Pitching starts |

## What the simulator can show

- **Vibration.** The simulator window shakes when the app vibrates, according to Garmin's developer forum. https://forums.garmin.com/developer/connect-iq/f/discussion/272906/how-to-test-vibration-with-connect-iq-device-simulator
- **Sound.** One forum report says the simulator plays tones. It did not say on which system, so test it on the demo laptop. https://forums.garmin.com/developer/connect-iq/f/discussion/317894/why-do-tones-not-play-on-the-watch-but-do-in-the-simulator
- **Not shown:** the background service, unless a background event is triggered from the Simulation menu.

## Design notes from the research

- Put the whole answer on one screen and keep navigation flat. https://developer.apple.com/design/human-interface-guidelines/designing-for-watchos
- Do one or two jobs, and make every task finish in seconds. https://developer.android.com/design/ui/wear/guides/get-started/design-for-wearables/principles
- Progress that hugs the round edge, bold type for the one number that matters, two or three colours. https://android-developers.googleblog.com/2025/08/introducing-material-3-expressive-for-wear-os.html
- A missed day should not wipe out progress, and the app should say when you have done enough. One reviewer's account of the Gentler Streak app. https://digitaltrends.com/mobile/apple-watch-fitness-recovery-problem-gentler-streak-app-fix
- We did not find a source specific to the second half of 2026, and the translucent look of watchOS 26 does not apply to a 64-colour screen.

## Presentation

Three minutes, then questions. The script, the demo steps, the numbers and the answers are in handoff-pitch.md. Backup: a screen recording of the demo path.
