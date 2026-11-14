# Handoff: pitch (David)

You own the three minutes. The outline with timings is in demo-plan.md. Your idea of a nudge that says why it fired is going into the app, and the inclusivity question became the three settings.

## Deliver

1. A script that runs 3:00 on a timer. The rule is 3 minutes, then questions.
2. Slides, five at most: the problem with today's numbers; the idea in one line; the sensor table from debrief.md; how we would measure it; limits and what is next. The demo is live, not a slide.
3. After the 2:30 freeze: update debrief.md and README.md so they describe what actually shipped.
4. Run the three timed rehearsals at 3:00, 3:15 and 3:30.

## Numbers you can use

Open each source before it goes on a slide.

- **Calgary today.** Sunrise 8:50 AM, sunset 5:51 PM, solar noon 1:21 PM. The sun is 21 degrees up at its highest and about 12 degrees up at 4:00 PM.
- **Light and mood.** Burns and others, Nature Mental Health, 2023: 86,772 adults wore wrist light sensors, and more daytime light was associated with lower risk of depression. Say "associated with", never "causes". https://www.nature.com/articles/s44220-023-00135-8.pdf
- **Why the nudge gives a reason.** HeartSteps, 2019: a walking suggestion raised steps over the next 30 minutes by 24 percent on average, and the effect faded as the study went on. https://pmc.ncbi.nlm.nih.gov/articles/PMC6401341
- **Who else does this.** Apple Watch has tracked time in daylight since watchOS 10.

## Do not say

- That we are the first to read the solar sensor. A watch face called SolarDay already does.
- UV or vitamin D. The sensor cannot measure either.
- That light lowers stress. We have no source for it.

## Answers to have ready

- **"That value is charge efficiency, not lux."** True. It is the only light reading Connect IQ gives an app. We count time above a cut-off, and the cut-off still needs calibrating on a watch.
- **"Does light through a window count?"** Yes. Visible light passes through glass. We make no UV claim.
- **"What about sleeves?"** The app notices walking outdoors with a dark sensor and asks you to uncover the watch.
- **"Battery?"** One sensor read every 5 minutes in the background. GPS is a single fix, not tracking.
- **"Does it run on a real watch?"** It builds for the device with no warnings. It has only run in the simulator, and we say so.
- **"How do you know it changes habits?"** We don't yet. We would measure days at goal per week over 30 days.
- **"Doesn't Garmin already do this?"** Solar watches show solar intensity as charging information. As far as we found, nothing turns it into a daily light goal for the wearer.
