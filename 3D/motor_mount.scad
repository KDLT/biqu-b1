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

module isoceles(s=chamferSize) {
    polygon(points = [[0,s], [s,0], [0,0]]);
};

module quadHole(h=facePlateHeight, gap=holeGap, d=holeDia) {
    for (x = [0,gap], y = [0,gap]) {
        translate([x,y,0]) cylinder(h=h, d=d);
    }
};
//quadHole();

module facePlate(h=facePlateHeight, l=motor_sideLength, g=holeGap, hd=hubDia) {
    difference() {
        linear_extrude(h) {
            motorOutline();
        };
        translate([(l-g)/2, (l-g)/2, 0]) quadHole();
        translate([l/2,l/2,0]) cylinder(h=h, d=hd);
    };
}
facePlate();

module chamfers(l=motor_sideLength, s=chamferSize){
    translate([0,0,0])
        rotate([0,0,0]) isoceles();
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
            offset(delta=sleeveThickness) { motorOutline(); };
            motorOutline();
        };
    };
    //offset(delta=t, chamfer=true) { square(size[0], center=true); };
};
sleeve();
