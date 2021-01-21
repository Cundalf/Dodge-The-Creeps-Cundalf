extends Node

export (PackedScene) var Mob
var score

# Background colors
var defaultColor = Color( 0, 0, 0.55, 1)
var colors = [Color( 0, 0.55, 0.55, 1),
	Color( 0.72, 0.53, 0.04, 1),
	Color( 0, 0.39, 0, 1),
	Color( 0.74, 0.72, 0.42, 1),
	Color( 0.55, 0, 0.55, 1),
	Color( 0.55, 0, 0, 1),
	Color( 0.58, 0, 0.83, 1),
]

func _ready():
	randomize()
	$MenuMusic.play()
	$ColorRect.color = defaultColor

func game_over():
	
	# Sound and Music control
	$GameMusic.stop()
	$DeathSound.play()
	
	# Restore default color
	$ColorRect.color = defaultColor
	
	# Kill all mobs
	get_tree().call_group("mobs", "queue_free")
	
	# Stop timers and show game over message
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	
	# Player must not move
	$Player.canMove = false
	
	# The main menu music start after 2 seconds
	yield(get_tree().create_timer(2), "timeout")
	$MenuMusic.play()
	
func new_game():
	# Music stop and reset score counter
	$MenuMusic.stop()
	score = 0
	
	# The background is set randomly
	$ColorRect.color = colors[randi() % colors.size()];
	
	# Reset player position
	$Player.start($StartPosition.position)
	
	# Show pre-game UI
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	
	$GameMusic.play()
	
	# After 2 seconds (time it takes for UI to hide), the player can move
	yield(get_tree().create_timer(2), "timeout")
	$Player.canMove = true
	$HUD.setDashIcon(true)

func _on_MobTimer_timeout():
	# Choose a random location on Path2D.
	$MobPath/MobSpawnLocation.offset = randi()
	
	# Create a Mob instance and add it to the scene.
	var mob = Mob.instance()
	add_child(mob)
	
	# Set the mob's direction perpendicular to the path direction.
	var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
	
	# Set the mob's position to a random location.
	mob.position = $MobPath/MobSpawnLocation.position
	
	# Add some randomness to the direction.
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	# Set the velocity (speed & direction).
	mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
	mob.linear_velocity = mob.linear_velocity.rotated(direction)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_Player_dash():
	$DashSound.play()
	$HUD.setDashIcon(false)

func _on_Player_canDash():
	$HUD.setDashIcon(true)
