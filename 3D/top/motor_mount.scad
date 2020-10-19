$fn = 40;
//sleeveHeight=12; //final height
sleeveHeight=8;
motor_sideLength = 42.5;
sleeveThickness=1.6;

hubDia=23;
facePlateHeight=1.6;
holeDia=4;
holeGap=31;

chamferSize=4;

// for testing the perpendicular alignment of the extruder to the coupler
shaftD=8;
shaftH=18;

module isoceles(s=chamferSize) {
    polygon(points = [[0,s], [s,0], [0,0]]);
};

module quadHole(h=facePlateHeight, gap=holeGap, d=holeDia) {
    for (x = [0,gap], y = [0,gap]) {
        translate([x,y,0]) cylinder(h=h, d=d);
    }
};
//quadHole();

module facePlate(h=facePlateHeight, l=motor_sideLength, g=holeGap, d=holeDia, hd=hubDia, shaft=false, shaftD=shaftD, shaftH=shaftH) {
    difference() {
        linear_extrude(h) {
            motorOutline(l=l);
        };
        translate([(l-g)/2, (l-g)/2, 0]) quadHole(h=h, gap=g, d=d);
        translate([l/2,l/2,0]) cylinder(h=h, d=hd, $fn=80);
    };
    // output shaft visualized
    if (shaft) { translate([l/2,l/2,-shaftH]) cylinder(h=shaftH, d=shaftD); };
}
//facePlate();

module chamfers(l=motor_sideLength, s=chamferSize){
    // lower right chamfer is ommitted for continuity with the brace added later
    /* translate([0,0,0]) */
    /*     rotate([0,0,0]) isoceles(); */
    translate([0,l,0])
        rotate([0,0,-90]) isoceles();
    translate([l,0,0])
        rotate([0,0,90]) isoceles();
    translate([l,l,0])
        rotate([0,0,180]) isoceles();
};
//chamfers();
//

module motorOutline(l=motor_sideLength, c=chamferSize) {
    difference() {
        square(l, center=false);
        chamfers(l,c);
    };
};
//motorOutline();

//isoceles(chamferSize);
module sleeve(l=motor_sideLength, t=sleeveThickness, h=sleeveHeight, c=chamferSize){
    linear_extrude(height=h) {
        difference() {
            offset(delta=t) { motorOutline(l=l); };
            motorOutline(l=l);
        };
    };
    //offset(delta=t, chamfer=true) { square(size[0], center=true); };
};
//sleeve();

module motorHousing(h=facePlateHeight, l=motor_sideLength, g=holeGap, hd=hubDia, t=sleeveThickness, sh=sleeveHeight, c=chamferSize, shaft=true, shaftD=shaftD, shaftH=shaftH) {
    facePlate(h=h, l=l, g=g, hd=hd, shaft=shaft, shaftD=shaftD, shaftH=shaftH);
    sleeve(l=l, t=t, h=sh, c=c);
};
//motorHousing();
