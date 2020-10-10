use <mount_baseplate.scad>
//use <pcb_backplate.scad>
use <pcb_backplate_outline.scad>

$fn = 80;

// base Plate parameters
zBasePlate = 1.2;
outerPlate = [68,64,zBasePlate];

// pcb backplate paremeters
backplate=[48,40];
backplateXOffset=14;
zPCB=6;

//mount_baseplate_assembly(z=zBasePlate);
mount_baseplate_assembly(zBasePlate);
translate([backplateXOffset, (outerPlate[1]-backplate[1])/2, zBasePlate])
    //pcb_backplate_assembly(h=10);
    pcbBackplate(h=zPCB);
