# Daylight debrief

Tech Thursday x Garmin Hackathon, Calgary, November 14, 2026. Target: fēnix 7 Pro (Connect IQ API 5.2, 260 × 260 round MIP screen).

This file records what we built, what we decided to add, and why. The build schedule and the pitch are in [demo-plan.md](demo-plan.md).

## The idea

On hackathon day the sun in Calgary rose at 8:50 AM, set at 5:51 PM, and never got higher than 21°. A desk worker can easily spend all of that daylight indoors. The fēnix 7 Pro already measures sunlight so it can charge itself. Daylight reads that same sensor.

We started with a sunlight counter. The brainstorm turned it into a **context-aware desk recovery app**: the watch reads its sensors and nudges you when your body needs a break, instead of on a fixed timer. Timer reminders are easy to ignore. A nudge that says why it fired, and gives one action that covers several goals at once, is harder to ignore.

## What exists today

| Feature | What it does | Code |
|---|---|---|
| Light ring | Minutes of light today against a 20-minute goal, sun time left, streak (one missed day is forgiven) | `source/DaylightView.mc` `drawRing` |
| Sun finder | Where the sun is from where you stand, rotated by the compass, plus its height and sunset time | `drawSun`; sun position in `DaylightModel.updateSun` (NOAA formulas) |
| Week | Six finished days and today, drawn against the goal line | `drawWeek`; history in `source/Day.mc` |
| Sensors | Live readings: solar, heart rate, GPS, barometer trend, movement, compass | `drawSensors` |
| Nudges | Vibrates when you have been sitting, the sun is up and the ring is not full. Asks you to uncover the watch when you are walking outside but the sensor reads dark | `DaylightModel.checkNudge`, `checkSleeve` |
| Background | Reads the sensor every 5 minutes while the app is closed (the shortest interval Connect IQ allows) | `source/DaylightService.mc` |
| Day rollover | Files the finished day into history, settles the streak, clears today's counters | `Day.roll()` |
| Demo mode | START steps a fake light level (off, 0, 15, 60, 100) and runs time 60× faster | `source/DaylightDelegate.mc`, `DaylightModel.cycleDemo` |

## What we track

The follow-up analysis narrowed the early brainstorm to these pillars.

### Sunlight and outdoor time (built)

Based on `System.getSystemStats().solarIntensity`. The value is a charging efficiency from 0 to 100, not lux and not UV, so we call it "light exposure." Any UV figure we show is an estimate. The threshold of 5 ("brighter than a room") has not been calibrated on a real watch.

### Stress and cognitive burnout (planned)

- Source: `SensorHistory.getStressHistory()`. Check that the API exists with `has` before calling it.
- Rule: if stress stays above 65 for 45 minutes and you have not moved, the stress is mental rather than physical. The watch starts a 60-second box-breathing guide (inhale, hold, exhale, hold) paced by vibrations.
- Shown: current stress, a 4-hour trend, and when the last breathing session happened.

### Caffeine cutoff and sleep protection (planned)

- **During setup the user sets a daily coffee limit** (0 to 5+ cups) and logs each cup with one tap (+1 coffee).
- Caffeine cutoff = bedtime − N hours (both configurable).
- In the afternoon, energy nudges become wind-down nudges.
- A cup over the limit, or after the cutoff, gets a gentle warning.

### Hydration (planned)

- **During setup the user sets a daily water goal** (4 to 12 glasses or bottles) and logs each one with one tap (+1 water).
- Progress = glasses logged ÷ goal.

Coffee and water counts reset at day rollover (`Day.roll()`). Each day's totals are kept in history so the week page can show them.

### Ideas we set aside

These came up in the early brainstorm and are out of scope for the demo: 20-20-20 eye-strain breaks, posture micro-breaks, latitude and winter presets, office and remote-work modes, weighted "vitality score," and hydration goals that rise after workouts or in hot weather.

## Visualization

The app keeps its current UP/DOWN page carousel. Every page has to be readable at a glance on a 260 px round MIP screen.

| Page | Content | Status |
|---|---|---|
| Today | Rings for light, stress and drinks. The light ring already exists | Extend |
| Sun finder | Sun direction, height and sunset time | Built |
| Stress | Current value, 4-hour trend, last breathing session | New |
| Coffee & water | "2 of 3 coffees", "5 of 8 waters" as arcs or cup icons, plus the countdown to the caffeine cutoff and to bedtime | New |
| Week | Daily light bars against the goal. Later: stress and drinks per day | Extend |
| Sensors | Raw readings. Kept for the judges | Built |
| Glance | One summary card in the glance list | Stretch |

## First-run setup

Setup runs the first time the app opens. It should read like a short conversation: one multiple-choice question per screen with friendly wording, built on `WatchUi.Menu2`. The answers set the notification behavior. The same keys go in `resources/settings/properties.xml` and `settings.xml`, so users can change them later from Garmin Connect Mobile.

| Question | Options | Sets |
|---|---|---|
| What do you want to track? | Light / Stress / Coffee & water | `trackLight`, `trackStress`, `trackCoffee`, `trackWater` |
| Is there anything we should adapt for? (optional) | None / Wheelchair user / Limited mobility / Sensory-sensitive / Prefer not to say | `mobilityMode`, `hapticLevel` |
| When do you work? | 9–5 / Early / Late / Shifts | `workStart`, `workEnd` |
| Do you do outdoor activities? | Often / Sometimes / Rarely | `outdoorLevel` (light goal, how often to nudge) |
| Notifications at night? | Yes / No | `nightNotifs` (quiet hours) |
| Track coffee or water? | Both / Coffee / Water / Neither | which items appear in the log menu |
| How many coffees a day? | 0 / 1 / 2 / 3 / 4 / 5+ | `coffeeLimit` |
| How many waters a day? | 4 / 6 / 8 / 10 / 12 | `waterGoal` |
| Do you drink coffee at night? | Yes / No | `coffeeAtNight` (cutoff warnings) |
| What tone should nudges have? | Gentle / Coach / Direct | `tone` |

Future work: with a language model behind it, setup could be a free-text conversation instead of fixed choices.

## Notifications

- **Per-pillar switches.** Each pillar can be turned on or off.
- **Quiet hours.** Taken from work hours and the night-notification answer.
- **Tone.** Every message is written three ways: gentle, coach and direct.
- **Haptic strength.** Sensory-sensitive users get soft, short pulses.
- **Combined nudges (the main selling point).** Several separate alerts cause notification fatigue. A rule engine checks every pillar and sends one message with one action:
  - *Lunchtime Trifecta*: almost no light all morning, steps behind and water behind at 12:30 → "15-minute walk outside and a bottle refill: light and movement goals done."
  - *Stress-Walk*: high stress with no light → "Step outside for 5 minutes. Light and movement lower stress faster than staying at your desk."
  - *Coffee after cutoff*: a cup logged after the cutoff → "This one may cost you sleep. Water instead?"
- **Limit.** While the app is closed it can only call `Background.requestApplicationWake(message)`, at most once every 5 minutes. The richer nudges need the app to be open.

## Inclusivity

The mentor asked us to consider women, people with disabilities and different lifestyles. The optional adaptation question in setup handles most of this. It is saved in the configuration and can be changed in settings. "Prefer not to say" keeps the defaults.

- **Wheelchair users and limited mobility.** Prompts never say "walk." Movement counts wheelchair pushes. Breaks suggest upper-body stretches, and light prompts say "find a window" or "roll outside."
- **Sensory-sensitive.** Soft vibrations, fewer nudges, and focus windows with no interruptions.
- **Shift workers.** Work hours set the active window, so the app does not assume a 9-to-5 day.

## Known limits

- `solarIntensity` is not lux or UV, and the cut-off value is not calibrated.
- In the background, one reading counts for the whole 5 minutes since the previous one.
- A sleeve covers the sensor. The app can ask you to uncover the watch but cannot read light through fabric.
- Stress history depends on the device and its settings, so the app must handle having none.
- Coffee and water depend on the user logging them by hand.
- So far the app has only run in the simulator.
