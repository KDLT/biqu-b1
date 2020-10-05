$fn = 20;

mainPlateThickness = 1.2;
//mainPlateDimensions = [59,45.8, mainPlateThickness];
mainPlateDimensions = [56,45.8, mainPlateThickness];

usbDimensions = [10.36, 13, mainPlateThickness];

// pair of holes near the usb slot
pairHoleYGap = 33.45;
//pairHoleEdgeXOffset = 18.4;
//pairQuadHoleXGap = 15.15;
pairHoleEdgeXOffset = 14.4; // from the top edge to the pair of holes
pairQuadHoleXGap = 15.15; // from the hole pair to the top left of quad

//all measured from the outer edge of mainPlate
wideHoleYOffset = 4.5;
narrowHoleYOffset = 12.8;
bigHoleYOffset = 16.85;

module mainPlate(d=mainPlateDimensions, du=usbDimensions, holeYGap=quadHoleGaps[1]) {
    difference() {
        cube(d);
        translate([0,(d[1]-du[1])/2,0]) cube(du);
        translate([pairHoleEdgeXOffset+pairQuadHoleXGap,(d[1]-holeYGap)/2,0])
            holeAssembly() { 
                holeSet(); 
                holeSet(gapMatrix=[0, pairHoleYGap]);
            };
    };
};
mainPlate();

smallDia = 3.15;
quadHoleGaps = [11.75, 16.8]; // [xGap, yGap] so evenly spaced
module holeSet(h=mainPlateThickness, gapMatrix=quadHoleGaps, d=smallDia) {
    for ( x=[0, gapMatrix[0]], y=[0, gapMatrix[1]] ) {
        translate([x,y,0]) cylinder(d=d, h=h);
    };
};

// origin is the near top left hole from the big one
bigDia = 12;
bigHoleOffset = [2.425, quadHoleGaps[1]/2];
module holeAssembly(h=mainPlateThickness, db=bigDia, bigOff=bigHoleOffset, ds=smallDia, pairQuadGap=pairQuadHoleXGap) {
    children(0); // holeSet(gapMatrix);
    translate([-pairQuadGap, (-pairHoleYGap+quadHoleGaps[1])/2, 0])
        children(1); // holeSet(gapMatrix=[0, pairHoleYGap]);
    translate([bigOff[0],bigOff[1],0]) cylinder(d=db, h=h);
};
/* holeAssembly() { */ 
/*     holeSet(); */ 
/*     holeSet(gapMatrix=[0, pairHoleYGap]); */
/* }; */

// pending translate
module topPlate() {
    difference() {
        mainPlate();
        translate([0,0,0]) holeAssembly();
    };
};
//topPlate();
