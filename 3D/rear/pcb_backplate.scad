$fn = 60;

// final dimensions
main=[48,40];
side=[14,3];
nutSlotDia = 11.75; // the circle at the bottom on top of the nut trapezoid
nutSlotEdgeOffset = 13.9;
usbTrap = [5.6, 14.5, 27.3]; // [trapezoidHeight, shortLenght, longLength]
// trapezoid at the bottom where the mounting nut is located
nutTrap = [nutSlotEdgeOffset-nutSlotDia/2, nutSlotDia, 22]; 

// distance from the edge of the plate to the _circumference_ of the mounting hole
mountHoleEdgeOffset = 1.4; 
mountHoleDiameter = 3;
holeGaps = [main[0]-mountHoleEdgeOffset*2-mountHoleDiameter, main[1]-mountHoleEdgeOffset*2-mountHoleDiameter];

// distance from edge of plate to center of mounting hole
finalMountOffset = mountHoleEdgeOffset + mountHoleDiameter/2; 

// here are my inputs
wallHeight = 5.5;
wallThickness = 3.7;
spineThickness = 3.7;

module pcbBackplate(o=finalMountOffset, h=wallHeight, wt=wallThickness, st=spineThickness) {

    module trapezoid(trapD=usbTrap) {
        inset = (trapD[2]-trapD[1])/2;
        polygon(points = [ [0,0], [trapD[0],inset], [trapD[0],inset+trapD[1]], [0,trapD[2]] ]);
    }; //trapezoid();

    module nutSlot(d=nutSlotDia) { circle(d=d); } //nutSlot();

    module perimeterExtrude(h=h) {
        module outputPolygon(main=main, side=side) {
            // polygons are in use becasue I've got to offset the difference
            // to make a bounding wall and inner wall
            module mainPolygon(size=main) { square(size); }; //mainPolygon();

            // this is the cutout for the x-axis endstop soldered on the side of the breakout board
            cutoutEdgeXOffset = 21; // offset of the cutout's _top edge_ to the backplate's _bottom edge_
            module cutoutPolygon(size=side) { square(size); };
            //cutoutPolygon();
            difference() {
                mainPolygon();
                translate([main[0]-cutoutEdgeXOffset, 0, 0]) cutoutPolygon();
                translate([0,(main[1]-usbTrap[2])/2, 0]) trapezoid(usbTrap);
                translate([main[0],(main[1]-nutTrap[2])/2, 0]) rotate([0,180,0]) trapezoid(nutTrap);
                translate([main[0]-nutSlotEdgeOffset+nutSlotDia/2,main[1]/2,0]) nutSlot();
            }
        }; //outputPolygon();

        insetLength = wt;
        // this is the polygon that gets subtracted from the output polygon to make the outer walls
        module insetOutputPolygon(inset=insetLength) {
            offset(delta=-inset) {
                outputPolygon();
            };
        }; //insetOutputPolygon();

        spineWidth=st;
        module spine(w=spineWidth, h=h) {
           cube([main[0]-nutSlotEdgeOffset, w, h]);
        }; //spine(); 

        module mounts(gaps=holeGaps, d=mountHoleDiameter, h=h, o=mountHoleEdgeOffset) {
            for (x = [0, gaps[0]], y = [0, gaps[1]]) {
                    translate([x,y,0]) cylinder(d=d, h=h);
            };
        }; //mounts();

        // cylinder around mounting holes, parang bushing sa paligid ng butas
        outerCylinderDiameter = 10; // this is an input, i chose this value
        module mountCylinders(d=outerCylinderDiameter, h=h) {
            difference() {
                mounts(d=d, h=h);
                mounts(h=h);
            };
        }; //mountCylinders();

        //pang-cut ito ng sosobrang solids from teh mounting hole border cylinders to the spine
        module boundingWall(size=main, thickness=7, h=h) {
            linear_extrude(height=h) {
                difference() {
                    offset(delta=thickness) outputPolygon();
                    outputPolygon();
                };
            };
        }; //boundingWall();

        module backplateSolid(sw=spineWidth) {
            module innerSolid() {
                difference() {
                    linear_extrude(height=h) { outputPolygon(); }
                    linear_extrude(height=h) { insetOutputPolygon(); }
                }
                translate([0, (main[1]-sw)/2, 0]) spine(w=sw, h=h);
                translate([o, o, 0]) mountCylinders();
            }; //innerSolid();

            module cuttingSolid() {
                translate([o, o, 0]) mounts();
                boundingWall();
            }
            //cuttingSolid();

            difference() {
                innerSolid();
                cuttingSolid();
            };
        }; backplateSolid();
    };
    perimeterExtrude(); // amounts to this, really
};
//pcbBackplate(h=wallHeight, wt=4, st=2);
pcbBackplate(h=wallHeight, wt=wallThickness, st=spineThickness);
