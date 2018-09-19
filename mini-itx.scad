include <defaults.scad>;
include <pci_bracket.scad>;
include <fan.scad>;
include <vent.scad>;
include <psu.scad>;
include <heatsink.scad>;
include <gpu.scad>;
include <motherboard.scad>;

// Uxcell M3 threaded inserts from Amazon
insert_r = 5.3/2;
insert_h = 5.0;

module motherboard_standoff() {
    difference() {
        cylinder(r = (0.4*25.4)/2, h = miniitx_bottom_keepout);
        translate([0, 0, miniitx_bottom_keepout-insert_h]) cylinder(r = insert_r - 0.1, h = insert_h+extra);
    }
}

module motherboard_standoffs_miniitx() {
    $fn = 50;
    
    // Mounting holes for the motherboard
    translate([miniitx_hole_c[0], miniitx_hole_c[1], 0]) {
        motherboard_standoff();
        for (hole = [miniitx_hole_f, miniitx_hole_h, miniitx_hole_j]) {
            translate([hole[0], hole[1], 0]) motherboard_standoff();
        }
    }
}

// Just a little wedge to provide support for the PSU
module psu_ledge() {
    cube_size = 15;
    translate([0, extra, 0]) difference() {
        translate([-cube_size/2, 0, 0]) rotate([-45, 0, 0]) cube([cube_size, cube_size, cube_size], true);
        translate([-cube_size*1.5, -cube_size*1.5, 0]) cube([cube_size*2, cube_size*2, cube_size*2]);
        translate([-cube_size*1.5, 0, -cube_size*1.5]) cube([cube_size*2, cube_size*2, cube_size*2]);
    }
}

// The tab that the pci bracket screws into
module pci_bracket_holder() {
    $fn = 20;
    
    bottom_wall = 1.0;
    
    translate(pci_e_to_bracket) {
        difference() {
            translate([pci_bracket_back_edge, -pci_e_spacing+pci_bracket_right_edge-pci_bracket_slot_extra, -insert_h-bottom_wall]) cube([11.43, pci_e_spacing+pci_bracket_total_width+pci_bracket_slot_extra*2-2.54, insert_h+bottom_wall]);
            translate([0, 0, -insert_h]) {
                cylinder(r = insert_r - 0.1, h = insert_h+extra);
                translate([0, 0, -bottom_wall-extra/2]) cylinder(r = 1.5, h = bottom_wall+extra);
            }
            translate([0, -pci_e_spacing, -insert_h]) {
                cylinder(r = insert_r - 0.1, h = insert_h+extra);
                translate([0, 0, -bottom_wall-extra/2]) cylinder(r = 1.5, h = bottom_wall+extra);
            }
        }
    }
}

module back_to_back() {
    motherboard_miniitx(false, am4_holes, am4_socket);
    
    translate([am4_holes[0], am4_holes[1], am4_socket[2]+miniitx[2]]) cryorig_c7();

    translate([0, miniitx[1]-flexatx[1], -miniitx_bottom_keepout-wall]) {
        rotate([-90, 0, 0]) flexatx(180);
    }

    translate([pci_e_offset[0], pci_e_offset[1]+100, -40]) {
        rotate([90, 0, 0]) zotac_1080_mini();
    }
}

module traditional(show_internals, use_sfx) {
    // Airflow clearance for CPU fan
    cpu_fan_clearance = 10;
    heatsink_height = noctua_nh_l12s_size[2];
    gpu_location = [pci_e_offset[0], pci_e_offset[1], pci_e_offset[2]+miniitx[2]];
    
    case_origin = [motherboard_back_edge-wall, -pci_e_spacing*1.5, -miniitx_bottom_keepout-wall];
    case_size = [zotac_1080_mini_length+wall*3, miniitx[1]-case_origin[1]+motherboard_back_panel_overhang+motherboard_back_panel_lip, heatsink_height+cpu_fan_clearance+am4_socket[2]+miniitx[2]+flexatx[1]-case_origin[2]+wall];
    
    sfx_location = [motherboard_back_edge, case_origin[1]+case_size[1]-sfx_size[1]-wall, case_origin[2]+case_size[2]-sfx_size[2]];
    flexatx_location = [motherboard_back_edge, case_origin[1]+case_size[1]-flexatx[0]-wall, heatsink_height+cpu_fan_clearance+am4_socket[2]+miniitx[2]];
    
    // Calculate the case size in liters
    case_volume = case_size[0]*case_size[1]*case_size[2]/1000000.0;
    echo("Case dimensions X:", case_size[0], " Y:", case_size[1], " Z:", case_size[2], " L:", case_volume);
    
    corsair_h60_location = [case_size[0]-wall-corsair_h60_size[0], case_size[1]-wall*2-corsair_h60_size[1], case_size[2]-wall*2-corsair_h60_size[2]];
    case_fan_size = 92;
    case_fan_thickness = 25;
    case_fan_location = [case_size[0]-wall-case_fan_thickness, case_size[1]/2, case_fan_size/2+wall*2];
    case_exhaust_fan_size = 80;
    case_exhaust_fan_thickness = 15;
    case_exhaust_fan_location = [wall, wall+40+case_exhaust_fan_size/2, case_exhaust_fan_size+20];
    
    // Using the bottom corner of the motherboard near the GPU as the origin
    if (show_internals == true) {
        motherboard_miniitx(false, am4_holes, am4_socket);
        
        translate([am4_holes[0], am4_holes[1], am4_socket[2]+miniitx[2]]) {
            if (!use_sfx) {
                noctua_nh_l12s();
            }
        }

        if (use_sfx) {
            translate(sfx_location) {
                sfx();
            }
        } else {
            translate(flexatx_location) {
                flexatx(150);
            }
            
            // The exhaust fan only fits (sort of) with flexatx
            translate(case_origin)  {
                translate(case_exhaust_fan_location) {
                    rotate([0, 90, 0]) fan(case_exhaust_fan_size, case_exhaust_fan_thickness, 10);
                }
            }
        }

        translate(gpu_location) {
            zotac_1080_mini();
        }
        
        translate(case_origin)  {
            // Currently SFX PSU is tied to needing an AIO cooler
            if (!use_sfx) {
                translate(case_fan_location) {
                    rotate([0, 90, 0]) fan(case_fan_size, case_fan_thickness, 10);
                }
            } else {
                translate(corsair_h60_location) {
                    corsair_h60();
                }
            }
        }
    }
    
    // The actual case
    color("WhiteSmoke", 0.3) {
        // Motherboard standoffs taking threaded inserts
        translate([0, 0, -miniitx_bottom_keepout]) {
            motherboard_standoffs_miniitx();  
        }
        
        // Part that the GPU screws into
        translate(gpu_location) {
            pci_bracket_holder();
        }
        
        if (use_sfx) {
            translate(sfx_location) {
                translate([sfx_size[0], sfx_size[1], 0]) psu_ledge();
            }
        } else {
            translate(flexatx_location) {
                translate([150, flexatx[0], 0]) psu_ledge();
            }
        }
        
        difference() {
            translate(case_origin) {
                 // Back wall
                cube([wall, case_size[1], case_size[2]]);
                
                // Bottom wall
                cube([case_size[0], case_size[1], wall]);
                
                // Right wall
                translate([0, case_size[1]-wall, 0]) cube([case_size[0], wall, case_size[2]]);
                
                // Left wall
                cube([case_size[0], wall, case_size[2]]);
                
                // Top wall
                translate([0, 0, case_size[2]-wall]) cube([case_size[0], case_size[1], wall]);
                
                // Front wall
                translate([case_size[0]-wall, 0, 0]) cube([wall, case_size[1], case_size[2]]);
            }
            
            translate(case_origin) {
                translate([8, 0.2, 8]) {
                    rotate([90, 0, 0]) linear_extrude(wall) {
                        text(str(case_volume), font = "Helvetica:style=Normal", size = 20);
                    }
                }
            }
                      
            motherboard_back_panel_cutout();
            
            if (use_sfx) {
                translate(sfx_location) {
                    sfx_cutout();
                }
                
                back_panel_vent = [case_size[2]-motherboard_back_panel_size[1]-wall*2, case_size[1]-zotac_1080_thickness-sfx_size[1]-wall*2];
                translate(sfx_location) translate([0, -back_panel_vent[1]/2+wall, sfx_size[2]-back_panel_vent[0]/2-wall]) {
                    rotate([0, 90, 0]) vent_rectangular(back_panel_vent, 10, 2.0);
                }
                
                translate(case_origin) translate(corsair_h60_location) translate([corsair_h60_size[0]+wall, corsair_h60_size[1]/2-corsair_h60_fan_offset, corsair_h60_fan[0]/2]) {
                    rotate([0, 90, 0]) {
                        fan_cutout(corsair_h60_fan[0]);
                    }
                }
            } else {
                translate(flexatx_location) {
                    flexatx_cutout();
                }
                
                translate(case_origin) translate([case_exhaust_fan_location[0]-wall, case_exhaust_fan_location[1], case_exhaust_fan_location[2]]) {
                    rotate([0, -90, 0]) {
                        fan_cutout(case_exhaust_fan_size);
                    }
                }
                
                translate(case_origin) translate([case_fan_location[0]+case_fan_thickness+wall, case_fan_location[1], case_fan_location[2]]) {
                    rotate([0, 90, 0]) {
                        fan_cutout(case_fan_size);
                    }
                }
            }
            
            translate(gpu_location) {
                zotac_1080_mini_cutout();
            }
        }
    }
}

module traditional_tower_cooler() {
    motherboard_miniitx(false, am4_holes, am4_socket);
    
    translate([am4_holes[0], am4_holes[1], am4_socket[2]+miniitx[2]]) noctua_nh_u9s();

    translate([0, miniitx[1]-flexatx[1], flexatx[0]+miniitx[2]+45]) rotate([-90, 0, 0]) {
        flexatx(180);
    }

    translate([pci_e_offset[0], pci_e_offset[1], pci_e_offset[2]+miniitx[2]]) {
        zotac_1080_mini();
    }
}

traditional(show_internals = true, use_sfx = true);
