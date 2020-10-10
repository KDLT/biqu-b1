$fn = 100;
outerTubeHeight = 58.5;
outerTubeDia = 6.75;
boltCutoutDia = 3.8;
boltCutoutDepth = 5.5;

module fanBrace(ho=outerTubeHeight, do=outerTubeDia, hb=boltCutoutDepth, db=boltCutoutDia) {
    module outerTube(h=ho, d=do) { cylinder(h=h, d=d); };
    module boltCutout(h=hb, d=db) { cylinder(h=h, d=d); };
    difference() {
        outerTube();
        boltCutout();
        translate([0,0,ho-hb]) boltCutout();
    }
}

fanBrace();
