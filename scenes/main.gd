extends Node

#preload
var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload('res://scenes/rock.tscn')
var barrel_scene = preload('res://scenes/barrel.tscn')
var bird_scene = preload('res://scenes/bird.tscn')


const DINO_START_POS := Vector2i(150,485)
const CAM_START_POS := Vector2i(576,324)
var score: int
const SCORE_MODIFIER : int = 10
var speed: float
const SPEED_MODIFIER : int = 5000
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25
var screen_size: Vector2i
var game_running : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	new_game()
	
func new_game():
	
	score = 0
	show_score()
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0,0)
	$Ground.position = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	
	$Hud/StartLabel.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		$Dino.position.x += speed
		$Camera2D.position.x += speed
		
		score += speed
		show_score()
		
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
	else:
		if Input.is_action_pressed('ui_accept'):
			game_running = true
			$Hud/StartLabel.hide()


func show_score():
	$Hud.get_node("ScoreLabel").text = "Score: " + str(score / SCORE_MODIFIER)
