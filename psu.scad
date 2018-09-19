include <defaults.scad>;
include <fan.scad>;

iec_size = [3, 24, 31];

module iec() {
    // IEC C14 placeholder
    color("DarkSlateGray", 1.0) {
        difference() {
            cube(iec_size);
            translate([-extra/2, 4, 3.5]) cube([2+extra/2, 16, 24]);
        }
    }
}

sfx_size = [100, 125, 63.5];
sfx_hole = 3.3;
sfx_holes = [[6.0, 6.0+113.0], [6.0, 6.0+25.7, 6.0+51.5]];

module sfx() {
    color("Silver", 1.0) {
        difference() {
            $fn = 20;
            
            cube(sfx_size);
            
            // Cut out for the fan
            translate([(sfx_size[0]-92)/2, (sfx_size[1]-92)/2, -extra/2]) cube([92, 92, extra]);
            // Cut out the standard mounting holes
            for (y = sfx_holes[0]) {
                for (z = sfx_holes[1]) {
                    translate([-extra, y, z]) {
                        rotate([0, 90, 0]) cylinder(r = sfx_hole/2, h = 30);
                    }
                }
            }
        }
    }
    
    // Add a 92mm fan in the location used by Silverstone
    translate([sfx_size[0]/2, sfx_size[1]/2, 0]) fan(92, 15, 8);
    
    // IEC C14 placeholder
    translate([-iec_size[0], sfx_size[1]-30+iec_size[2]/2, sfx_size[2]/2-iec_size[1]/2]) {
        rotate([90, 0, 0]) iec();
    }
}

sfx_l_size = [130, 125, 63.5];

module sfx_l() {
    color("Silver", 1.0) {
        difference() {
            $fn = 20;
            
            cube(sfx_l_size);
            
            // Cut out for the fan
            translate([(sfx_l_size[0]-92)/2, (sfx_l_size[1]-92)/2, -extra/2]) cube([92, 92, extra]);
            // Cut out the standard mounting holes
            for (y = sfx_holes[0]) {
                for (z = sfx_holes[1]) {
                    translate([-extra, y, z]) {
                        rotate([0, 90, 0]) cylinder(r = sfx_hole/2, h = 30);
                    }
                }
            }
        }
    }
    
    // Add a 92mm fan in the location used by Silverstone
    translate([sfx_l_size[0]/2, sfx_l_size[1]/2, 0]) fan(92, 15, 8);
    
    // IEC C14 placeholder
    translate([-iec_size[0], sfx_l_size[1]-30+iec_size[2]/2, sfx_l_size[2]/2-iec_size[1]/2]) {
        rotate([90, 0, 0]) iec();
    }
}

module sfx_cutout() {
    // Cut out the standard mounting holes
    for (y = sfx_holes[0]) {
        for (z = sfx_holes[1]) {
            translate([-15, y, z]) {
                rotate([0, 90, 0]) cylinder(r = sfx_hole/2, h = 30);
            }
        }
    }
    
    // Exhaust cutout
    translate([-15, sfx_holes[0][0]+wall+sfx_hole/2, wall]) cube([30, sfx_size[1]-wall*2-sfx_hole-sfx_holes[0][0]*2, sfx_size[2]-wall*2]);
}

flexatx = [81.5, 40];
flexatx_hole = 3.3;
flexatx_hole_a = [81.5-75.9, 4.1];
flexatx_hole_b = [81.5-75.9, 4.1+31.5];
flexatx_hole_c = [81.5-15.2, 36.5];

module flexatx(length) {
    color("Silver", 1.0) {
        difference() {
            $fn = 20;
            
            cube([length, flexatx[0], flexatx[1]]);
            
            // Cut out the standard mounting holes
            for (hole = [flexatx_hole_a, flexatx_hole_b, flexatx_hole_c]) {
                translate([-extra, hole[0], hole[1]]) {
                    rotate([0, 90, 0]) cylinder(r = flexatx_hole/2, h = 30);
                }
            }
            translate([-extra, flexatx[0]-52.4-40/2, -extra/2]) cube([15+extra, 40, 40+extra]);
        }
    }
    
    // Add a 40mm fan in the location used by Delta
    translate([0, flexatx[0]-52.4, flexatx[1]/2]) rotate([0, 90, 0]) fan(40, 15, 6);
    
    // IEC C14 placeholder
    translate([-iec_size[0], flexatx[0]-iec_size[1]-4.4, 2]) {
        iec();
    }
}

module flexatx_cutout(fan) {
    $fn = 20;
    cutout_extra = 0.5;
    
    // Mounting holes
    for (hole = [flexatx_hole_a, flexatx_hole_b, flexatx_hole_c]) {
        translate([-15, hole[0], hole[1]]) {
            rotate([0, 90, 0]) cylinder(r = flexatx_hole/2, h = 30);
        }
    }
    
    // IEC power plug hole
    translate([-15, flexatx[0]-iec_size[1]-4.4-cutout_extra, 2-cutout_extra]) {
        cube([30, iec_size[1]+cutout_extra*2, iec_size[2]+cutout_extra*2]);
    }
    
    // Fan hole
    if (fan == true) {
        $fn = 50;
        
        translate([-15, flexatx[0]-52.4, flexatx[1]/2]) rotate([0, 90, 0]) cylinder(r = 20, h = 30);
    }
}

//flexatx(150);
//% flexatx_cutout(true);

//sfx();
//% sfx_cutout();

//sfx_l();
//% sfx_cutout();
