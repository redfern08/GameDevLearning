extends RigidBody2D
# Player will use the FSM (finite state machine) method.

# Add export items here
@export var engine_power = 500
@export var spin_power = 8000
@export var bullet_scene : PackedScene
@export var fire_rate = 0.25

# Start by creating the FSM skeleton.
enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = INIT
var thrust = Vector2.ZERO
var rotation_dir = 0
var screensize = Vector2.ZERO # screen size
var can_shoot = true


# Create 'change state' function to handle state transitions.
func _ready():
	change_state(ALIVE) # state is ALIVE for testing purposes. change to INIT later.
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = fire_rate

func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true) 
		ALIVE:
			$CollisionShape2D.set_deferred("disbaled", false) 
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
	state = new_state

func _process(_delta):
	get_input()

# create the player input function
func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return 
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		
# create shoot function
func shoot():
	if state == INVULNERABLE:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)

func _physics_process(_delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform

func _on_gun_cooldown_timeout():
	can_shoot = true
