// threads, screws, augers
use <base.scad>;

// auger with sector profile
// sector_a - sector angle
// rot_dir - rotation direction, 'r' - right, 'l' - left
module sector_auger(pitch, outer_d = 1, shaft_d = 0, sector_a = 90, 
    length = 10, rot_dir = "r", resolution = 0.1)
{
    dir_sign = (rot_dir == "l") ? 1 : -1;
    twist_a = dir_sign * 360 * length / pitch;
    n_slices = length / resolution;
    union() {
        linear_extrude(height = length, center = true, twist = twist_a, 
            convexity = 10, slices = n_slices, scale = 1.0)
        sector2d(outer_d, sector_a);
        cylinder(r = shaft_d/2, h = length, center = true);
    }
}

//$fn = 64;
//sector_auger(30, outer_d = 15, shaft_d = 13, sector_a = 90, 
//    length = 100, resolution = 0.1);