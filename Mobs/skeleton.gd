extends CharacterBody2D

var chase = false
var speed = 100
@onready var anim = $AnimatedSprite2D
var alive = true


func _physics_process(delta: float) -> void:
	# Гравитация
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Находим игрока
	var player = $"../../Player/Player"

	if alive:
		if chase:
			# Движение вправо
			if player.position.x > position.x:
				velocity.x = speed
				anim.flip_h = false
				anim.play("Run")

			# Движение влево
			elif player.position.x < position.x:
				velocity.x = -speed
				anim.flip_h = true
				anim.play("Run")

			# Если игрок прямо рядом по X
			else:
				velocity.x = 0
				anim.play("Idle")

		else:
			# Игрок вышел из зоны
			velocity.x = 0
			anim.play("Idle")

	move_and_slide()


func _on_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true


func _on_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false


func _on_death_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.velocity.y -= 300
		death()

func _on_death_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if alive == true:
			body.health -=40
		death()

func death() -> void:
	# Чтобы смерть не запускалась несколько раз
	if not alive:
		return

	alive = false
	chase = false
	velocity.x = 0

	# Анимация смерти
	anim.play("Death")

	await anim.animation_finished

	# Удаляем моба после окончания анимации
	queue_free()
