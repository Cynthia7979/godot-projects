extends Node

export var mob_scene : PackedScene;
var score;
var in_game = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize();

func _process(delta):
	if self.in_game:
		if Input.is_action_pressed('end_game'):
			$Player._on_Player_body_entered(null);

func game_over():
	self.in_game = false;
	$ScoreTimer.stop();
	$MobTimer.stop();
	$HUD.show_game_over();
	$BGM.stop();
#	self.get_tree().call_group('mob_collision_shapes', 'set_disabled', true);

func new_game():
	self.get_tree().call_group('mobs', 'queue_free');
	self.score = 0;
	self.in_game = true;
	$HUD.update_score(str(score));
	$HUD.show_message('Get Ready!');
	$Player.start($StartPosition.position);
	$StartTimer.start();
	$BGM.play();

func _on_ScoreTimer_timeout():
	self.score += 1;
	$HUD.update_score(score);

func _on_StartTimer_timeout():
	if self.in_game:
		$MobTimer.start();
		$ScoreTimer.start();

func _on_MobTimer_timeout():
	# Spawn a new mob
	var mob : Node2D = mob_scene.instance();
	# Randomize spawning position (around the screen)
	var mob_spawn_position : PathFollow2D = $MobPath/MobSpawnPosition;
	mob_spawn_position.offset = randi();
	# Randomize direction
	var direction = mob_spawn_position.rotation + PI / 2;
	mob.position = mob_spawn_position.position;
	direction += rand_range(-PI / 4, PI / 4);
	mob.rotation = direction;
	# Randomize speed
	var velocity = Vector2(rand_range(150.0, 250.0), 0.0);
	mob.linear_velocity = velocity.rotated(direction);
	# Add the mob to the game
	self.add_child(mob);
