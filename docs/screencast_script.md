# Individual development screencast: script (target 11-13 min, limit 5-15)

Face in a corner (PIP), Godot open, game ready to run. Talk in your own words;
these are talking points, not text to read aloud. Each section names the
course criterion it shows, so say it out loud ("this is about teaching the game").

Before recording: check the course rules on AI tools and state how you used
them the way the course requires. Make sure you can explain every part below
without notes; this is also your preparation for the oral exam.

---

## 1. Intro (0:00-0:45)
**Show:** main menu running, then a few seconds of level 1.
- Name, course, game: One Button Hell, a one-button auto-runner in Godot 4.7 with GDScript.
- Core idea: one simple control, increasingly complex decisions.
- What I'll show: controls, teaching, progression, skill, feedback, architecture, testing.

## 2. Controls that "just work" (0:45-2:30), criterion: well tested, polished, intuitive
**Show:** `scripts/player.gd`, `_physics_process` and `_handle_jump`; the Player's Inspector (exported values).
- Auto-run: `velocity.x = run_speed * direction`; gravity added only in the air; `move_and_slide()`.
- **Coyote time** 0.1 s and **jump buffer** 0.1 s: the game forgives human reaction time.
- **Variable jump height**: releasing early multiplies upward speed by 0.5. Tap = hop, hold = full jump: a skill element in one button.
- **Air jump always full height**: found in playtesting (story in section 7).
- `@export` values = tuning in the Inspector while testing.
- Jump numbers: about 117 px high, 217 px long at 300 px/s. Levels are designed from these.

## 3. Teaching without text (2:30-4:30), criterion: teaching through the experience
**Show:** play level 1 start; then level 4 discovery zone; then level 5 crumble intro.
- Level 1: first spike visible immediately with about 2 s runway; first coin is free.
- Visual language table (README): red = danger, gold = coin, green = goal, cyan = speed, orange = turn, wood = moves, cracked sand = breaks, dark void = pit. Each color means one thing only.
- Double jump: **wings** show you have an air jump; they burst into feathers when used and come back on landing. Own sound. Safe discovery zone first.
- Crumbling platforms first appear above solid ground: failing costs nothing.
- Moving platforms draw their **dotted track** and slow down at the ends (cosine easing), so they are predictable.
- Sound tells you what happened: spike crunch vs. pit whistle with the music fading out.

## 4. Progression and variation (4:30-6:00), criterion: progression
**Show:** level select, then quick clips of levels 2, 3, 6, 7.
- Each level: new idea safe, then required, then combined (README level table).
- Level 3: speed pads, camera **look-ahead grows with speed** so reaction time stays fair.
- Levels 6-7: turnaround tower, my own idea; flat ledges instead of slopes so the controls behave the same everywhere.
- Palettes day → sunset → dusk → night: the look changes, the rules never do (teacher's feedback on the plan).
- Levels unlock in order (saved in `user://save.cfg`), so everyone meets the curve as designed.

## 5. Skill (6:00-6:45), criterion: skill
**Show:** risky coin route in level 2 or 4; level complete screen.
- Coins on risky routes; coins reset on death, so all coins = one clean run.
- Complete screen: coins, deaths, best. Replay goal for experienced players.
- Hold vs. tap control and deterministic patterns: experienced players learn and go faster.

## 6. Feedback and juice (6:45-8:00)
**Show:** jump, land, die on a spike, collect a coin, reach the goal; then `fx.gd`, `shake_camera.gd`.
- Squash & stretch (visual origin at the feet), dust scaled by fall speed.
- Death: burst in the character's colors + shake + **hit-stop** (time_scale 0.05 for 0.08 s) + fast restart.
- `FX.burst()`: one static function making one-shot CPUParticles2D, deleted when finished.
- Frame-rate independent smoothing: `lerp(..., 1 - exp(-k * delta))`.
- Audio autoload: music survives restarts; pool of players; pitch variation on the jump. Sounds generated with `tools/make_sounds.py` from square/triangle waves and noise.

## 7. Testing: the strongest part (8:00-10:30), criterion: well tested
**Show:** `tools/sim5.py` briefly; run `death_report.py` on a log; README "Testing".
- Simulation uses the game's own physics numbers. Checks per level: finishable, mechanic required (level 4 impossible without double jump), coins reachable in one run, which press styles work.
- **Story 1, level 4:** 32 deaths at one ledge → measured: quick double-taps had **0** working timings because the air jump was cut on release → full-height air jump, ledge 160 → 140 → **0 → 588** working timings. Rejected glide-on-hold: one button would mean two things in the air.
- **Story 2, levels 6-7:** sibling playtest "too hard" → ledges stacked, head bonks, no time after turning → 560 px ledges overlapping 25% → **61 → 155** working timings; extra turn arrow = missed jump loops back instead of death.
- Playtest log: every death with position and cause → per-level heatmap.
- Bugs found by playing: player died after the goal, HUD had zero width, duplicated background, void gap.

## 8. Architecture (10:30-12:00), criterion: complexity of platform vs. content
**Show:** FileSystem dock and one level's scene tree; `game_manager.gd` LEVELS list; `level.gd`.
- Reusable scenes: levels are built by placing Player, Platform, Spike, Coin, Goal, pads, movers.
- Signals (`body_entered`, `coins_changed`, `level_completed`) = loose coupling; groups to find nodes.
- `GameManager` autoload: level order in one list, navigation, save/load, playtest log.
- `level.gd` per level: counts coins (parent `_ready` runs after children), double jump on/off, palette, path length.
- Pausing: `get_tree().paused`; menus use `PROCESS_MODE_ALWAYS`.
- Everything drawn in code with `_draw()`; `@tool` shows it in the editor.

## 9. Wrap-up (12:00-12:30)
- What I'd do next: more levels per world, a level editor, controller support.
- What I learned: game feel details decide whether a one-button game feels fair; measuring beats guessing.
