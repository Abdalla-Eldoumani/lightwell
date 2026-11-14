# Stream 2: setup and personal settings (David)

You own the first minute of the app: the three questions that make it fit the person wearing it. Your files are source/SetupDelegate.mc and source/SettingsDelegate.mc. Nobody else edits them, and you edit nothing else without asking Abdalla.

## Already on main

- **First run.** Three screens, one question each, built on the watch's own menus so they look native:
  1. "I get around": on foot, by wheelchair, mostly indoors. Sets the wording of every nudge (step outside, roll outside, find a window).
  2. "On workdays I get": almost no daylight, some, plenty. Sets the daily goal to 10, 20 or 30 minutes.
  3. "Nudge me with": buzz and tone, soft buzz, screen only.
- A short message at the end confirms the plan ("10 min a day. Roll outside").
- **Settings** (hold UP) change the same three values later, and "Run setup again" replays the questions.
- **Two demo items** at the bottom of settings: "Demo: new user" wipes everything and starts setup, and "Demo: month later" loads a month of sample history from source/DemoData.mc. The week and month pages are titled DEMO while it is loaded.

## To do, in this order

1. **Run every path.** Nine answers across three screens. Check each one changes what the ring page and the nudge say. BACK should go to the previous question.
2. **Fix the wording.** A title must fit on one line of the menu, about 17 characters. Each option should finish the sentence the title starts. Nothing in the wheelchair or indoors path may say "walk" or "step".
3. **Check the confirmation message** fits and reads well for all three wordings.
4. **Only if 1 to 3 are done by 2:30:** a fourth question, "Nudge me" with "any time" or "work hours only".

## What good looks like here

- Each step takes a few seconds and one press. No typing, no scrolling past three options.
- The answers change something the user sees straight away.
- Skipping setup still leaves a working app with sensible defaults.

## How the values are stored

Application.Storage keys: words (0, 1, 2), goal (10, 20, 30), buzz (0, 1, 2), setup (1 when done). Read them through Day.num, Day.goalSecs and Day.action. Do not add settings.xml.

## Rules

One file per commit. Never commit bin/. Run git pull --rebase before every push. 2:45 is the feature freeze.
