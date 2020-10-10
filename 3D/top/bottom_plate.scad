// following params are from top_plate_nobracket.scad
mainPlateThickness = 1.2;
mainPlateDimensions = [56, 45.8, mainPlateThickness];
usbDimensions = [10.36, 13, mainPlateThickness];

smallDia = 3.15;
quadHoleGaps = [11.75, 16.8];
pairQuadHoleXGap = 14.5;
pairHoleYGap = 33.45;
bigHoleOffset = [2.425, quadHoleGaps[1]/2];

// this is basically the padding of the gap between the pair of mounting holes and the center of coupler along x
hbot=4.72; // versions = [4, 5, 4.72]
bottomPlateThickness=3; // versions = [1.2, 1.8, 3]
pairHoleCouplerXGap = pairQuadHoleXGap + bigHoleOffset[0]; // 16.925
pairHoleHotendXGap = 11; // versions = [9,12,11]
hotendY = 30; // size of hotend (heatsink talaga) along y axis
hotendZ = 30 + 0.12; // sizeo f hotend (heatsink talaga) along z axis
verticalHeight=hotendZ; // hotendZ = 30, kaya may +1 kasi maybridge na lulundo, off ko muna ang +1 kasi may bridge naman na;
topBeamThickness = 2; //ito ang bridge para hindi sakang ang verticals
hotendEdgeYOffset = (mainPlateDimensions[1] - hotendY)/2 - 0.2; echo("heYOff", hotendEdgeYOffset); // -0.2 kasi sobrang sikip ng true value
bottomBeamDimensions=[pairHoleHotendXGap + hbot, mainPlateDimensions[1], bottomPlateThickness];
module bottomPlate(sizeBeam=bottomBeamDimensions, d=smallDia, hcXGap=pairHoleCouplerXGap, heYOff=hotendEdgeYOffset, hh=bottomBeamDimensions[2], hbot=hbot) {
    module bottomPlateSolid() {
        //translate([0,(sizeBeam[1]-pairHoleYGap)/2,0])
        difference() {
            union() {
                bottomPlateHorizontal();
                bottomPlateSide();
                translate([0, sizeBeam[1]-heYOff, 0])
                    bottomPlateSide();
                translate([hcXGap, 0, verticalHeight]) // bridge between the verticals
                    bottomPlateHorizontal(dPlate=[2,mainPlateDimensions[1],2]);
            };
            translate([hbot, (sizeBeam[1]-pairHoleYGap)/2,0])
                bottomPlateHoles();
        };
    };
    bottomPlateSolid(); //bottomPlate amounts to this

    module bottomPlateHoles(d=smallDia, gap=pairHoleYGap , h=hh) {
        cylinder(d=d, h=h, $fn=20);
        translate([0, gap, 0]) cylinder(d=d, h=h, $fn=20);
    };
   // bottomPlateHoles();

    module bottomPlateHorizontal(dPlate=sizeBeam, h=sizeBeam[2]) {
        module bottomPlateUsb() {
            usbCutoutX = hbot - 4.74; // 4.74 is the gap between the pair of holes and edge of cutout
            cube([usbCutoutX, usbDimensions[1], sizeBeam[2]]);
    };
        difference() {
            cube(dPlate);
            translate([0,(sizeBeam[1]-usbDimensions[1])/2,0])
                bottomPlateUsb();
        };
    };
    //bottomPlateHorizontal();

    module bottomPlateSide() {
        cube([hcXGap + 2*hbot, heYOff, sizeBeam[2]]); // this is where the hbot as padding kicks in
        chamferHeight=2*hbot;
        // distance of the "zero" nut position from the base
        nutBaseOffset=5; // versions = [6, 5]
        nutDia=7.2; // versions = [6, 7, 6.4, 7.2]
        boltDia=3.5;
        nutHeight=2.5; // versions = [3, 2.5] // ito ang kapal ng _nakahiga_ na nut
        roofHeight=1.2;
        module bottomPlateVertical(s=hbot, h=verticalHeight, c=chamferHeight) {
            module bottomPlateChamfer(c=c) {
                translate([0,heYOff,0]) rotate([90,0,0])
                linear_extrude(height=heYOff) {
                        polygon(points=[[0,0],[0,c],[-c,0]]);
                }
            };
            bottomPlateChamfer(); //gotta call this if I want a chamfer
            module nutSlot(dn=nutDia, nh=nutHeight, db=boltDia, nih=nutBaseOffset, rh=roofHeight) {
            // nih means nut initial height (from base)
            nsYOff = (heYOff - nh)/2; // nutSlotOffset
            bsXOff = (dn - db)/2; // boltSlotXOffset
            bsY = (heYOff-nh)/2; // bolt slot Y thickness
            vSlotZ = h-rh-nih; // vertical slots height
                translate([s, 0, nih]) rotate([-90,0,0]) // horizontal hole at the column base
                    cylinder(h=heYOff, d=db, $fn=20);
                translate([s-dn/2, nsYOff, nih/2]) cube([s+dn/2, nh, dn]); // horizontal nut slot
                translate([s-dn/2, nsYOff, nih]) cube([dn, nh, vSlotZ]); // vertical nut slot
                translate([s-dn/2+bsXOff, 0, nih]) cube([db, bsY, vSlotZ-dn/2]); // vertical bolt slot 1
                translate([s-dn/2+bsXOff, heYOff-bsY, nih]) cube([db, bsY, vSlotZ-dn/2]); // vertical bolt slot 2
                translate([s, 0, h-rh-dn/2]) rotate([-90,0,0]) // horizontal hole at the column top
                    cylinder(h=heYOff, d=db, $fn=20);
            };
            //nutSlot(nh=2.5);
            difference() {
                cube([s*2,heYOff,h]);
                nutSlot(nh=2.5);
            };
        };
        translate([hcXGap, 0, 0])
            bottomPlateVertical(c=11); 
    };
    //bottomPlateSide();
};
bottomPlate();
