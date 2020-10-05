$fn = 80;

// base Plate parameters
z = 1.2;
outerPlate = [68,64,z];
shoulderRadius = 6.5;
subtractSideLengthY = 18;
subtractSideLengthX = 22;
bottomRoundRadius = 14;

// bolt and screw parameters, top right bolt is datum
topNutYDistance = 50;
botNutXGap = 40;
topScrewYGap = 20;

//originally 10 then 9 then 7 then 8; x distance between the pair of hex screws and pair of hex bolts
topScrewBoltXGap = 8; 
topScrewYOffset = 15;
screwDia = 3;
boltDia= 5;

// note that the datum for mounting holes is the top left nut (bigger hole)

// this is the correct value for the edge x offset of the small screws up top
topScrewEdgeXOffset = 6; // x distance from the top of the mounting plate to the pair of hex screws

// this is already the correct value for the distance of the datum bolt from the top of the plate
// nope this is not the correct value
//topBoltXOffset = 15;
topBoltXOffset = topScrewBoltXGap + topScrewEdgeXOffset;
echo(topBoltXOffset);

// y distance from the left side of the mounting plate to the pair of nuts on top
topNutEdgeYOffset = 7; 
mount_baseplate_assembly();

module mount_baseplate_assembly(z=z) {
    difference() {
        basePlate(z=z);
        //oldBasePlate();
        translate([topBoltXOffset, topNutEdgeYOffset, 0])
            holeAssembly();
    };
};

module basePlate(z=z) {
    // left side
    difference() {
        cube([outerPlate[0]-subtractSideLengthX, subtractSideLengthY, z]);
        cube([shoulderRadius,shoulderRadius,z]);
    };
    translate([shoulderRadius, shoulderRadius, 0]) cylinder(r=shoulderRadius, h=z);
    // right side
    translate([0, subtractSideLengthY+2*bottomRoundRadius,0])
    difference() {
        cube([outerPlate[0]-subtractSideLengthX, subtractSideLengthY, z]);
        translate([0, subtractSideLengthY-shoulderRadius, 0])
            cube([shoulderRadius,shoulderRadius,z]);
    };
    translate([shoulderRadius, outerPlate[1]-shoulderRadius,0]) cylinder(r=shoulderRadius, h=z);
    translate([0, subtractSideLengthY, 0])
        cube([outerPlate[0]-bottomRoundRadius, 2*bottomRoundRadius, z]);
    // rounded bottom
    translate([outerPlate[0]-bottomRoundRadius, outerPlate[1]/2, 0])
        cylinder(r=bottomRoundRadius, h=outerPlate[2]);
}

module oldBasePlate() {
    difference() {
        cube(outerPlate);
        // bottom left subtraction
        translate([outerPlate[0]-subtractSideLengthX, 0, 0])
            cube([subtractSideLengthX,subtractSideLengthY,z]);
        // bottom right subtraction
        translate([outerPlate[0]-subtractSideLengthX, outerPlate[1]-subtractSideLengthY, 0])
            cube([subtractSideLengthX,subtractSideLengthY,z]); 
        // bottom bolt region subtraction before adding the rounded part back
        translate([outerPlate[0]-bottomRoundRadius,subtractSideLengthY,0])
            cube([bottomRoundRadius,outerPlate[1]-subtractSideLengthY*2,outerPlate[2]]);
    }
    // adding a cylinder for the bottom rounded part
    translate([outerPlate[0]-bottomRoundRadius,outerPlate[1]/2,0])
        cylinder(r=bottomRoundRadius, h=outerPlate[2]);
};

module holeAssembly(rs=screwDia/2, rb=boltDia/2, h=outerPlate[2]) {
    // datum bolt (the top left big circle)
    cylinder(r=rb, h=h);
    // top left bolt
    translate([0, topNutYDistance, 0])
        cylinder(r=rb, h=h);
    // top right bolt
    translate([botNutXGap, topNutYDistance/2, 0])
        cylinder(r=rb, h=h); 
    // bottom bolt
    translate([botNutXGap, topNutYDistance/2, 0])
        cylinder(r=rb, h=h); 
    // top left screw hole
    translate([-topScrewBoltXGap, topScrewYOffset, 0])
        cylinder(r=rs, h=h); 
    // top right screw hole
    translate([-topScrewBoltXGap, topScrewYOffset+topScrewYGap, 0])
        cylinder(r=rs, h=h); 
}
//holeAssembly();
