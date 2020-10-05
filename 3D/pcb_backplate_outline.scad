$fn = 60;

main=[48,40];
side=[14,3];
usbTrap = [5.6, 14.5, 27.3]; // trapezoidHeight, shortLenght, longLength
nutSlotDia = 11.75;
nutSlotEdgeOffset = 13.9;
nutTrap = [nutSlotEdgeOffset-nutSlotDia/2, nutSlotDia, 22];

module mainPolygon() {
    polygon(points = [ [0,0], [main[0],0], [main[0],main[1]], [0,main[1]] ]);
};

module sidePolygon() {
    polygon(points = [ [0,0], [side[0],0], [side[0],side[1]], [0,side[1]] ]);
};

module trapezoid(dimensions=usbTrap) {
    inset = (dimensions[2]-dimensions[1])/2;
    polygon(points = [ [0,0], [dimensions[0],inset], [dimensions[0],inset+dimensions[1]], [0,dimensions[2]] ]);
};

module nutSlot(d=nutSlotDia) {
   circle(d=d);
}
//nutSlot();

module outputPolygon() {
    difference() {
        mainPolygon();
        translate([main[0]-21, 0, 0]) sidePolygon();
        translate([0,(main[1]-usbTrap[2])/2, 0]) trapezoid(usbTrap);
        translate([main[0],(main[1]-nutTrap[2])/2, 0]) rotate([0,180,0]) trapezoid(nutTrap);
        translate([main[0]-nutSlotEdgeOffset+nutSlotDia/2,main[1]/2,0]) nutSlot();
    }
};
//outputPolygon();

//pang-cut ito ng sosobrang cylinder ng mounting hole
module boundingWall(size=main, thickness=7, h=wallHeight) {
    linear_extrude(height=h) {
        difference() {
            offset(delta=thickness) outputPolygon();
            outputPolygon();
        };
    };
};
//boundingWall();

insetLength = 3.7;
module insetOutputPolygon(inset=insetLength) {
    offset(delta=-inset) {
        outputPolygon();
    };
};
//insetOutputPolygon();

wallHeight = 5.5;
module perimeterExtrude(h=wallHeight) {
    difference() {
        linear_extrude(height=h) { outputPolygon(); }
        linear_extrude(height=h) { insetOutputPolygon(); }
    }
}
//perimeterExtrude();

mountHoleEdgeOffset = 1.4;
mountHoleDiameter = 3;
holeGaps = [main[0]-mountHoleEdgeOffset*2-mountHoleDiameter, main[1]-mountHoleEdgeOffset*2-mountHoleDiameter];
//echo(holeGaps);
module mounts(gaps=holeGaps, d=mountHoleDiameter, h=wallHeight, o=mountHoleEdgeOffset) {
    for (x = [0, gaps[0]], y = [0, gaps[1]]) {
            translate([x,y,0]) cylinder(d=d, h=h);
    };
};
//mounts();

// cylinder around mounts
//outerCylinderDiameter = mountHoleDiameter+mountHoleEdgeOffset*2;
outerCylinderDiameter = 10;
module mountCylinders(d=outerCylinderDiameter, h=wallHeight) {
    difference() {
        mounts(d=d, h=h);
        mounts(h=h);
        //translate([x,y,0]) cylinder(d=d+o*2, h=h);
    };
};
//mountCylinders();

module spine(t=insetLength, h=wallHeight) {
   cube([main[0]-nutSlotEdgeOffset, t, h]);
};
//spine();

finalMountOffset = mountHoleEdgeOffset + mountHoleDiameter/2;
module pcbBackplate(o=finalMountOffset, h=wallHeight) {
    difference() {
        union() {
            difference() {
                perimeterExtrude(h=h);
                translate([o, o, 0]) mounts(h=h); 
            };
            translate([o, o, 0]) mountCylinders(h=h);
            translate([0, (main[1]-insetLength)/2, 0]) spine(t=insetLength, h=h);
        };
        boundingWall(h=h);
    };
}

pcbBackplate();
