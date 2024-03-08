// For motors mounting
use <base.scad>;
use <gears.scad>;
use <MCAD/constants.scad>

// return vector [x, y, z]
// you can specify motor backlash as vector of backlashes
function motor_size(type = "nema17", backlash = 0.1, height = 30) = 
	let(backlashes = (len(backlash) == undef) ? [backlash, backlash, backlash] :
				 	 (len(backlash) == 2) ? [backlash[0], backlash[1], 0] :
				 	 (len(backlash) == 3) ? backlash : [0, 0, 0],
		size = (type == "nema17") ? [42, 42, height] : 
			     	 				[42, 42, height])
	size + backlashes;

// return n points for bolt mounting
function motor_bolt_places(type = "nema17", dir = "y") = 
	let(rotation = (dir == "z") ? [90, 0, 0] :
				   (dir == "x") ? [0, 0, 90] : [0, 0, 0])
	(type == "nema17") ? [for (i = [-1, 1], j = [-1, 1]) rotate_vector(rotation, [i * 31/2, 0, j * 31/2])] :
	(type == "nema23") ? [for (i = [-1, 1], j = [-1, 1]) rotate_vector(rotation, [i * 47.14/2, 0, j * 47.14/2])] :
	(type == "ptz42")  ? [for (i = [-1, 1], j = [-1, 1]) rotate_vector(rotation, [i * 30.5 / (2 * sqrt(2)), 0, j * 30.5 / (2 * sqrt(2))])] :
	(type == "airbldc") ? [for (i = [-1, 1], j = [-1, 1]) rotate_vector(rotation, [i * 8, 0, j * 8])] :
						 [for (i = [-1, 1], j = [-1, 1]) rotate_vector([i * 31/2, 0, j * 31/2])];

// return [thread diameter, head diameter, head length]
// backlash = [thread_backlash, head_backlash]
function motor_bolt_size(type = "nema17", backlash = [0, 0.1]) =
	let(bolt_size = (type == "nema17") ? [3, 6, 2] :
					(type == "nema23") ? [5, 10, 4] :
					(type == "ptz42") ? [3, 6, 2] :
					  		   			 [3, 6, 2])
	[bolt_size[0] + backlash[0], bolt_size[1] + backlash[1], bolt_size[2]];

// return some body that protrudes from motor mounting plane
// You can specify height if you want to get, for example hole instead of hollow
// you should place it on motor mounting plane
module motor_protrusion(type = "nema17", backlash = 0.1, height = -1, dir = "z", pos = [0, 0, 0])
{
	cylinder_d = (type == "nema17") ? 22.0 :
				 (type == "nema23") ? 38.1 :
				 22.0;
	cylinder_h = (type == "nema17") ? 2.0 : 2.0;
	cylinder_height = (height >= 0) ? height : cylinder_h + backlash;
	angle = (dir == "x") ? [0, 90, 0]:
            (dir == "y") ? [90, 0, 0]:
            [0, 0, 0];

	translate(pos) rotate(angle) translate([0, 0, cylinder_height / 2])
		cylinder(r = cylinder_d / 2 + backlash, h = cylinder_height + 0.01, center = true);
}