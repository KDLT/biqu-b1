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

// main plate shoulder cuts
shoulderDimensions=[4.5,4.5];

module mainPlate(dPlate=mainPlateDimensions, dUsb=usbDimensions, db=bigDia, dsp=smallDia, dsq=smallDia, h=mainPlateDimensions[2], sd=shoulderDimensions) {
    difference() {
        cube([dPlate[0], dPlate[1], h]);
        // usb slot
        translate([0,(dPlate[1]-dUsb[1])/2,0]) 
            cube([dUsb[0], dUsb[1], h]);
        // cutout on the shoulders
            cube([sd[0],sd[1],h]);
        translate([0,dPlate[1]-4.5,0]) 
            cube([sd[0],sd[1],h]);
        // hole Assembly
        translate([holeAssemblyXEdgeOffset,(dPlate[1]-quadHoleGaps[1])/2,0])
            holeAssembly(h=h, db=db) { 
                holeSet(d=dsq, h=h);  // for the quad holes
                holeSet(d=dsp, gapMatrix=[0, pairHoleYGap], h=h); // pair of holes
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

capDiameter = 6.5; // head of the hex screw
dCoupler = 26.4 - 3; // outer diameter and then some of the ptfe coupler
totalHeight = 10; // this is the target height for the riser plus baseplate
// these offsets exist so I can place the cutout on top of the main plate hole assembly
//couplerHoleXOffset = bigHoleOffset[0] + holeAssemblyXEdgeOffset;
//couplerHoleYOffset = (mainPlateDimensions[1]-dCoupler)/2;
couplerHoleXOffset = bigHoleOffset[0] + holeAssemblyXEdgeOffset;
couplerHoleYOffset = (mainPlateDimensions[1]-dCoupler)/2;
//echo(couplerHoleXOffset, couplerHoleYOffset);

// for perpendicular alignment of coupler to stepper shaft
filamentD=1.75;
filamentH=50;
module riserPlate(mainD=mainPlateDimensions, rh=totalHeight, dc=capDiameter, db=dCoupler, cxoff=couplerHoleXOffset, cyoff=couplerHoleYOffset, filament=false, filamentD=filamentD, filamentH=filamentH) {
// basically the main plate but has a cutout in front
    difference() {
        // dsq is diameter of the four holes, i set this separate from the pair defined by dsp
        // para hindi makain 'yung wall sa kaliwa ni top left quad, same lang ang riser hole diameter sa main
        mainPlate(dsq=smallDia, dsp=smallDia, h=rh, db=db); // smallDia on dsp becasue cap diameter doesn't matter up topanymore
        // cube cutout below (-x) coupler hole
        translate([cxoff, cyoff, 0]) 
            cube([mainD[0]-cxoff, db, rh]);
        rightCutoutDimensions=[mainD[0]-(cxoff-db/2),mainD[1]/2,rh];
        translate([cxoff-db/2, rightCutoutDimensions[1], 0])
            cube(rightCutoutDimensions);
    };
    echo("couplerYOffset+db/2", cyoff+db/2);
    echo("couplerXOffset", cxoff);
    if (filament) { translate([cxoff, cyoff+db/2, 0]) cylinder(h=filamentH, d=filamentD); };
};
//riserPlate();

/* couplerHoleXOffset = bigHoleOffset[0] + holeAssemblyXEdgeOffset; */
/* couplerHoleYOffset = (mainPlateDimensions[1]-dCoupler)/2; */
/* //echo(couplerHoleXOffset, couplerHoleYOffset); */

/* // for perpendicular alignment of coupler to stepper shaft */
/* filamentD=1.75; */
/* filamentH=50; */
/* module riserPlate(mainD=mainPlateDimensions, rh=totalHeight, dc=capDiameter, db=dCoupler, cxoff=couplerHoleXOffset, cyoff=couplerHoleYOffset, filament=false, filamentD=filamentD, filamentH=filamentH) { */

// combined mainPlate and riserPlate here
module topPlate(dPlate=mainPlateDimensions, rh=totalHeight, dc=capDiameter, db=dCoupler, filament=false, filamentD=filamentD, filamentH=filamentH, cxoff=couplerHoleXOffset, cyoff=couplerHoleYOffset) {
    // if I want to edit this, I won't do it in the assembly, I'll go here and change it, besides, main plate dimensions are already correct
    mainPlate();
    // difference with the riser plate is I might want to lower the height, change the cap diameter, or decide to enlarge/shrink the coupler hole
    // params are my design choices versus the main plate's whose features depend on the actual aluminum plate where the hotend's mounted
    riserPlate(rh=rh, dc=dc, db=db, filament=filament, filamentD=filamentD, filamentH=filamentH, cxoff=cxoff, cyoff=cyoff);
};
//topPlate(filament=false);
