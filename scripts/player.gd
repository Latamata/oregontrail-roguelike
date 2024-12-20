extends CharacterBody2D

const SPEED = 60.0
var reloaded = true
var gather = false
var direction
var targetResource

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var gun = $Musket
@export var gun_offset = Vector2(10, 10)
@export var gun_radius = 1.0
@onready var camera_2d = $"../Camera2D"
@onready var sabre = $sabre

func _physics_process(delta):
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		camera_2d.global_position = global_position
		sprite_frame_direction()
		velocity = direction * SPEED * delta
		move_and_collide(velocity)
	else:
		velocity = Vector2.ZERO
		animated_sprite_2d.stop()
	#rotate_sword_to_mouse()  # Keep sword aligned to the mouse

func _input(event):
	if event is InputEventMouseMotion:
		rotate_gun()

func sprite_frame_direction():
	if direction == Vector2(-1, 0):
		animated_sprite_2d.animation = "walking"
		animated_sprite_2d.play()
		animated_sprite_2d.flip_h = true
		#print(animated_sprite_2d.animation = )
		
	elif direction == Vector2(1, 0):
		animated_sprite_2d.animation = "walking"
		animated_sprite_2d.play()
		animated_sprite_2d.flip_h = false
		#animated_sprite_2d.frame = 2
	if direction == Vector2(0, -1):
		animated_sprite_2d.animation = "new_animation"
		animated_sprite_2d.stop()
		#animated_sprite_2d.frame = 1
		pass
	elif direction == Vector2(0, 1):
		pass
		#animated_sprite_2d.frame = 0
	
func player_die():
	queue_free()

func rotate_gun():
	var mouse_position = get_global_mouse_position()
	var direction_to_mouse = (mouse_position - global_position).normalized()
	var angle = direction_to_mouse.angle()
	sabre.rotation = angle
	sabre.position = direction_to_mouse * gun_radius + gun_offset
	#if angle > PI / 2 or angle < -PI / 2:
		#gun.flip_v = true
	#else:
		#gun.flip_v = false
	#if angle < 0:
		#gun.z_index = 0
	#else:
		#gun.z_index = 1

func _on_reload_timeout():
	reloaded = true

func _on_gatherarea_body_entered(body):
	if body.name == "tree":
		#targetResource = body
		gather = false

func swing_sword():
	# Align the sword with the mouse before swinging
	var mouse_position = get_global_mouse_position()
	var direction_to_mouse = (mouse_position - global_position).normalized()
	var angle = direction_to_mouse.angle()

	sabre.rotation = angle+45  # Base the swing on this angle
	sabre.get_child(1).disabled = false  # Enable the sword's hitbox

	# Animate the sword swing
	$Timer.start()  # Timer to reset the rotation after swing duration


func _on_sabre_body_entered(body):
	print(body)
	if body.name == "tree":
		body.chopped_down()
	if body.is_in_group("zombie"):
		body.player_die()
		#print("hit zombie")

func rotate_sword_to_mouse():
	var mouse_position = get_global_mouse_position()
	var direction_to_mouse = (mouse_position - sabre.global_position).normalized()
	var angle = direction_to_mouse.angle()
	sabre.rotation = angle

func _on_timer_timeout():
	sabre.rotation = 0
	sabre.get_child(1).disabled = true
