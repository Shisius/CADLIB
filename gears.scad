use <base.scad>;
use <mechanic.scad>;

// place for bearing
module bearingplace(outer_diameter, inner_diameter, height, 
    shaft = 100, shaft_offset = 0.0, backlash = 0.1, resolution = 0.1, center = true)
{
    $fs = resolution;
    union() {
        cylinder(h = height + 2 * backlash, 
            r = backlash + outer_diameter / 2, 
            center = center);
        translate([0, 0, shaft_offset]) cylinder(h = shaft, 
            r = backlash + inner_diameter / 2, 
            center = center);
    }
    
} 

// Shaft
module shaft(diameter, length = 100, backlash = 0.1, resolution = 0.1, dir = "z", pos = [0, 0, 0])
{
    angle = (dir == "x") ? [0, 90, 0]:
            (dir == "y") ? [90, 0, 0]:
            [0, 0, 0];
    translate(pos) rotate(angle)
        cylinder(h = length, r = backlash + diameter / 2, center = true, $fs = resolution);
}

// Truncated shaft like motor shaft
// Trunc parameter - truncation depth
module truncated_shaft(diameter, trunc_depth, length = 1, backlash = 0.1, dir = "z", pos = [0, 0, 0])
{
    angle = (dir == "x") ? [0, 90, 0]:
            (dir == "y") ? [90, 0, 0]:
            [0, 0, 0];
    real_trunc_depth = trunc_depth;
    translate(pos) rotate(angle)
        difference() {
            cylinder(h = length, r = backlash + diameter / 2, center = true);
            translate([backlash + diameter / 2, 0, 0])
            cube([real_trunc_depth * 2, diameter + 2*backlash, length + 0.01], center = true);
        }
}

// Shaft to shaft adapter. Support truncated shafts
// backlash = [inner_shaft_backlash, outer_shaft_backlash]
// trunc = [trunc_depth_inner, trunc_depth_outer]
module shaft2shaft(inner_diameter, outer_diameter, length = 1, trunc = [0, 0], backlash = [0.1, 0.1], dir = "z", pos = [0, 0, 0])
{
        difference() {
            truncated_shaft(outer_diameter, trunc[1], length = length, backlash = -backlash[1], dir = dir, pos = pos);
            truncated_shaft(inner_diameter, trunc[0], length = length + 0.01, backlash = backlash[0], dir = dir, pos = pos);
        }
}

// Place hole and holder for shaft
// mirrorcp = "xyz", type dimensions for mirrorcp
module add_shaftholder(diameter, shell, dir = "z", backlash = 0.1, mirrorcp = "", pos = [0, 0, 0], length = 10)
{
    mirrorcp_x = 0;

    difference() {
        union() {
            children();

            shaft(diameter + 2 * shell, length = length, dir = dir, backlash = 0, pos = pos);
        }
    }
}
$fn = 128;
shaft2shaft(5, 8, length = 20, trunc = [0.4, 0.5], backlash = [0.2, 0.2]);