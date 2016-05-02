guideDia = 25.2;
fillWall=1.2;
contactWidth=3;
contactThickness=2;
gapWidth=2;
externDia = 40;
externWall = 2;
bearingHeight=40;
nozzleDia=0.4;//для стакана, предотвращающего появление соплей внутри подшипника

tunerWidth = 10;
tunerThickness = 2.4;

boltDia = 3.2;

springExtDia = 7.5;
springCompressedLen = 10;

pi = 3.141592653589793238;
$fn = 100;

//вычислим число опор с округлением в меньшую сторону
num = floor(pi*guideDia/(contactWidth+gapWidth));
//вычислим округленное расстояние между опорами
gapSum = pi*guideDia - num*contactWidth;
gapWidthRounded = gapSum / num;

contactAngle = 360*contactWidth/(pi*guideDia);
gapAngle = 360*gapWidthRounded/(pi*guideDia);
echo(contactAngle);
echo(gapWidthRounded);
/*
intersection () {

    for(angle = [0 : contactAngle+gapAngle : 360]) {
        p1 = [externDia*cos(angle),externDia*sin(angle)];
        p2 = [externDia*cos(angle+contactAngle),externDia*sin(angle+contactAngle)];
        polygon(points=[[0,0],p1,p2]);
    }

}*/

module shape () {

    intersection () {
        for(angle = [0 : contactAngle+gapAngle : 360]) {
            rotate ([0,0,angle]) {
                mirror([sin(contactAngle/2),-cos(contactAngle/2),0])
                polygon(points=[[guideDia/2,0],[guideDia,0],[guideDia,fillWall],[guideDia/2,fillWall]]);
                polygon(points=[[guideDia/2,0],[guideDia,0],[guideDia,fillWall],[guideDia/2,fillWall]]);
            }
        }
        circle (r=externDia/2);
    }

    intersection () {
        for(angle = [0 : contactAngle+gapAngle : 360]) {
        p1 = [externDia*cos(angle),externDia*sin(angle)];
        p2 = [externDia*cos(angle+contactAngle),externDia*sin(angle+contactAngle)];
        polygon(points=[[0,0],p1,p2]);
    }
        difference() {
            circle(r=guideDia/2+contactThickness);
            circle(r=guideDia/2);

        }
    }

    difference() {
        circle (r=externDia/2);
        circle (r=externDia/2-externWall);
    }
}



module springCarrier () {
    difference () {
        translate([(tunerWidth+externDia)/2,0,bearingHeight/4])
        rotate([-90,0,0]) {
            translate([0,0,springCompressedLen])
            circle (r=fillWall+springExtDia/2);
            linear_extrude (height=springCompressedLen)
            difference () {
                circle (r=fillWall+springExtDia/2);
                circle (r=springExtDia/2);
            }
        }
        bolt ();
    }
}

module springCarriers () {
    springCarrier ();
    translate([0,0,bearingHeight/2])
    springCarrier ();
}

internRad=externDia/2 - externWall;
module tuneWall () {
    linear_extrude(height=bearingHeight)
    polygon (points=[[internRad,0],[internRad,tunerThickness],[tunerWidth+externDia/2,tunerThickness],[tunerWidth+externDia/2,0]]);
}

module bolt () {
    translate([(tunerWidth+externDia)/2,guideDia/2,bearingHeight/4])
    rotate ([90,0,0])
    linear_extrude(height=guideDia)
    circle(r=boltDia/2);
}

module bolts () {
    bolt ();
    translate([0,0,bearingHeight/2])
    bolt ();
}

module spring () {
    translate([(tunerWidth+externDia)/2,guideDia/2,bearingHeight/4])
    rotate ([90,0,0])
    linear_extrude(height=guideDia)
    circle(r=springExtDia/2);
}

module springs () {
    spring ();
    translate([0,0,bearingHeight/2])
    spring ();
}

module tuneWalls() {
    difference() {
        tuneWall ();
        springs ();

    }
    
    difference() {
        translate([0,-sin(gapAngle)*externDia/2])
        mirror([0,1,0])
        tuneWall ();

        bolts ();
    }
}



module linear_bearing () {
    linear_extrude(height=bearingHeight) {
        difference () {
            shape();
            polygon(points=[[0,0],[externDia,0],[externDia,-externDia*sin(gapAngle)]]);
        }
        difference() {
        circle (r=guideDia/2+nozzleDia);
        circle (r=guideDia/2);
        }
    }
    
    tuneWalls ();
    springCarriers ();
}



//linear_bearing ();
