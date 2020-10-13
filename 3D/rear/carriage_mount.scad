use <mount_baseplate.scad>
use <pcb_backplate.scad>

$fn = 80;

// base Plate parameters
zBaseplate = 1.2;
outerPlate = [68, 64, zBaseplate];

// pcb backplate paremeters
backplate = [48, 40];

// distance of pcbBackplate's top left hole from top edge of mountBaseplate
backplateXOffset = 14; 
zPCB = 6;

module carriageMount(zp=zPCB, zb=zBaseplate) {
    mountBaseplate(zb);
    echo("total_height", zb+zp);
    translate([backplateXOffset, (outerPlate[1]-backplate[1])/2, 0])
        pcbBackplate(h=zb+zp);
}; carriageMount();
