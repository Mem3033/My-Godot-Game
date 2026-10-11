extends CharacterBody2D

const SPEED = 100.0
const DAMAGE = 15
const ATTACK_DISTANCE = 35.0
const ATTACK_COOLDOWN = 1.0

@onready var anim = $AnimatedSprite2D

var health = 60
var alive = true
var chase = false
var attacking = false
var attack_timer = 0.0
var player: Node2D


func _ready():
	player = get_tree().get_first_node_in_group("player") as Node2D
	anim.animation_finished.connect(_on_animation_finished)


func _physics_process(delta):
	if not alive:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	attack_timer = maxf(attack_timer - delta, 0.0)

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D

	if not is_instance_valid(player) or not chase:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

		if not attacking:
			anim.play("Idle")

		move_and_slide()
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= ATTACK_DISTANCE:
		velocity.x = 0.0

		if not attacking:
			anim.play("Idle")

		if attack_timer <= 0.0:
			attack()
	else:
		velocity.x = sign(player.global_position.x - global_position.x) * SPEED
		anim.flip_h = player.global_position.x < global_position.x

		if not attacking:
			anim.play("Run")

	move_and_slide()


func _on_detector_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player = body
		chase = true


func _on_detector_body_exited(body: Node2D):
	if body.is_in_group("player"):
		chase = false
		velocity.x = 0.0


func attack():
	if not alive or not is_instance_valid(player):
		return

	attacking = true
	attack_timer = ATTACK_COOLDOWN
	anim.play("Attack")
	if player.has_method("take_damage"):
		player.take_damage(DAMAGE)


func _on_animation_finished():
	if anim.animation == "Attack":
		attacking = false

		if alive:
			anim.play("Idle")


func take_damage(amount: int):
	if not alive:
		return

	health -= amount

	if health <= 0:
		death()


func _on_death_body_entered(body: Node2D):
	if not alive or not body.is_in_group("player"):
		return

	if body.velocity.y > 0 and body.global_position.y < global_position.y:
		body.velocity.y = -300
		death()


func death():
	if not alive:
		return

	alive = false
	chase = false
	attacking = false
	velocity = Vector2.ZERO
	anim.play("Death")

	await anim.animation_finished
	queue_free()
