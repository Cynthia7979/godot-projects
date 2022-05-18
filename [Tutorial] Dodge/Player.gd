extends Area2D
signal hit

export var speed = 400;
export var angular_speed_degrees = 540;
var velocity = Vector2.ZERO;
var target_rotation_degrees = 0;
var screen_size;

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size;
	$AnimatedSprite.animation = 'up';
	self.hide();
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_velocity = Vector2.ZERO;
	if Input.is_action_pressed('character_right'):
		new_velocity.x = 1;
	if Input.is_action_pressed('character_left'):
		new_velocity.x = -1;
	if Input.is_action_pressed('character_up'):
		new_velocity.y = -1;
	if Input.is_action_pressed('character_down'):
		new_velocity.y = 1;
	
	new_velocity = new_velocity.normalized() * speed;

	if new_velocity.x > 0 && new_velocity.y < 0:
		target_rotation_degrees = 45;
	elif new_velocity.x > 0 && new_velocity.y > 0:
		target_rotation_degrees = 135;
	elif new_velocity.x < 0 && new_velocity.y < 0:
		target_rotation_degrees = -45;
	elif new_velocity.x < 0 && new_velocity.y > 0:
		target_rotation_degrees = -135;
	elif new_velocity.x && !new_velocity.y:
		target_rotation_degrees = 90 if new_velocity.x > 0 else -90;
	elif new_velocity.y && !new_velocity.x:
		target_rotation_degrees = 0 if new_velocity.y < 0 else -180;
	
	if new_velocity.length() != 0:  # A key is pressed. Player spins and/or moves
		# Calculate angular velocity (no inertia because I'm tired)
		var rotation_difference_degrees = 0;
		# Find the shortest "path" to getting to the desired degrees
		# Any store it in rotation_difference_degrees
		if abs(target_rotation_degrees - rotation_degrees) < \
			abs(target_rotation_degrees+360 - rotation_degrees):
			rotation_difference_degrees = target_rotation_degrees - rotation_degrees;
		else:
			rotation_difference_degrees = target_rotation_degrees+360 - rotation_degrees;
		# Actually spin the player to the desired angle
		if abs(rotation_difference_degrees) > 90:
			# Usually this means 180 degrees, which takes a long time if we spin it
			rotation_degrees = target_rotation_degrees;
		else:
			var turn_left = rotation_difference_degrees < 0;
			# We don't want to spin past the desired spot
			# And yes I'm using self because I'm Pythonic and care about readability
			self.rotation_degrees += max(-angular_speed_degrees*delta, rotation_difference_degrees)\
				if turn_left else min(angular_speed_degrees*delta, rotation_difference_degrees);
		# Finally, convert the angle to be within the [-180, 180] interval
		# So that it doesn't cause any trouble afterwards
		self.rotation_degrees = clamp_degrees(rotation_degrees);
		
		# Calculate linear velocity
		velocity *= 0.8;
		velocity += new_velocity;
		velocity.x = clamp(velocity.x, -speed, speed);
		velocity.y = clamp(velocity.y, -speed, speed);
		$AnimatedSprite.play();
	else:  # Deccelerates
		velocity *= 0.8  # Inertia
		$AnimatedSprite.stop();
	
	if velocity.length() != 0:  # Move the player
		self.position += velocity * delta;
		self.position.x = clamp(position.x, 0, screen_size.x);
		self.position.y = clamp(position.y, 0, screen_size.y);

func _on_Player_body_entered(body):
	self.hide();
	print('Hit!')
	self.emit_signal('hit');
	$CollisionShape2D.set_deferred('disabled', true)

func start(pos):
	self.position = pos;
	self.show();
#	print('Starting!')
	$CollisionShape2D.disabled = false;
	
static func clamp_degrees(degrees):
	if degrees >= -180 and degrees <= 180:
		return degrees;
	else:
		if degrees < -180:
			return degrees + 360;
		elif degrees > 180:
			return degrees - 360;
