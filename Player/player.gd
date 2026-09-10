extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@onready var anim = $AnimatedSprite2D
var health = 100
var gold = 0

func _physics_process(delta: float) -> void:
	# Гравитация
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Проверка здоровья
	if health <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://меню.tscn")
		return

	# Прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Движение влево / вправо
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED

		# Поворот персонажа
		if direction == -1:
			anim.flip_h = true
		elif direction == 1:
			anim.flip_h = false

		anim.play("Run")

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		anim.play("Idle")

	# Анимация прыжка
	if not is_on_floor():
		anim.play("Jump")

	move_and_slide()
	
