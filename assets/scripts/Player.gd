extends Area2D
signal hit
signal dash
signal canDash

export var speed = 400
export var canMove = false
var canDashing
var screen_size
var isDashing

func _ready():
	isDashing = false
	canDashing = true
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	
	# Move control
	if(!canMove):
		$AnimatedSprite.stop()
		return 
	
	var velocity = Vector2()  # The player's movement vector.
	
	# Input control
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	# Dash control
	if Input.is_action_pressed("ui_select") and canDashing:
		isDashing = true
		canDashing = false
		modulate = Color(1, 1, 1, 0.5)
		$DashTimer.start()
		emit_signal("dash")
	
	# Anim control
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
	
	if velocity.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0
	
	# The player must not leave the screen
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _on_Player_body_entered(body):
	if(!isDashing):
		hide()
		emit_signal("hit")
		$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_DashTimer_timeout():
	isDashing = false
	modulate = Color(1, 1, 1, 1)
	$DashReloadTimer.start()

func _on_DashReloadTimer_timeout():
	canDashing = true
	emit_signal("canDash")
