extends Area2D


var screen_resolution;
var screen_radius;
const center = Vector2(300, 300);
const maximum_displacement_length = 300;  # In pixels


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_resolution = self.get_viewport().size;
	screen_radius = sqrt(pow(screen_resolution.x, 2) + pow(screen_resolution.y, 2));
	self.position = self.center;

func _input(event):
	if event is InputEventMouseMotion:		
		# We want to keep the eye inside the body
		# Meanwhile move it to a point on a line between the mouse and the origin
		# Depending on how far the mouse is from the origin
		var mouse_pos = event.position - self.center;
		print(mouse_pos);
		var distance = mouse_pos.length();
		# First rotate the path we're going to follow
		var direction;
		if mouse_pos.x == 0 and mouse_pos.y == 0:
			$Eyes.position = Vector2.ZERO;
			return;  # No need to move eyes. Return to center.
		if mouse_pos.x > 0:
			# First or fourth quadrant, use atan() directly
			direction = atan(mouse_pos.y / float(mouse_pos.x));
		elif mouse_pos.x < 0:
			# Second or third quadrant, atan() + pi
			direction = atan(mouse_pos.y / float(mouse_pos.x)) + PI;
		elif mouse_pos.x == 0:
			direction = PI / 2.0 if mouse_pos.y > 0 else - PI / 2.0;
		else:  # y == 0
			direction = 0.0 if mouse_pos.x > 0 else 3 * PI / 2.0;
			
		# You know what? Screw that. I'm gonna freaking do it myself.
		var r = clamp(distance / 5, 0, maximum_displacement_length);
		# No need to add self.center because child's position is already relative.
		$Eyes.position = Vector2(r * cos(direction), r * sin(direction))
		# And it works. Take that you muffin!
		# (28 lines of buggy codes deleted)
	
