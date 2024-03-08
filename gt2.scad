// Gears and belts GT2
use <base.scad>;
/// GT2
gt2_step = 2;
gt2_teeth_height = 0.75;
gt2_teeth_width = gt2_step / 3;
gt2_belt_thickness = 0.75;
gt2gear_width_default = 7.2;
gt2lock_teeth_height_default = 1;
module gt2lock_pattern(n_pin = 10, width = 9, 
    teeth_height = gt2lock_teeth_height_default, support = 1)
{
    union() {
        translate([gt2_step / 4, 0, 0])
            array([n_pin, 1, 1], step = [gt2_step, 0, 0], center = true)
                cube([gt2_step / 2, width, teeth_height], center = true);
        translate([0, 0, support / 2 + teeth_height / 2])
            cube([n_pin * gt2_step, width, support + 0.01], 
                center = true);
    }
}

module gt2lock_minimal(n_pin = 10, gap = 5, width = 9, support = 1,
    wall = 1, teeth_height = gt2lock_teeth_height_default, 
    belt_thickness = gt2_belt_thickness)
{
    pattern_length = n_pin * gt2_step;
    total_size = [pattern_length * 2 + gap, 
                  width + wall, 
                  support * 2 + teeth_height + belt_thickness];
    union(){
        mirrorcp([1, 0, 0]) translate([pattern_length / 2 + gap / 2, 0, 
            total_size[2] / 2 - support - teeth_height / 2])
                gt2lock_pattern(n_pin = n_pin, width = width, 
                    teeth_height = teeth_height, support = support);
        // wall
        translate([0, width / 2 + wall / 2, 0]) 
            cube([total_size[0], wall, total_size[2]], center = true);
        // gap
        cube([gap, width, total_size[2]], center = true);
        // support
        translate([0, 0, -total_size[2] / 2 + support / 2]) 
            cube([total_size[0], width, support], center = true);
    }
}
module gt2gear_teeth(width = gt2gear_width_default, n_teeth = 20, hole_d = 5)
{
    r_out = gt2_step * n_teeth / (2 * PI) - 0.25;
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
                        rx = gt2_teeth_width, ry = gt2_teeth_height);
            }
        }
    }
}

module gt2belt_sync(w = 6, l = 100, gear = 20)
{
    r_out = gt2_step * gear / (2 * PI) - 0.25;
    mirrorcp([1,0,0]) mirrorcp([0,0,1])
    translate([l/4,0,-r_out-gt2_belt_thickness/2])
    union() {
        cube([l/2, w, gt2_belt_thickness], center=true);
        translate([0,0,gt2_belt_thickness/2])
        array([floor(l/4), 1, 1], step = [gt2_step, 0, 0], center = true)
                rotate([90,0,0])
                ellipse_cylinder(h = w, rx = gt2_teeth_width, 
                                 ry = gt2_teeth_height);
    }
    
    mirrorcp([1,0,0]) 
    translate([l/2,0,0])
    union() {
        difference() {
            rotate([90,0,0])
            cylinder(h=w,r=r_out+gt2_belt_thickness,center=true);
            rotate([90,0,0])
            cylinder(h=w+1,r=r_out,center=true);
            translate([-r_out,0,0])
            cube([2*r_out,w+1,4*r_out], center=true);
        }
        for (t = [1:gear/2]) {
            phi = (t-0.5)*360/gear;
            translate([r_out * sin(phi), 0, r_out * cos(phi)])
                    rotate([90,0,0])
                    ellipse_cylinder(h = w, 
                        rx = gt2_teeth_width, ry = gt2_teeth_height);
            }
    }
}

$fn=100;
gt2gear_teeth(n_teeth = 100);
