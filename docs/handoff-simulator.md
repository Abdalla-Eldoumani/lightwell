# Handoff: simulator and demo (Yaseen)

You run every build, find what is broken, and drive the demo on stage. You do not need to write code. If you want to, ask Abdalla first so two people never edit the same file.

## Now

1. The history of main was rewritten at noon and bin/ is no longer tracked. Save anything you have not pushed, then in Git Bash run these two commands:
   - git fetch origin
   - git reset --hard origin/main
2. Run the app on fenix7pro (Ctrl+F5).
3. Set the simulator position to Calgary: 51.0447, -114.0719.
4. Screenshot all four pages and send them to Abdalla.

## Checklist, rerun after every push

- [ ] No text is cut off or runs into the ring on any page.
- [ ] Find the solar intensity control (look where the simulator sets the battery level). Moving it above 5 turns the top line to LIGHT and the minutes climb.
- [ ] START steps the demo level. At DEMO 60 the ring fills in about 20 seconds, the watch vibrates and "Goal reached" shows.
- [ ] DOWN and UP move through ring, sun finder, week and sensors. The dots on the left follow.
- [ ] The sun finder points near south-west in the afternoon and shows a sunset time of 5:51 PM.
- [ ] Sensors page: write down which lines say "waiting".
- [ ] Set steps and the move bar from the Simulation menu (Activity Monitoring). The nudge to go outside should fire.
- [ ] Close the app, trigger a background temporal event from the Simulation menu, and reopen. With solar above 5, the minutes should be 5 higher.
- [ ] Holding UP opens the settings, once Abdalla has pushed them.

Report every failure to Abdalla with a screenshot and what you pressed.

## 2:30 to 3:00

Record the full demo path as a screen recording, 60 to 90 seconds. It is the backup if the simulator fails on stage.

## On stage

You drive the simulator while David talks. The order is in demo-plan.md. Practise it in all three rehearsals.
