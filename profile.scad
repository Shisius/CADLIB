// Leading Profiles
use <base.scad>;

module square_profile(size, length = 100, dir = "x", pos = [0, 0, 0], 
    backlash = 0.1)
{
    cube_size = (len(size) == undef) ? [size, size, length] :
                (len(size) == 1) ? [size[0], size[0], length] :
                [size[0], size[1], length];
    rotation = (dir == "x") ? [0, 90, 0] :
               (dir == "y") ? [90, 0, 0] :
               [0, 0, 0];
    backlash_vec = [backlash, backlash, backlash];
    translate(pos) rotate(rotation) 
        cube(cube_size + backlash_vec, center = true);
}

// Key hole. Parameters: outer cylinder diameter, total height, 
// base width, base-to-cylinder angle, hole diameter, total length
module key_hole(d = 1, h = 2, base = 1, angle = 45, hole = 0, length = 1)
{
    trap_h = h - d/2;
    difference() {
        union() {
            prism(h = length) iso_trapezium(bottom = base, height = trap_h, angle = angle);
            translate([0, trap_h, 0])
                cylinder(r = d/2, h = length, center = true);
        }
        translate([0, trap_h, 0])
            cylinder(r = hole/2, h = length + 0.01, center = true);
    }
}

// Square channel. w - width, h - height, btm_th - bottom thickness, side_th - side_thickness, l - length
module square_channel(h = 10, w = 10, btm_th = 1, side_th = 1, l = 1)
{
    difference() {
        cube([l, w, h], center = true);
        translate([0, 0, btm_th]) cube([l + 0.01, w - side_th*2, h + 0.01], center = true);
    }
}

square_profile(10, backlash = 1);