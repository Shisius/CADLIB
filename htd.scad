use <base.scad>;

htd5_step = 5;
htd5_teeth_height = 2;
htd5_teeth_width = 2; //htd5_step / 3;
htd5_belt_thickness = 0.75;
htd5gear_width_default = 16;
htd5lock_teeth_height_default = 1;

module htd5gear_teeth(width = htd5gear_width_default, n_teeth = 20, hole_d = 5)
{
    r_out = htd5_step * n_teeth / (2 * PI) - 0.5715; //0.55;
    difference() {
        cylinder(h = width, r = r_out, center = true);
        union() {
            // hole
            cylinder(h = width + 1, d = hole_d, center = true);
            // teeth
            for (t = [0:n_teeth-1]) {
                phi = t*360/n_teeth;
                translate([r_out * cos(phi), r_out * sin(phi), 0])
                    ellipse_cylinder(h = width + 1, 
                        rx = htd5_teeth_width, ry = htd5_teeth_height);
            }
        }
    }
}
