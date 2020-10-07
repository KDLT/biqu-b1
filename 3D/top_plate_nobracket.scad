$fn = 20;

mainPlateThickness = 1.2;
mainPlateDimensions = [56, 45.8, mainPlateThickness];
usbDimensions = [10.36, 13, mainPlateThickness];

// final dimensions
pairHoleYGap = 33.45; // pair of holes near the usb slot
//pairHoleEdgeXOffset = 14.4; // from the top edge to the pair of holes (deprecated)
pairQuadHoleXGap = 14.5; // from the hole pair to the top left of quad // version = [15.15]

// absolute distance from the far edge to the reference top left hole near the big one, measured 29.55, rounded to 29.6
holeAssemblyXEdgeOffset = 29.6;

//all measured from the outer edge of mainPlate
wideHoleYOffset = 4.5;
narrowHoleYOffset = 12.8;
bigHoleYOffset = 16.85;

module mainPlate(dPlate=mainPlateDimensions, dUsb=usbDimensions, db=bigDia, ds=smallDia, h=mainPlateThickness) {
    difference() {
        cube([dPlate[0], dPlate[1], h]);
        // usb slot
        translate([0,(dPlate[1]-dUsb[1])/2,0]) 
            cube([dUsb[0], dUsb[1], h]);
        // hole Assembly
        translate([holeAssemblyXEdgeOffset,(dPlate[1]-quadHoleGaps[1])/2,0])
            holeAssembly(h=h, db=db) { 
                holeSet(d=ds, h=h);  // for the quad holes
                holeSet(d=ds, gapMatrix=[0, pairHoleYGap], h=h); // pair of holes
            };
    };
};
//mainPlate();

// Final Dimensions
smallDia = 3.15;
quadHoleGaps = [11.75, 16.8]; // [xGap, yGap]
module holeSet(h=mainPlateThickness, gapMatrix=quadHoleGaps, d=smallDia) {
    for ( x=[0, gapMatrix[0]], y=[0, gapMatrix[1]] ) {
        translate([x,y,0]) cylinder(d=d, h=h, $fn=60);
    };
};

// origin is the near top left hole from the big one
bigDia = 12;
bigHoleOffset = [2.425, quadHoleGaps[1]/2];
module holeAssembly(h=mainPlateThickness, db=bigDia, bigOff=bigHoleOffset, ds=smallDia, pairQuadGap=pairQuadHoleXGap) {
    children(0); // holeSet for the four holes;
    translate([-pairQuadGap, (-pairHoleYGap+quadHoleGaps[1])/2, 0])
        children(1); // holeSet(gapMatrix=[0, pairHoleYGap]); for the pair
    translate([bigOff[0],bigOff[1],0]) cylinder(d=db, h=h, $fn=100); // coupler hole
};
/* holeAssembly() { */ 
/*     holeSet(); */ 
/*     holeSet(gapMatrix=[0, pairHoleYGap]); */
/* }; */

capDiameter = 6; // head of the hex screw
dCoupler = 26.4; // outer diameter and then some of the ptfe coupler
totalHeight = 10; // this is the target height for the riser plus baseplate
// these offsets exist so I can place the cutout on top of the main plate hole assembly
couplerHoleXOffset = bigHoleOffset[0] + holeAssemblyXEdgeOffset;
couplerHoleYOffset = (mainPlateDimensions[1]-dCoupler)/2;
//echo(couplerHoleXOffset, couplerHoleYOffset);

// for perpendicular alignment of coupler to stepper shaft
filamentD=2;
filamentH=50;
module riserPlate(rh=totalHeight, dc=capDiameter, db=dCoupler, cxoff=couplerHoleXOffset, cyoff=couplerHoleYOffset, filament=false, filamentD=filamentD, filamentH=filamentH) {
// basically the main plate but has a cutout in front
    difference() {
        mainPlate(ds=dc, h=rh, db=db);
        translate([cxoff, cyoff, 0]) 
            cube([db, db, rh]);
    };
    echo("couplerYOffset+db/2", cyoff+db/2);
    echo("couplerXOffset", cxoff);
    if (filament) { translate([cxoff, cyoff+db/2, 0]) cylinder(h=filamentH, d=filamentD); };
};
//riserPlate();

// combined mainPlate and riserPlate here
module topPlate(dPlate=mainPlateDimensions, rh=totalHeight, dc=capDiameter, db=dCoupler, filament=false, filamentD=filamentD, filamentH=filamentH) {
    // if I want to edit this, I won't do it in the assembly, I'll go here and change it, besides, main plate dimensions are already correct
    mainPlate();
    // difference with the riser plate is I might want to lower the height, change the cap diameter, or decide to enlarge/shrink the coupler hole
    // params are my design choices versus the main plate's whose features depend on the actual aluminum plate where the hotend's mounted
    riserPlate(rh=rh, dc=dc, db=db, filament=filament, filamentD=filamentD, filamentH=filamentH);
};
//topPlate(filament=true);

hbot=7;
bottomPlateThickness=1.2;
pairHoleCouplerXGap = pairQuadHoleXGap + bigHoleOffset[0]; // 16.925
pairHoleHotendXGap = 9;
hotendEdgeYOffset = 8;
bottomBeamDimensions=[pairHoleHotendXGap + hbot, mainPlateDimensions[1], bottomPlateThickness];

module bottomPlate(sizeBeam=bottomBeamDimensions, d=smallDia, hcXGap=pairHoleCouplerXGap, heYOff=hotendEdgeYOffset) {
    /* difference() { */
    /*     cube(sizeBeam); */
    /*     translate([hbot, (sizeBeam[1]-pairHoleYGap)/2, 0]) */
    /*         holeSet(h=sizeBeam[2], gapMatrix=[0,pairHoleYGap], d=d); */
    /*     translate([0,(sizeBeam[1]-usbDimensions[1])/2,0]) */
    /*         cube([hbot-4.74,usbDimensions[1], sizeBeam[2]]); */
    /* }; */
    module bottomPlateSolid(hcXGap=hcXGap) {
        bottomPlateHorizontal();
        bottomPlateSide();
        translate([0, sizeBeam[1]-heYOff, 0])
            bottomPlateSide();
        translate([hcXGap, 0, 0])
            bottomPlateVertical();
        translate([hcXGap, sizeBeam[1]-heYOff, 0])
            bottomPlateVertical();
    };
    module bottomPlateHorizontal() {
        cube(sizeBeam);
    };
    module bottomPlateSide() {
        cube([hcXGap + 2*hbot, heYOff, sizeBeam[2]]);
    };
    module bottomPlateVertical(s=hbot, h=sizeBeam[2]) {
        cube([hbot*2,heYOff,h*2]);
    };
    module bottomPlateHoles(h=sizeBeam[2], d=smallDia, gap=[0, pairHoleYGap]) {
        holeSet(h=h, gapMatrix=gap, d=d);
    };
    // bottomPlate module amounts to this
    difference() {
        bottomPlateSolid();
        translate([hbot, (sizeBeam[1]-pairHoleYGap)/2,0])
            bottomPlateHoles();
        // testing lang muna kung sentro ang katapat ng coupler
        translate([hcXGap + hbot, heYOff/2, 0]) 
            bottomPlateHoles(h=sizeBeam[2]*2, gap=[0, sizeBeam[1]-heYOff, 0]);
    };
};

bottomPlate();
