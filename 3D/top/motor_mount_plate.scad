include <motor_mount.scad>;
include <top_plate_nobracket.scad>;

mainPlateThickness = 1.2;
mainPlateDimensions = [56,45.8, mainPlateThickness];

// gap between the aluminum base plate and outlet of extruder
riseHeight = 10; // versions = [10, 13, 16]
// sleeve height is along y now kasi rotated
sleeveHeight = 12; // versions = [10, 12]
motor_sideLength = 43; // original 42.5
sleeveThickness = 3.2; // versions = [2, 3, 3.2, 2.4, 3.2]
//chamferSize=4; 
echo("chamferSize in motor_mount_plate", chamferSize);
facePlateHeight=1.2; // versions = [1.6, 2.4, 1.2]

//sleeve(t=sleeveThickness); // delta=t was corrected in motor_mount.scad

// still adjusting this one
//motorMountOffset=[19,5,10+sleeveThickness]; TRIAL1, overshot right and forward
//motorMountOffset=[15,2,riseHeight+sleeveThickness]; //Trial 2, overshot left and backward
//motorMountOffset=[15.5, 4, riseHeight+sleeveThickness]; // Trial 3, y needs to go right, x needs to... stay there
// 6.06 = couplerYOffset + couplerDiameter/2 -> check in riserPlate module
// 15.35 = couplerXOffset - (motorsidelength - shaftDia)/2 + filamentRadius
//motorMountOffset=[15.35, 6.06, riseHeight+sleeveThickness]; // Trial 4, dapat tama na itokasi kinompyut ko na puta... y offset is still wrong, i overshot to the right
motorMountOffset=[15.3, 4.56, riseHeight+sleeveThickness]; // Trial 5 (sipat) 15.3 na kasi nilakihan ko by 0.5 ang motor_sideLength para lumuwag, GOOD

// vertical holes na horizontal talaga ang pasok, I don't know what I was thinking
verticalMountHolesDiameter = 3;
verticalMountHolesGap = 16.64 + verticalMountHolesDiameter;
verticalMountHolesDepth = 7.6; //depth of cut for the mounting screw
verticalMountBaseOffset = 4.72; // from the aluminum base to the mounting holes

totalHeight = 10; // of the topPlate (main and riser combined)

// distance from Filament vertical path to faceplate of motor housing, a very crude physical measurement
filamentFaceplateYOffset = 18; // versions = [16.84, 18]
module motorBracketAssembly(shaftView=false, filamentView=false, th=totalHeight, hd=verticalMountHolesDepth) {
    
    module vertHoles(d=verticalMountHolesDiameter, gap=verticalMountHolesGap, hd=verticalMountHolesDepth, bh=verticalMountBaseOffset) {
    // bolts the entire assembly from behind the aluminum mounting plate with the vrollers
    // precariously secures (oxymoron) the stepper, extruder, hotend assembly to the hotend backplate
        translate([0,(mainPlateDimensions[1]-gap)/2,bh])
        rotate([0,90,0]) {
            cylinder(d=d, h=hd);
            translate([0,gap,0]) cylinder(d=d, h=hd);
        };
    };
    //vertHoles();

    module motorHousingAndBase(l=motor_sideLength, h=facePlateHeight, mo=motorMountOffset, t=sleeveThickness, sh=sleeveHeight, rh=riseHeight, c=chamferSize, shaft=false, shaftD=2, shaftH=18) {
        v = t*tan(atan(c/c)/2); echo(v);

        module motorSleeveBase(rh=riseHeight, c=chamferSize, t=sleeveThickness, hs=sleeveHeight) {
            // riser base, with chamfer carried over
            v = t*tan(atan(c/c)/2); echo(v); 
            //baseDimensions=[motor_sideLength - c*2 + 2*v, hs, rh];
            baseDimensions=[motor_sideLength-c+v+t, hs, rh];
            difference() {
                cube(baseDimensions);
                // cutting triangle
                rotate([-90,0,0])
                //translate([baseDimensions[0]-rh,0,0])
                translate([baseDimensions[0]-rh, 0, 0])
                    linear_extrude(height=hs) {
                        polygon(points=[[0,0],[rh,0],[rh,-rh]]);
                    };
            };
        };
        //motorSleeveBase();

        module motorSleeveBrace(b=mainPlateDimensions[1]/2, h=l/2+t) {
            rotate([0,-90,0])
            linear_extrude(height=t/2) { polygon(points=[[0,0], [h,0], [0,b]]); }
        };
        //motorSleeveBrace();

        translate([mo[0]-sleeveThickness/2, 0, mo[2]-sleeveThickness])
            motorSleeveBrace(h=2*l/3, b=2/3*mainPlateDimensions[1]);// 2/3 of motor_sideLength
            //motorSleeveBrace(h=l/2);
        translate(mo) {
            rotate([90,0,0]) {
                motorHousing(l=l, h=h, t=t, sh=sh, c=c, shaft=shaft, shaftD=shaftD, shaftH=shaftH);
            };
        };
        //translate([mo[0]+c-v, mo[1]-sh, 0])
        translate([mo[0]-t, mo[1]-sh, 0])
            motorSleeveBase(t=t);
    };
    //motorHousingAndBase();

    motorHousingAndBase(shaft=shaftView, shaftD=7.4, shaftH=filamentFaceplateYOffset);
    difference() {
        // other params for topPlate should be changed in top_plate_nobracket.scad
        topPlate(dc=capDiameter, rh=th, filament=filamentView, filamentD=1.75); // this is the main plate plus the riser
        vertHoles(hd=8); //hole depth versions = [8]
    };

};
motorBracketAssembly(shaftView=false, filamentView=false, th=10);
