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
#			$EyeMovementPath.rotation = 0;
#			$EyeMovementPath/PathFollow2D.offset = 0;
			$Eyes.position = Vector2.ZERO;
			return;  # No need to move eyes. Return to center.
		if mouse_pos.x > 0:
			# First or fourth quadrant, use atan() directly
			direction = atan(mouse_pos.y / float(mouse_pos.x));
		elif mouse_pos.x < 0:
			# Second or third quadrant, atan() + pi/2
			direction = atan(mouse_pos.y / float(mouse_pos.x)) + PI;
		elif mouse_pos.x == 0:
			direction = PI / 2.0 if mouse_pos.y > 0 else - PI / 2.0;
		else:  # y == 0
			direction = 0.0 if mouse_pos.x > 0 else 3 * PI / 2.0;
		# You know what? Screw that. I'm gonna freaking do it myself.
		var r = clamp(distance / 5, 0, maximum_displacement_length);
		# No need to add self.center because child's position is already relative.
		$Eyes.position = Vector2(r * cos(direction), r * sin(direction))
		
#		print(direction);

#		$EyeMovementPath.rotation = direction;

		# Since PathFollow2D does not seem to update with Path2D anyhow,
		# We're going to replicate an instance here.
#		var path_node = Path2D.new();
#		var path_curve = Curve2D.new();
#		var original_curve = $EyeMovementPath.curve;
#		for i in range(original_curve.get_point_count()):
#			path_curve.add_point(
#				rotate_point(original_curve.get_point_position(i), direction),
#				original_curve.get_point_in(i),
#				original_curve.get_point_out(i)
#			);
#		path_node.curve = path_curve;
#
#		var follow_node = PathFollow2D.new()
#		follow_node.rotate = false;
#		path_node.add_child(follow_node);
#		follow_node.offset = clamp(distance / 5.0, 0, 70.99);
#
#		# Move the eye
#		$Eyes.position = follow_node.position;
#		$Eyes.position = $EyeMovementPath/PathFollow2D.position;


static func rotate_point(pt, phi):
	return pt.rotated(phi) + center;

