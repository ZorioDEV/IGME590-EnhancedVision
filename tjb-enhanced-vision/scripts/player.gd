extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var sensitivity:float = 0.001

@onready var head: Node3D = $Head
@onready var night_light: SpotLight3D = $Head/Camera3D/SpotLight3D
@onready var night_overlay: CanvasLayer = $Head/CanvasLayer
@onready var night_animation: AnimationPlayer = $AnimationPlayer
@onready var goggles: Node3D = $Head/GoggleScene

const GOGGLE_ANIM := "raise_goggle"
const FADE_IN_TIME := 0.6

var night_vision_on := false
var goggles_wanted := false
var night_light_energy: float
var fade_tween: Tween

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	night_light_energy = night_light.light_energy
	_set_night_vision(false)
	night_animation.animation_finished.connect(_on_goggle_animation_finished)
	
	#starts with the goggles lowered (first frame)
	night_animation.play(GOGGLE_ANIM)
	night_animation.seek(0.0, true)
	night_animation.pause()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("night_vision"):
		goggles_wanted = not goggles_wanted
		if goggles_wanted:
			#raises the goggles
			night_animation.play(GOGGLE_ANIM)
		else:
			#turns night vision off instantly (exiting)
			_set_night_vision(false)
			night_animation.play_backwards(GOGGLE_ANIM)


func _on_goggle_animation_finished(anim_name: StringName) -> void:
	#turns on night vision after animation
	if anim_name == GOGGLE_ANIM and goggles_wanted:
		_set_night_vision(true)


func _set_night_vision(on: bool) -> void:
	night_vision_on = on
	night_light.visible = on
	night_overlay.visible = on
	goggles.visible = not on  #goggle model + lens quads hidden in night mode

	if fade_tween:
		fade_tween.kill()
	if on:
		#fades the spotlight energy up
		night_light.light_energy = 0.0
		fade_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		fade_tween.tween_property(night_light, "light_energy", night_light_energy, FADE_IN_TIME)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		head.rotate_x(-event.relative.y * sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))
