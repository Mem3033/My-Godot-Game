extends CharacterBody2D

const SPEED = 200.0
const WALK_SPEED = 90.0
const JUMP_VELOCITY = -400.0

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
@onready var attack_area: Area2D = $AttackArea

var health = 100
var gold = 0

var attacking = false
var attack_step = 0
var attack_queued = false
var blocking = false
var taking_damage = false
var dead = false


func _ready():
	add_to_group("player") # Гарантируем, что игрок в группе
	anim.animation_finished.connect(_on_animation_finished)
	
	if not attack_area.body_entered.is_connected(_on_attack_area_body_entered):
		attack_area.body_entered.connect(_on_attack_area_body_entered)


func _physics_process(delta: float) -> void:
	if dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if health <= 0:
		die()
		move_and_slide()
		return

	var direction := Input.get_axis("left", "right")

	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

	blocking = Input.is_action_pressed("block")

	if blocking and not attacking and not taking_damage:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		anim.play("Block")
		move_and_slide()
		return

	if taking_damage:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	if Input.is_action_just_pressed("attack"):
		if attacking:
			attack_queued = true
		else:
			start_attack()
	
	if attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var current_speed = SPEED

	if Input.is_action_pressed("walk"):
		current_speed = WALK_SPEED

	if direction != 0:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if not is_on_floor():
		if velocity.y < 0:
			anim.play("Jump")
		else:
			anim.play("Fall")
	elif direction != 0:
		if Input.is_action_pressed("walk"):
			anim.play("Walk")
		else:
			anim.play("Run")
	else:
		anim.play("Idle")

	move_and_slide()


func start_attack():
	attacking = true
	attack_step = 0
	attack_queued = false
	anim.play("Attack")


func _on_animation_finished():
	if dead:
		if anim.animation == "Death":
			get_tree().change_scene_to_file("res://меню.tscn")
		return

	if taking_damage and anim.animation == "Damage":
		taking_damage = false
		return

	if attacking:
		if attack_queued and attack_step < 2:
			attack_step += 1
			attack_queued = false

			if attack_step == 1:
				anim.play("Attack2")
			elif attack_step == 2:
				anim.play("Attack3")
		else:
			attacking = false
			attack_queued = false


# Нанесение урона врагам при ударе
func _on_attack_area_body_entered(body):
	if attacking:
		if body.has_method("take_damage"):
			body.take_damage(25)


func take_damage(amount: int):
	if dead or blocking or taking_damage:
		return

	health -= amount

	if health <= 0:
		die()
		return

	attacking = false
	attack_queued = false
	taking_damage = true
	anim.play("Damage")


func die():
	if dead:
		return

	dead = true
	attacking = false
	taking_damage = false
	blocking = false
	velocity = Vector2.ZERO
	anim.play("Death")
