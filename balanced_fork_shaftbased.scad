use </home/cat/Projects/UniversalTools/CADLIB/base.scad>;
use </home/cat/Projects/UniversalTools/CADLIB/motor_mount.scad>;
use </home/cat/Projects/UniversalTools/CADLIB/gears.scad>;

/// --- Arm parts ---

// ARM END
// shaft_gap - is a distance between centers of two supporting shafts
// in Z dimention (vertical)
// wall_shift - change wall position to change distance between centers of two arm_ends
// wall_shift = center, inner (to decrease arm_end's gap) or outer (to increase it)
module arm_end(shaft_gap, bearing = [22, 8, 7], 
    support_shaft = 8, bolt = 3, length = 0, shell = 1, wall = 0,
    bearing_backlash = 0.1, shaft_backlash = 0.1, wall_shift = "center", bear_shift = "side",
    resolution = 0.1)
{
    arm_end_length = (length) ? length: bearing[0] + 2 * shell;
    arm_end_width = (wall) ? wall: bearing[2] + shell;
    wall_offset = (wall_shift == "center") ? 0 :
    			  (wall_shift == "inner") ? (support_shaft - arm_end_width) / 2 + shell :
    			  (wall_shift == "outer") ? (arm_end_width - support_shaft) / 2 - shell : 
    			  0;
    bear_offset = (bear_shift == "center") ? 0 :
    			  (bear_shift == "side") ? (arm_end_width - bearing[2]) / 2 :
    			  0;
    $fs = resolution;
    module bolt()
    {
        translate([0, (shaft_gap + support_shaft + shell) / 2, 0]) 
        	shaft(bolt, length = shell + 1, backlash = 0, dir = "y",
            	resolution = resolution); 
    }
    module support_shaft() {
		translate([0, shaft_gap / 2, 0]) 
        	shaft(support_shaft, backlash = shaft_backlash, dir = "x",
            	resolution = resolution);
	}
    difference() {
        union() {
        	translate([0 ,0 ,wall_offset])
            	cube([arm_end_length, shaft_gap, arm_end_width], center = true);
            rotate([0, 90, 0]) translate([0, shaft_gap / 2, 0])
                cylinder(h = arm_end_length, r = support_shaft / 2 + shell, center = true);
            rotate([0, 90, 0]) translate([0, -shaft_gap / 2, 0])
                cylinder(h = arm_end_length, r = support_shaft / 2 + shell, center = true); 
        }
        union() {
            translate([0, 0, bear_offset + wall_offset]) 
                bearingplace(bearing[0], bearing[1], bearing[2], 
                    backlash = bearing_backlash, resolution = resolution);
            mirrorcp([0, 1, 0]) support_shaft();
            mirrorcp([0, 1, 0]) bolt();
        }
    }
}

// ARM CENTER
// arm_width is a distance between centers of two supporting shafts
// in Y dimension (width of arm)
module arm_center(shaft_gap, arm_width, support_shaft = 8, axle_shaft = 8, 
	bolt = 3, length = 0, shell = 1, wall = 0,
	shaft_backlash = 0.1, axle_backlash = 0.1, resolution = 0.1)
{
	$fs = resolution;
	arm_center_length = (length) ? length: axle_shaft + 2 * shell;
	arm_center_support_wall = (wall) ? wall: support_shaft + 2 * shell;
	arm_center_axle_wall = (wall) ? wall: axle_shaft + 2 * shell;
	module support_shaft() {
        shaft(support_shaft, backlash = shaft_backlash, dir = "x", 
            pos = [0, arm_width / 2, shaft_gap / 2],
            resolution = resolution);
	}
	module axle_shaft() {
		shaft(axle_shaft, backlash = axle_backlash, dir = "y",
			resolution = resolution);
	}
	module support_shaft_cover() {
        shaft(support_shaft + shell * 2, backlash = 0, 
        	length = arm_center_length, dir = "x", pos = [0, arm_width / 2, shaft_gap / 2], 
        	resolution = resolution);
	}
	module side_cube() {
		translate([0, arm_width / 2, 0]) 
			cube([arm_center_length, arm_center_support_wall, shaft_gap], center = true);
	}
	module axle_cover() {
		union() {
			shaft(axle_shaft + 2 * shell, backlash = 0, 
				length = arm_width, dir = "y", resolution = resolution);
			cube([arm_center_length, arm_width, arm_center_axle_wall], center = true);
		}
	}
	module support_bolt()
    {
        	translate([0, arm_width / 2, (shaft_gap + support_shaft + shell) / 2]) 
                    shaft(bolt, length = shell + 1, backlash = 0, 
                        resolution = resolution); 
    }
	module axle_bolt(positions_y, dir)
	{
		rot_angle = (dir == "x") ? [0, 90, 0] : [0, 0, 90];
		for (y = positions_y) {
			shaft(bolt, backlash = 0, resolution = resolution, dir = dir, pos = [0, y, 0]);
		}
	}
	difference() {
		union() {
			axle_cover();
			mirrorcp([0, 0, 1]) mirrorcp([0, 1, 0]) support_shaft_cover();
			mirrorcp([0, 1, 0]) side_cube();
		}
		union() {
			axle_shaft();
			mirrorcp([0, 0, 1]) mirrorcp([0, 1, 0]) support_shaft();
			mirrorcp([0, 0, 1]) mirrorcp([0, 1, 0]) support_bolt();
			axle_bolt([-arm_width / 2, 0, arm_width / 2], "x");
			axle_bolt([-support_shaft, support_shaft], "z");
		}
	}
}

// ARM MOTOR
// Holder for motor. Depends on motor_type
// motor_bolt = [thread diameter, head diameter, head length]
// motor_base - thickness of motor mounting plate
// motor_back - thickness of intershaft support plate
// motor_shell - thickness of additional support plates
// shaft wall: can be scalar or vector of two numbers - [left (at motor side) wall, right wall]
module arm_motor_claw(shaft_gap, arm_width, support_shaft = 8, shaft_bolt = 3,
	shaft_shell = 1, shaft_backlash = 0.1, shaft_wall = 1, motor_type = "nema17", 
	motor_base = 1, motor_back = 1, motor_shell = 1, motor_bolt = 0,  
	motor_backlash = 0.1, gear_diameter = 10, gear_backlash = 1, resolution = 0.1)
{
	// depends on motor
	motor_size = motor_size(type = motor_type, backlash = motor_backlash);
	motor_bolt_places = motor_bolt_places(type = motor_type); 
	motor_bolt_size = (motor_bolt) ? motor_bolt : 
					  motor_bolt_size(type = motor_type);

	total_height = max(motor_size[1], shaft_gap + support_shaft + 2 * shaft_shell);
	total_length = motor_size[0] + motor_back;
	// shaft wall:
	shaft_wall_vec = (len(shaft_wall) == undef) ? [shaft_wall, shaft_wall] :
					 (len(shaft_wall) == 1) ? [shaft_wall[0], shaft_wall[0]] :
					 (len(shaft_wall) == 2) ? shaft_wall :
					 [shaft_wall[0], shaft_wall[1]];
	module support_shaft()
	{
		shaft(support_shaft, backlash = shaft_backlash, dir = "x", 
            pos = [0, arm_width / 2, shaft_gap / 2],
            resolution = resolution);
	}
	module support_shaft_cover()
	{
		union(){
			shaft(support_shaft + shaft_shell * 2, backlash = 0,
				dir = "x", pos = [0, arm_width / 2, shaft_gap / 2],
            	resolution = resolution, 
            	length = total_length);
			translate([0, arm_width / 2 - (support_shaft / 4 + shaft_shell / 2), 
				shaft_gap / 2])
				cube([total_length, support_shaft/2 + shaft_shell,
				  	  support_shaft + shaft_shell * 2], center = true);
			translate([0, (arm_width - support_shaft + shaft_wall_vec[0]) / 2, 0])
				cube([total_length, shaft_wall_vec[0], shaft_gap], center = true);
		}
	}
	module motor_bottom()
	{
		translate([0, (arm_width - support_shaft - motor_base) / 2, 0])
		cube([total_length, motor_base, total_height], center = true);
	}
	module motor_back()
	{
		size_y = arm_width;
		translate([-motor_size[0] / 2, 0, 0])
		cube([motor_back, size_y, total_height], 
			center = true);
	}
	module on_other_side() {
		union (){
			mirrorcp([0, 0, 1]) 
				shaft(support_shaft + shaft_shell * 2, backlash = 0, 
					dir = "x", pos = [0, -arm_width / 2, shaft_gap / 2],
            		resolution = resolution, length = total_length);
			difference() {
				translate([0, -arm_width / 2, 0])
				cube([total_length, shaft_wall_vec[1], shaft_gap], center = true);
				union() {
					shaft(gear_diameter, backlash = gear_backlash, 
						dir = "y", pos = [motor_back / 2, 0, 0], 
						resolution = resolution);
					translate([motor_back / 2 + motor_size[0] / 4, -arm_width / 2, 0])
						cube([motor_size[0] / 2 + 0.01, shaft_wall_vec[1] + 0.01, 
							  gear_diameter + 2 * gear_backlash], center = true);
				}
			}
		}
	}
	module motor_bolt() {
		union() {
			translate([0, arm_width / 2, 0])
				shaft(motor_bolt_size[0], dir = "y", pos = motor_bolt_places[0], 
					length = support_shaft + motor_base * 2.1, 
					backlash = 0, resolution = resolution);
			long_head_coeff = 1.5;
			translate([0, arm_width / 2 + 
				(-motor_bolt_size[2] + long_head_coeff * shaft_shell) / 2, 0])
				shaft(motor_bolt_size[1], dir = "y", pos = motor_bolt_places[0], 
					length = support_shaft + long_head_coeff * shaft_shell + 
					motor_bolt_size[2], backlash = 0, resolution = resolution);
		}
	}
	module support_bolt()
    {
        translate([0, arm_width / 2, (shaft_gap + support_shaft + shaft_shell) / 2]) 
        	shaft(shaft_bolt, length = shaft_shell + 1, backlash = 0, resolution = resolution); 
    }
    module motor_side()
    {
    	translate([motor_back / 2, 0, (motor_size[1] + motor_shell) / 2])
    		cube([motor_size[0], arm_width, motor_shell], center = true);
    }
	difference(){
		union() {
			motor_bottom();
			motor_back();
			mirrorcp([0, 0, 1]) support_shaft_cover();
			//on_other_side();
			//mirrorcp([0, 0, 1]) motor_side();
		}
		union(){
			mirrorcp([0, 0, 1]) mirrorcp([0, 1, 0]) support_shaft();
			translate([motor_back / 2, 0, 0])
				mirrorcp([1, 0, 0]) mirrorcp([0, 0, 1]) motor_bolt();
			mirrorcp([0, 0, 1]) mirrorcp([0, 1, 0]) support_bolt();
		}
	}
}
