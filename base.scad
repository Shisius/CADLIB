// Base function and modules for all cases

// Create [x, y, z] copies of the object 
// placed according to the step vector
module array(n_copies, step = [10,10,10], center = true)
{
    translation = (center) ? [for(i = [0:2])
            (n_copies[i] - 1) * step[i] / -2] : [0, 0, 0];
    translate(translation)
    union() {
        for (i_x = [0:n_copies[0] - 1]) {
            for (i_y = [0:n_copies[1] - 1]) {
                for (i_z = [0:n_copies[2] - 1]) {
                    translate([i_x*step[0], i_y*step[1], 
                        i_z*step[2]]) children();
                }
            }
        }
    }
}

module mirrorcp(arg) {
    children();
    mirror(arg) children();
}

module rotatecp(arg) {
    children();
    rotate(arg) children();
}

module placeclone(points) {
    union() {
        for (p = points) {
            translate(p) children();
        }
    } 
}

// cylinder with ellipse profile
module ellipse_cylinder(h = 1, rx = 1, ry = 1)
{
    scale([rx, ry, h]) cylinder(h = 1, r = 1, center = true);
}

// rectangular triangle
module rect_triangle(x = 1, y = 1)
{
    polygon(points = [[x, 0], [0, 0], [0, y]]);
}

// isosceles triangle
// set two out of three parameters
module iso_triangle(base = undef, height = undef, angle = undef)
{
    b = (base > 0) ? base : 2 * height / tan(angle);
    h = (height > 0) ? height : base * tan(angle) / 2;
    a = (angle > 0) ? angle : atan2(h, b/2);
    polygon(points = [[-b/2, 0], [0, h], [b/2, 0]]); 
}

// hexagon. Width for nut wrench.
module hexagon(width)
{
    size = width / sqrt(3);
    polygon(points = [for(a = [0:60:360]) [size*cos(a+30), size*sin(a+30)]]);
}

// octogon. Width - from rib to rib
module octogon(width)
{
    size = 0.5 * width / cos(45/2);
    polygon(points = [for(a = [0:45:360]) [size*cos(a+45/2), size*sin(a+45/2)]]);
}

// torus(outer_d, inner_d)
module torus(outer_d, inner_d, convexity = 10)
{
    rotate_extrude(convexity = convexity)
    translate([outer_d/2, 0, 0])
    circle(d = inner_d);
}

// isosceles trapezium
// set three out of four parameters
module iso_trapezium(bottom = undef, top = undef, height = undef, angle = undef)
{
    b = (bottom > 0) ? bottom : top + 2 * height / tan(angle);
    t = (top > 0) ? top : bottom - 2 * height / tan(angle);
    h = (height > 0) ? height : abs(bottom - top) * tan(angle) / 2;
    a = (angle > 0) ? angle : atan2(h, abs(bottom - top) / 2);
    polygon(points = [[-b/2, 0], [-t/2, h], [t/2, h], [b/2, 0]]);
}

// create prism from polygon
module prism(h = 1, center = true)
{
    linear_extrude(height = h, center = center, scale = 1.0)
    {
        children();
    }
}


// rectangular triangle prism
// size = [x, y, z] - 2 legs and depth
// dir - direction of normal to triangle plane
module rect_triangle_prism(size = [1, 1, 1])
{
    linear_extrude(height = size[2], center = true, scale = 1.0)
    {
        rect_triangle(x = size[0], y = size[1]);
    }
}

// Circular plane sector
// angle > 0!
module sector2d(diameter, angle)
{
    support_point = (angle < 90) ? [0, 2*diameter] :
                    (angle < 270) ? [-2*diameter, 0] :
                    [0, -2*diameter];
    difference() {
        circle(d=diameter);
        polygon(points = [[0, 0], [2*diameter, 0], [2*diameter, -3*diameter], 
            [-4*diameter, -3*diameter], support_point,
            [diameter*cos(angle), diameter*sin(angle)]]);
        
    }
}

// Bow - base on sector2d
// Pos - bow position related to diameter. Can be "o" = outer, "i" = inner, "c" = center
module bow2d(diameter, angle, width, pos = "c")
{
    d_offset = (pos == "o") ? width : (pos == "i") ? -width : 0;
    d1 = diameter + width + d_offset;
    d2 = d1 - 2*width;
    difference() {
        sector2d(d1, angle);
        sector2d(d2, 360);
    }
}

// Bow - bow2d by two points - beginning and ending of bow.
// Pos - bow position related to points. Can be "o" = outer, "i" = inner, "c" = center
// Use switch to choose another bow part
module bow2d2p(point_begin, point_end, bow_r, width, switch = true, pos = "c", ext_angle = 0)
{
    dx = point_begin[0];
    dy = point_end[1];
    circle_center = [circle_center_x(point_end[0] - dx, point_begin[1] - dy, bow_r), circle_center_y(point_end[0] - dx, point_begin[1] - dy, bow_r)] + [dx, dy];
    az_begin = vector_az2d(point_begin - circle_center);
    az_end = vector_az2d(point_end - circle_center);
    az1 = (switch) ? min(az_begin, az_end) : max(az_begin, az_end);
    az2 = (switch) ? max(az_begin, az_end) : min(az_begin, az_end);
    bow_a = (az2 > az1) ? az2-az1: 360 + (az2 - az1);
    echo(az1 = az1); echo(dx = dx); echo(dy = dy);
    echo(az2 = az2); echo(az_begin = az_begin); echo(az_end = az_end);
    echo(circle_center = circle_center);

    translate([circle_center[0], circle_center[1], 0])
    rotate([0, 0, az1 - ext_angle])
    bow2d(abs(bow_r)*2, bow_a + 2*ext_angle, width, pos);
}

function vector_az2d(v) = atan2(v[1], v[0]);

function rotate_vector(a, v)
    = [[1,0,0],[0,cos(a[0]),-sin(a[0])],[0,sin(a[0]),cos(a[0])]]
    * [[cos(a[1]),0,sin(a[1])],[0,1,0],[-sin(a[1]),0,cos(a[1])]]
    * [[cos(a[2]),-sin(a[2]),0],[sin(a[2]),cos(a[2]),0],[0,0,1]] * v;

function circle_center_root(x, y, r) = sign(r) * sqrt(pow(r,2) / (pow(y,2) + pow(x,2)) - 0.25);
function circle_center_x(x, y, r) = y * circle_center_root(x, y, r) + x/2;
function circle_center_y(x, y, r) = x * circle_center_root(x, y, r) + y/2;


module bevel_cube(cube_vec, bevel)
{
    intersection() {
        intersection() {
            intersection() {
                cube(cube_vec, center = true);
                scale([1, cube_vec[1]/cube_vec[0],1])
                cylinder(d=cube_vec[0]*sqrt(2)-bevel*2, h = cube_vec[2]+1,center=true);
            }
            rotate([90,0,0])
            scale([1, cube_vec[2]/cube_vec[0],1])
            cylinder(d=cube_vec[0]*sqrt(2)-bevel*2, h = cube_vec[1]+1,center=true);
        }
        rotate([0,90,0])
        scale([1, cube_vec[2]/cube_vec[1],1])
        cylinder(d=cube_vec[1]*sqrt(2)-bevel*2, h = cube_vec[0]+1,center=true);
    }
}
