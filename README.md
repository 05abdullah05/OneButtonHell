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