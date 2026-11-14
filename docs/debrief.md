# Lightwell debrief

Tech Thursday x Garmin Hackathon, Calgary, November 14, 2026. Target: fenix 7 Pro (Connect IQ API 5.2, 260 x 260 round MIP screen). The app was called Daylight until the afternoon, and the code still uses that name.

This file records what we built, what we decided to add, what we set aside, and why. The schedule and the pitch are in demo-plan.md.

## The idea

On hackathon day the sun in Calgary rose at 8:50 AM, set at 5:51 PM, and never got higher than 21 degrees. A desk worker can easily spend all of that daylight indoors. The fenix 7 Pro already measures sunlight so it can charge itself. Lightwell reads that same sensor and counts the light toward a daily goal.

The brief asked us to pick one thing we struggle with ourselves. We picked this one and kept the app to it: the watch measures the habit with no input from the user, and nudges at the moment the nudge can be acted on.

## What exists today

| Feature | What it does | Code |
|---|---|---|
| Light ring | Minutes of light today against a 20-minute goal, sun time left, streak (one missed day is forgiven) | source/DaylightView.mc, drawRing |
| Sun finder | Where the sun is from where you stand, turned by the compass, plus its height and the sunset time | drawSun; sun position in DaylightModel.updateSun (NOAA formulas) |
| Week | Six finished days and today, drawn against the goal line | drawWeek; history in source/Day.mc |
| Sensors | Live readings: solar, heart rate, GPS, barometer trend, movement, compass | drawSensors |
| Nudges | Vibrates when you have been sitting, the sun is up and the ring is not full. Asks you to uncover the watch when you are walking outside but the sensor reads dark | DaylightModel.checkNudge, checkSleeve |
| Background | Reads the sensor every 5 minutes while the app is closed, the shortest interval Connect IQ allows | source/DaylightService.mc |
| Day rollover | Files the finished day into history, settles the streak, clears today's counters | Day.roll() |
| Demo mode | START steps a labelled fake light level (off, 0, 15, 60, 100) and runs time 60 times faster | DaylightDelegate.mc, DaylightModel.cycleDemo |

## What each sensor is for

| Sensor | Used for |
|---|---|
| Solar sensor | The light reading that fills the ring |
| GPS | Sunrise, sunset, and the sun's direction and height where you are |
| Compass | Turning the sun finder to match the way you face |
| Accelerometer and steps | Telling light minutes spent moving from light minutes spent sitting |
| Heart rate | Heart rate when you stepped into light against heart rate now |
| Barometer | A pressure drop over 3 hours shows "go now" before cloud arrives |

Pulse Ox and temperature are left out on purpose. We could not find a real job for either.

## What we are adding before the pitch

- **A nudge that says why it fired.** A reminder on a timer is easy to ignore. Ours names the reason: how long you have been sitting and how much sun is left.
- **Three settings on the watch**, opened by holding UP: goal (10, 20 or 30 minutes), wording (walk, roll, find a window), vibration (normal, soft, off).
- **Optional:** current stress as a second trigger for the same nudge.

## Inclusivity

The mentor asked us to consider women, people with disabilities and different lifestyles. The three settings are how we do that.

- **Wheelchair users and limited mobility.** With wording set to "roll" or "find a window", no prompt says "walk" or "step". Light through a window counts toward the goal, so the goal can be met without going outside.
- **Sensory-sensitive.** Vibration can be soft or off.
- **Different days.** There is no fixed schedule. Nudges depend on the sun and on how long you have been still, so shift workers are not assumed to work 9 to 5. The goal can be lowered to 10 minutes.

## Ideas we set aside

- **Coffee, water and a caffeine cutoff.** Logged by hand, no sensor, and a caffeine tracker is already in the Connect IQ store.
- **A breathing guide.** Garmin watches already have breathing exercises.
- **A stress page.** The fenix7pro simulator has no stress history to show.
- **A ten-question setup, three tones for every message, a settings file with 17 keys.** More than we can build and test in an afternoon.
- **Earlier ideas:** eye-strain breaks, posture breaks, winter presets, office and remote modes, a weighted score, a glance view, setup as a conversation with a language model.

## Known limits

- solarIntensity is a charging efficiency from 0 to 100. It is not lux and not UV. We count time above a cut-off of 5, and that cut-off has not been calibrated on a watch.
- In the background, one reading counts for the whole 5 minutes since the previous one.
- While the app is closed, the only way to reach the user is a prompt that offers to open the app.
- A sleeve covers the sensor. The app can ask you to uncover the watch but cannot read light through fabric.
- The app has only run in the simulator.
