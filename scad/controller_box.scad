button_radius = 12;
square_margin = 3;
side_length = 75;
top_height = 45;
top_margin = 2;
vertical_button_position = 25;
horizontal_button_position = 25;


module box(){
    difference(){ linear_extrude(height=top_height+top_margin) square(side_length + 2 * square_margin, center = true); linear_extrude(center=true, height=2*top_height) square(side_length, center = true);
}
}

module button_holes(){
    linear_extrude(height=2*top_height){
    circle(button_radius);
    translate([vertical_button_position, horizontal_button_position]) circle(button_radius);
    translate([vertical_button_position, -horizontal_button_position]) circle(button_radius);
    translate([-vertical_button_position, horizontal_button_position]) circle(button_radius);
    translate([-vertical_button_position, -horizontal_button_position]) circle(button_radius);
    }
}

module logo(){
    translate([0,0,top_height/2]) {
        rotate([90,0,90])linear_extrude(height=1.5*side_length) scale(0.15) translate([-108,-155,0]) import("utoss_logo.dxf",center=true);
        rotate([90,0,0])linear_extrude(height=1.5*side_length) scale(0.15) translate([-108,-155,0]) import("utoss_logo.dxf",center=true);
        rotate([-90,0,0])linear_extrude(height=1.5*side_length) scale(0.15) translate([-108,-155,0]) import("utoss_logo.dxf",center=true);
        rotate([90,0,-90])linear_extrude(height=1.5*side_length) scale(0.15) translate([-108,-155,0]) import("utoss_logo.dxf",center=true);
        }
}

difference(){
    box();
    button_holes();
    logo();
}