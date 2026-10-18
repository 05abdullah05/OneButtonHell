# One Button Hell

2D auto-runner made in Godot 4.7 (GDScript) for TDDD23.
The player runs automatically; the only input is jump (Space / left mouse button).

## Dev log

### Setup (30/9 – 7/10)
- Godot project + private GitHub repo.
- Player: CharacterBody2D with auto-run, gravity and jump.
- Game-feel techniques for "controls work flawlessly":
  - Coyote time (0.1 s): can still jump just after leaving a ledge.
  - Jump buffering (0.1 s): a slightly early press still counts on landing.
  - Variable jump height: releasing early cuts the jump short = skill element.
- Jump physics: ~117 px high, ~217 px long at 300 px/s. Gap and spike
  sizes in levels are designed from these numbers.
- Input Map action "jump" instead of hard-coded keys.

### Architecture + Level 1 (5/10 – 7/10)
- Reusable scenes: Player, Platform, Spike, Goal. Levels are built by
  placing instances.
- Platform uses a @tool script: Size is set in the Inspector and each
  platform creates its OWN collision shape (avoids Godot's shared-resource
  trap when duplicating).
- Spike/Goal are Area2D using the body_entered signal (observer pattern);
  `class_name Player` so they only react to the player.
- Spike hitbox is smaller than its visual = forgiving, fair deaths.
- Death = instant restart (reload_current_scene via call_deferred, because
  physics objects must not be removed mid physics step).
- Level 1 teaches without text: first spike is visible from the start with
  ~2 s of runway, then one new idea at a time (gap, double spike, wider gap).
- Color language: red = danger, green = goal, neutral stone = safe ground.

### Seminar (8/10)
- Presented level 1, controls design and roadmap.

### Art: background + visuals (13/10)
- All art drawn in code with _draw() (@tool so it shows in the editor).
- Platforms: stone bricks (rows offset half a brick) + grass top.
- Spikes: shaded triangle (light left, dark right) for a 3D feel.
- Parallax background (Parallax2D), 4 layers in a reusable Background scene:
  - Clouds: scroll 0.1 + slow autoscroll so the world feels alive.
  - Far hills: scroll 0.2, pale blue (atmospheric perspective = depth).
  - Bushes: scroll 0.5, dark green.
  - Void: dark area below ground, so gaps read as deadly pits without text.
- Hills are generated with sine waves that fit a whole number of times into
  the layer width, so the repeating layer has no visible seam.
- Draw order = tree order: Background must be first child of the level.
- Camera2D vertical drag margins: the camera ignores normal jumps, so the
  view doesn't bounce every time the player jumps.
- Bug found: two Background instances, one drawn in front of everything.
  Fixed by removing the duplicate.




  ### Character + squash & stretch (14/10)
- Player visual drawn in code (PlayerVisual, @tool): head, hair, face,
  shirt, arms, legs, with a dark outline so it reads on every background.
- Purple shirt: not red (danger) or green (goal), and stands out against
  sky, bushes and stone.
- Three poses chosen from physics state: run cycle (sin/cos for legs and
  arms, opposite phase), rising (tucked), falling (arms out, legs down).
- Eyes look in the running direction; mouth opens in the air.
- Squash & stretch: stretch (0.7, 1.3) on takeoff, squash on landing
  scaled by fall speed (bigger fall = bigger squash).
- Visual origin at the feet, so scaling keeps the feet on the ground.
- Scale eases back with lerp using 1 - exp(-k * delta) =
  frame-rate independent smoothing.
- Separation: Player (physics/logic) tells PlayerVisual (drawing) what
  happens via set_state() and squash(). Logic and visuals stay separate.
- Hitbox shrunk to 24x56 to match the narrower character (fair deaths).


For the exam
Squash and stretch is one of the classic animation principles. It makes motion feel elastic and gives every jump and landing physical weight without any extra mechanic. It's feedback the player feels rather than reads.
Separating logic from visuals means player.gd only handles physics and rules, while PlayerVisual only handles drawing. You could swap the art for a sprite later without touching the movement code.
The fall_speed detail shows careful debugging: move_and_slide() sets velocity.y to 0 on landing, so the speed has to be saved before the call.





### Juice / feedback (15/10)
- FX helper (static function) spawns one-shot CPUParticles2D bursts in
  code: random colors per particle, shrink over lifetime, auto-deleted
  when finished (no memory build-up).
- Dust on jump and landing; landing dust scales with fall speed.
- Death: character bursts into pieces in its own colors + screen shake.
- Hit-stop: Engine.time_scale = 0.05 for 0.08 s at death so the hit
  "lands". The timer ignores time_scale, otherwise it would be slowed too.
- Death pause 0.55 s: the player sees what killed them, but restart is
  still fast enough to keep the "one more try" flow.
- Screen shake on the Camera2D: random offset added to the base offset,
  decays with frame-rate independent smoothing. Strong on death, light on
  hard landings, so its intensity carries meaning.
- Goal: confetti + 1 s celebration before restarting/next level.
  `reached` flag prevents triggering twice.
- Particles are added to the level, not the player, so they stay where
  they spawned.
- Fixed: Void polygon points in wrong order made a bowtie shape.

For the exam
Feedback scales with the event. Small hop, small puff; big fall, big puff and a shake; death, explosion, freeze and a big shake. Since effect size matches how important an event is, the player learns what matters without being told. That's the "visual cues and feedback" criterion directly.
Hit-stop is used in games like Celeste and fighting games. A tiny freeze makes an impact feel heavy, and here it also makes clear exactly what killed you.
Fast restart is a design choice. A long death screen punishes the player; a short pause plus an instant retry keeps them in the flow, which matters in a hard, short-level game like this.
await with timers lets one function describe a whole sequence in order (freeze, unfreeze, wait, restart) without a state machine.




### Audio (16/10)
- All sounds and music generated from basic waveforms (square, triangle,
  noise) with tools/make_sounds.py: no licensing issues.
- Sounds: jump (rising chirp), spike death (crunch + falling "pheww"),
  pit fall (slide whistle fading into silence), goal fanfare, coin.
- Music: 16-bar chiptune loop (Am-F-C-G), 150 BPM.
- Audio manager is an autoload ("Audio"): created once, survives scene
  reloads, so the music doesn't restart after every death.
- Pool of 8 AudioStreamPlayers reused in turn: sounds can overlap without
  creating new nodes each time.
- Random pitch variation on the jump sound so the most frequent sound
  never feels repetitive.
- Pit fall: whistle starts when the player drops below the ground (pit_y),
  and the music fades out with a Tween, like falling down a well. It
  fades back in on restart. Spike and pit deaths sound different, so the
  player hears what killed them.

  
For the exam
Autoload (singleton): a node Godot creates at startup that lives outside the scenes. That's why the music survives reload_current_scene(); a music player inside the level would restart on every death, which gets very annoying in a game where you die often.
Sound tells the player what happened. Spike and pit deaths sound different, so the player knows the cause without looking. That's the "auditory cues" part of the teaching criterion.
Pitch variation: the jump is the most frequent sound in the game. A small random change in pitch keeps it from sounding mechanical over hundreds of jumps.
Tweens animate a property smoothly over time, here the music volume, with one line of code.



### Coins + HUD + GameManager (17/10)
- Coin: Area2D drawn in code, spins (width squeezed with cos) and bobs.
  Collect = sparkles + sound + counter update.
- Coin hitbox (r=18) is bigger than its drawing (r=13): rewards are easy
  to grab, hazards (spikes) have smaller hitboxes. Generous both ways.
- GameManager autoload: coins this attempt, total coins, deaths in the
  current level. Survives reloads, so deaths keep counting; coins reset
  each attempt, so all coins require one clean run (skill element).
- Signal coins_changed: the HUD reacts when a coin is collected
  instead of checking every frame (observer pattern).
- level.gd on every level root: counts coins via the "coins" group.
  Works because a parent's _ready runs after all its children's.
- HUD in a CanvasLayer (fixed on screen, ignores camera), drawn in code:
  coin counter with "pop" animation, death counter, progress bar
  (player marker moving toward a flag) = shows how far you are without text.
- HUD ignores mouse input, so clicking still jumps.
- Level 1 coins along the main path; first coin is free (teaches what
  coins are), one needs a full held jump.


### For the exam
Groups are Godot's tags. Nodes join a group like "coins," "player" or "goal," and any script can find them without knowing where they sit in the tree. That keeps scenes loosely connected.
Signals vs. polling: the HUD's coin pop is triggered by the coins_changed signal, so it reacts exactly when something happens. The progress bar does read the player position every frame, because that changes continuously. Knowing when to use which is good design reasoning.
Coins reset on death is a design choice: collecting everything requires a clean run, which separates experienced players from beginners. That's the "skill" criterion.
The progress bar answers "how far is it?" without words, and makes near-misses motivating ("I was at 90%!").


### Level complete + pause menu (18/10)
- GameManager holds the level order (LEVELS list) and all navigation:
  next level, restart, main menu. One place to add new levels.
- Level complete screen: coins x/y, "All coins collected!", deaths, best
  coins, buttons Next Level / Replay / Main Menu. Last level shows
  "YOU BEAT THE GAME!" without Next. Fades in after the confetti.
- Signal level_completed: the goal doesn't know about the UI, it just
  reports to GameManager and the screen reacts (loose coupling).
- Pause menu (Esc/P): get_tree().paused stops the game; the menu uses
  PROCESS_MODE_ALWAYS so it keeps working while everything else is paused.
- Every new scene unpauses in start_level, so the game can never get
  stuck paused after a restart.
- One-button friendly: first button is preselected, Space/Enter presses
  it, with a white border showing the selection.
- UIKit: shared code-built styles (StyleBoxFlat) so all menus match the
  game's colors (purple buttons, gold titles).
- Bug fixed: player ran off the last platform after the goal and died.
  Now finish() brakes to a stop and shows a victory pose; die() is
  ignored after finishing.


For the exam
Pausing in Godot: get_tree().paused = true stops every node whose process mode is "pausable" (the default), and nodes set to ALWAYS keep running. That's why the pause menu can still respond while the game is frozen.
Centralizing the level order: levels don't point to each other; GameManager owns the list. Adding, removing or reordering levels is a one-line change, with no risk of a broken chain between levels.
Feedback loop for skill: the complete screen shows coins, deaths and your best. Experienced players get a reason to replay ("can I get all 5 with zero deaths?"), which supports the skill criterion beyond simply finishing.
Bug found by playtesting: the post-goal death came from actually playing and noticing. Mention it as part of your testing story.