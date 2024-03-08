// For mechanics only
use <base.scad>;

// Fish top with stem. Angle must be between 0 and 90.
// Female fish top - is a difference(cube, male)
// Stem - for male, Shell - for female
// Shell = [side(X), back(Y)] or scalar
module fishtop(gender = "m", size = 1, depth = 1, 
    angle = 45, length = 1, backlash = 0, stem = 0, shell = 1)
{
    if (angle >= 90 || angle <= 0) echo("Fish top: Wrong angle!");
    if (gender == "m") {
        real_size = size + 2*backlash;
        real_depth = depth + backlash;
        minor_size = size - 2*depth/tan(angle) + 2*backlash;
        union() {
            linear_extrude(height = length, center = true, scale = 1.0)
            {
                polygon(points = [[-real_size/2, backlash],
                    [-real_size/2, 0], [real_size/2, 0],
                    [real_size/2, backlash],
                    [minor_size/2, real_depth], 
                    [-minor_size/2, real_depth]]);
            }
            translate([0, real_depth + stem / 2 - 0.01, 0]) 
                cube([minor_size, stem, length], center = true);
        }
        
    } else {
        side_shell = (len(shell) > 1) ? shell[0] : shell;
        back_shell = (len(shell) > 1) ? shell[1] : shell;
        difference() {
            translate([0, depth/2 - back_shell/2, 0])
                cube([size + 2 * side_shell, 
                    depth + back_shell, length], 
                    center = true);
            fishtop(gender = "m", size = size, depth = depth, 
                angle = angle, length = length + 0.01, 
                backlash = backlash, stem = 0.1);
        }
    }
}

// Box
// You must set any two parameters. Thrid parameter is redundant.
// External, internal and shell must be a vectors.
// shell[2] (Z) - is a bottom width
module box(external = 0, internal = 0, shell = 0)
{
    ext_size = (external) ? external : internal + 
        [shell[0]*2, shell[1]*2, shell[2]];
    int_size = (internal) ? internal : external - 
        [shell[0]*2, shell[1]*2, shell[2]];
    shell_size = (shell) ? shell : 
        [(external[0] - internal[0]) / 2,
         (external[1] - internal[1]) / 2,
         external[2] - internal[2]];
    difference(){
        cube(ext_size, center = true);
        translate([0, 0, shell_size[2]/2 + 0.01])
            cube(int_size + [0, 0, 0.02], center = true);
    }
}

// Stuff for bolt and nut mount. Add it in difference
// Required parameters: l - full bolt length. d - bolt diameter, 
// Additional parameters: depth - hat and nut depth, hex - nut width, hat_d - botl hat diameter
module bolt_nut_mount(l = 10, d = 3, depth = 0, hex = 0, hat_d = 0)
{
    hat_depth = (depth == 0) ? d : depth;
    hex_depth = (depth == 0) ? d : depth;
    bolt_hat_d = (hat_d == 0) ? 2*d : hat_d;
    hex_w = (hex == 0) ? (1.7 + 5.4 / pow(d, 3)) * d : hex;
    union() {
        cylinder(d = d, h = l, center = true);
        translate([0, 0, l/2 - hat_depth/2]) cylinder(d = bolt_hat_d, h = hat_depth, center = true);
        translate([0, 0, -l/2 + hat_depth/2]) prism(h = hex_depth) hexagon(hex_w);
    }
}


// Pipe
module pipe(outer_diameter, inner_diameter, length, resolution = 0.1)
{
    $fs = resolution;
    difference() {
        cylinder(h = length, r = outer_diameter / 2, 
            center = true);
        cylinder(h = length + 0.01, r = inner_diameter / 2, 
            center = true);
    }
}

// Holder for cylinder
// n_holes - number of holes - can be scalar or [x_holes, z_holes]
module pipe_collar(cylinder_d = 10, holder_d = 5, holder_h = 10, 
    gap = 1, clamp_l = 1, clamp_w = 1, n_holes = 0, hole_d = 3, bolt_places = false)
{
    holder_shell = (holder_d - cylinder_d)/2;
    clamp_full_l = clamp_l + holder_d/2;
    hole_points_z = (len(n_holes) == undef) ? 
        [-holder_h * (n_holes/(n_holes + 1) - 1/2):
         holder_h/(n_holes + 1):
         holder_h * (n_holes/(n_holes + 1) - 1/2) + 0.01] : 
        [holder_h/2 - hole_d, -holder_h/2 + hole_d];
    difference() {
        union() {
            cylinder(r = holder_d/2, h = holder_h, center = true);
            // clamp
            translate([clamp_full_l/2, 0, 0])
                cube([clamp_full_l, clamp_w*2 + gap, holder_h], 
                    center = true);
        }
        union() {
            cylinder(r = cylinder_d/2, h = holder_h + 0.01, 
                center = true);
            // gap
            translate([holder_d/2 - (holder_shell - clamp_l)/2, 0, 0]) 
                cube([clamp_l + holder_d/2 + 0.01, gap, 
                    holder_h + 0.01], center = true);
            // holes
            for (z = hole_points_z) {
                translate([cylinder_d/2 + clamp_l/2 + holder_shell*3/4, 0, z]) 
                rotate([90, 0, 0])
                if (bolt_places) {
                    bolt_nut_mount(l = clamp_w*2 + gap + 0.01, d = hole_d);
                } else {
                    cylinder(r = hole_d/2, h = clamp_w*2 + gap + 0.01, 
                        center = true);
                }
            }
        }
    }
}

$fn = 64;
pipe_collar(cylinder_d = 16, holder_d = 20, holder_h = 10, gap = 3,
    clamp_l = 7, clamp_w = 3, n_holes = 2, hole_d = 2);
