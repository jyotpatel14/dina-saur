extends Node

#preload
var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload('res://scenes/rock.tscn')
var barrel_scene = preload('res://scenes/barrel.tscn')
var bird_scene = preload('res://scenes/bird.tscn')
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
var bird_heights := [200, 390] 


const DINO_START_POS := Vector2i(150,485)
const CAM_START_POS := Vector2i(576,324)
var difficulty
const MAX_DIFFICULTY: int = 2
var score: int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed: float
const SPEED_MODIFIER : int = 5000
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25
var screen_size: Vector2i
var ground_height: int
var game_running : bool
var last_obs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()
	
func new_game():
	
	score = 0
	difficulty = 0
	game_running = false
	get_tree().paused = false
	show_score()
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0,0)
	$Ground.position = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Hud/StartLabel.show()
	$GameOver.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		generate_obs()
			
		$Dino.position.x += speed
		$Camera2D.position.x += speed
		
		score += speed
		show_score()
		
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed('ui_accept'):
			game_running = true
			$Hud/StartLabel.hide()

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300,500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs +1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node('Sprite2D').texture.get_height()
			var obs_scale = obs.get_node('Sprite2D').scale
			var obs_x: int = screen_size.x + score + 100 + (i * 100)
			var obs_y: int = screen_size.y - ground_height - (obs_height * obs_scale.y /2) + 5
			last_obs = obs
			add_obs(obs,obs_x,obs_y)
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) ==0:
				obs = bird_scene.instantiate()
				var obs_x: int = screen_size.x + score + 100
				var obs_y: int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)
	
		
func add_obs(obs,x,y):
	obs.position = Vector2i(x,y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body):
	if body.name == "Dino":
		game_over()
			
func game_over():
	
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
		
func show_score():
	$Hud.get_node("ScoreLabel").text = "Score: " + str(score / SCORE_MODIFIER)
	
func check_high_score():
	if score > high_score:
		high_score = score
		$Hud.get_node("HighScoreLabel").text = "High Score: " + str(score / SCORE_MODIFIER)
	
func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if (difficulty > MAX_DIFFICULTY):
		difficulty = MAX_DIFFICULTY
