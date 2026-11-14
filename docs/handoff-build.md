# Stream 1: screens and nudges (Abdalla, with Yaseen on the simulator)

You own how the app looks and how a nudge lands. You are the only person who edits LightwellView.mc, LightwellModel.mc, LightwellDelegate.mc, LightwellApp.mc, LightwellService.mc and Day.mc, and you merge everything to main.

## Already on main

- Five pages (ring, sun finder, week, month, sensors) with page dots. The month page is a grid of 30 days: a full dot is a day at goal.
- A nudge that says why: the ring page shows the sun time left, "Sitting 1h" and the action in the user's wording.
- A tone and a vibration with each nudge and at the goal. In the simulator the window shakes on a vibration, and tones are reported to play through the PC speakers. Check that on your machine first.
- Smoothed arcs (anti-aliasing) on the ring and the compass.
- Settings on hold UP.

## To do, in this order

1. **Fix what the screenshots show.** Nobody has reviewed these pages on screen yet. Clipped or overlapping text comes first.
2. **Make "goal met" a change of shape as well as colour.** A filled dot or a tick in the middle of the full ring. Colour alone is easy to miss on this screen.
3. **Today's bar on the week page in the accent colour**, the other days in grey, so the eye lands on today.
4. **Only if 1 to 3 are done by 2:30:** draw the nudge as a band along the bottom edge of the ring page, in place of two lines of text.

## What good looks like here

- One number per page, readable in under 2 seconds. Nothing smaller than the small label font.
- Black background, white text, one warm colour for sun and progress, one grey. No third colour without a reason.
- A nudge only when the user can act on it, and never more than one at a time.
- These come from Apple's watchOS guidelines, Google's Wear OS principles and the Material 3 Expressive notes for Wear OS. Links are in demo-plan.md.

## How we review the look

Nothing about the look is decided in one pass. For each visual change, Yaseen screenshots it in the simulator, the team says keep, change or drop, and only then does the next change start. Where there is a real choice (the nudge is the first one), three versions are shown side by side and the team picks.

## Rules

- One file per commit. Never commit bin/. Run git pull --rebase before every push.
- Build with no warnings before every push, then tell Yaseen.
- 2:45 is the feature freeze.
