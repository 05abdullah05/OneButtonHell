## Download & play

Get the Windows version from the [Releases page](../../releases): download the zip, unzip it and run `OneButtonHell.exe`.
Gameplay videos: [Teaser](https://youtu.be/fpKyru0xjNk?si=1zNDyEc_R5KOmLH-) · [Full playthrough](https://youtu.be/nFVydSco_tc?si=FMFr4dqnl1RGBJ7y)

# One Button Hell

A 2D one-button auto-runner made in **Godot 4.7.2 (GDScript)** for TDDD23 Game Development, Linköping University, 2026.

The character runs on its own. The only input is **jump** (Space / left mouse button).
Seven short levels introduce one idea at a time and then combine them.

**Controls:** Space / Left click = jump (hold for a higher jump) · Esc / P = pause · Menus: Space/Enter presses the selected button, Esc = back.

---

## Core design

> One simple control, increasingly complex decisions.

- **Easy to pick up:** level 1 teaches jumping without any text. The first spike is visible from the start with about 2 seconds of runway, so the player has time to try the only button there is.
- **Skill:** tap = small hop, hold = full jump. Coins are placed on risky routes and reset on death, so collecting all of them requires one clean run. The complete screen shows coins, deaths and best result.
- **Progression:** every level adds one new idea in a safe situation first, then requires it, then combines it with earlier ideas. Each pair of levels has its own time of day (day → sunset → dusk → night).

## Levels

| # | Name | Palette | New idea | How it is taught |
|---|------|---------|----------|------------------|
| 1 | Basics | Day | Run, jump, spikes, gaps, coins | First spike visible from the start; first coin is free |
| 2 | Patterns | Day | Spike rhythm, step-up, triple spike, risk route | Floating platform with 2 coins above a safe path |
| 3 | Faster | Sunset | Speed pads 300 → 380 → 450 | First pad on an easy stretch; camera looks further ahead at higher speed |
| 4 | Wings | Sunset | Double jump | Safe discovery zone (coins only a double jump reaches), then gaps and ledges that require it |
| 5 | Moving Parts | Dusk | Moving and crumbling platforms | Crumbling platforms first appear above solid ground (falling is harmless) |
| 6 | Turnaround | Dusk | Turn arrows, zig-zag tower climb | Combines all earlier mechanics, then turns around and climbs |
| 7 | Final Level | Night | Everything at higher speed | Speed 380, tower slowed to 320 so the climb stays fair |

## Visual language (teaching without text)

| Color / look | Meaning | Used only for |
|---|---|---|
| Red | Danger | Spikes |
| Gold | Reward | Coins |
| Green | Finish | Goal flag |
| Cyan chevrons | Speed change | Speed pads |
| Orange arrows | Turn around | Turn arrows |
| Wood + dotted track | Moves (path shown in advance) | Moving platforms |
| Cracked sandstone | Breaks when you stand on it | Crumbling platforms |
| Wings on the character | An air jump is available | Double jump |
| Dark void | Falling here kills you | Pits |

Palettes change the sky and background, never these meanings.

## Feedback ("juice")

- **Squash & stretch** on jump and landing; landing squash scales with fall speed.
- **Dust** on jump/landing, **feathers** on double jump, **sparkles** on coins, **debris** from crumbling platforms, **confetti** at the goal.
- **Death:** the character bursts into pieces in its own colors, screen shake, **hit-stop** (0.08 s near-freeze), then a fast restart (0.55 s).
- **Sound:** distinct sounds for jump, double jump, coin, spike death, pit fall (slide whistle while the music fades out), speed pad, turn, crumble and goal, plus a chiptune music loop.
- **HUD:** coin counter that pops on pickup, death counter, and a progress bar toward a flag.

## Game feel (controls)

- **Coyote time (0.1 s):** you can still jump just after leaving a ledge.
- **Jump buffering (0.1 s):** a press slightly before landing still counts.
- **Variable jump height:** releasing early cuts the ground jump short.
- **Air jump always full height:** playtesting showed players double-*tap*; a cut air jump made a ledge impossible with taps.
- **Forgiving hitboxes:** spikes have smaller hitboxes than their drawing, coins bigger.
- **Camera:** vertical drag margins (normal jumps don't move the camera), look-ahead that grows with speed and swings around when the player turns.

## Architecture

```
scenes/
  player.tscn            CharacterBody2D + PlayerVisual + ShakeCamera
  platform.tscn          StaticBody2D, @tool, size set in Inspector
  moving_platform.tscn   AnimatableBody2D (carries the player)
  crumble_platform.tscn  StaticBody2D + Trigger Area2D
  spike / coin / goal / speed_pad / turn_pad .tscn   Area2D + signals
  background.tscn        Parallax2D layers (clouds, hills, bushes, void)
  hud.tscn               CanvasLayer: HUD, pause menu, level complete
  ui/main_menu.tscn      Start, Levels (unlocking), Credits, Quit
  levels/level_01..07.tscn
scripts/                 one script per scene + helpers
audio/                   generated .wav files
tools/                   sound generator, level simulations, death report
```

- **Autoloads (singletons):** `Audio` (music survives level restarts, pool of 8 players, pitch variation) and `GameManager` (level order, coins, deaths, navigation, save file, playtest log).
- **Signals** for events (`body_entered`, `coins_changed`, `level_completed`): objects don't need to know about each other.
- **Groups** (`player`, `goal`, `coins`) to find nodes without hard-coded paths.
- **All art is drawn in code** with `_draw()`; `@tool` scripts show it in the editor.
- **Saved progress:** `user://save.cfg` (ConfigFile): beaten levels and best coins. Levels unlock in order.

## Testing

1. **Physics simulation** (`tools/sim*.py`): the game's own numbers (gravity, jump speed, hitboxes, coyote time, speed pads, moving/crumbling platforms, turn arrows). For every level it checks that the level can be finished, that new mechanics are really required (e.g. level 4 is impossible without the double jump), that all coins are reachable in one run, and which press styles (full jumps only, quick taps only) can finish it.
2. **Playtests** with the death counter and the playtest log (`user://playtest_log.csv`, summarized by `tools/death_report.py` into a per-level death heatmap).
3. **Fixes from playtests** (selection):
   - Level 4: 32 deaths at one ledge. The cut air jump made the ledge impossible with quick taps (0 working timings). Air jump made full height, ledge lowered 160 → 140 px: quick taps 0 → 588 working timings.
   - Levels 6–7: tower ledges stacked directly on top of each other (head bonks, no time to react after turning). Rebuilt with 560 px ledges overlapping only 25%: 61 → 155 working timings for the same climb; an extra turn arrow lets a missed jump loop back instead of dying.
   - Level 5 felt easier than level 4 = dip in the difficulty curve, noted for balancing.
   - Bugs found by playing: player ran off the last platform after the goal, HUD had zero width, duplicated background drawn in front, void not covering the screen.

## Dev log (condensed)

- **30/9–7/10:** project setup; player with auto-run, coyote time, jump buffer, variable jump height; reusable scenes; level 1.
- **8/10:** game seminar.
- **13/10:** code-drawn art: parallax background, brick platforms, shaded spikes.
- **14–15/10:** animated character with squash & stretch; juice (particles, shake, hit-stop).
- **16/10:** generated sound effects and music; audio autoload.
- **17–18/10:** coins, HUD, GameManager; level complete screen, pause menu, victory pose.
- **19–20/10:** main menu, level select with unlocking, saved progress; first export; levels 2–3 with speed pads.
- **21–22/10:** double jump with wings + level 4 (tuned after playtest); moving and crumbling platforms + level 5.
- **23–26/10:** turn arrows + level 6; level 7; world palettes; playtest death logging.
- **29–30/10:** sibling playtest: towers in levels 6–7 rebuilt; final export and recordings.

## Running / building

- Open the folder in Godot 4.7.2 and press F5 (main scene: `scenes/ui/main_menu.tscn`).
- Export: Project → Export → Windows Desktop (Embed PCK) → single `OneButtonHell.exe`.
- Regenerate sounds: `python tools/make_sounds.py` (needs numpy).

## Credits

Made by the author for TDDD23, Linköping University, 2026. Made with Godot Engine 4.7. Art, sound effects and music created in code.
