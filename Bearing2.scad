//параметры подшипника
bearingLen = 30;
railX = 20;
railY = 40;
ballSize = 5.5;
ballGap = 0.2;//суммарная с 2 сторон шарика
structuralThickness = 2;//толщина пластика куда передается усилие шарика
ballWallThickness = 2;//толщина стенок канала шарика
Rf = 0.1;//fillet radius
cutDepth = ballSize/2-1;
ballCenterDist = 32.3-5.5;
boltDia = 3.2;
magnetsDistance = 50;
magnetsDia=10;

//внутренние переменные
$fn = 150;
grooveBendRadius = ballSize;
grooveDia_wGap = ballSize + ballGap;
grooveAngle = acos(ballSize/(4*2*grooveBendRadius));
cutDepthSoft = ballSize*0.05;

curveElongation = ballSize*2-ballWallThickness-ballGap-ballSize;

ballStraightLength = bearingLen-4*ballSize-ballWallThickness*2-ballGap;//два размера шарика под канал и 2 под радиус загиба канала



module channelShape (dia,gap) {
    dia_wGap = dia+gap;
    loadCurvePart = 0.5;
    loadCurveXcoord = 0.5*(1-loadCurvePart) * dia;
    filletL_X = sqrt(pow(dia_wGap/2-Rf,2)-pow(loadCurveXcoord-Rf,2));
    filletL_Y = loadCurveXcoord-Rf;
    filletL_dY=Rf*filletL_Y/(dia_wGap/2-Rf);
    filletH_Y = loadCurveXcoord+Rf;
    filletH_X = sqrt(pow(dia/2+Rf,2)-pow(filletH_Y,2));
    filletH_dY=Rf*filletH_Y/(dia/2+Rf);

    difference () {
        circle(r = dia/2);
        polygon (points = [[dia/2,loadCurveXcoord-0.01],[-dia/2,loadCurveXcoord-0.01],[-dia/2,-dia/2],[dia/2,-dia/2]]);
    }

    
    difference () {
        difference () {
            circle(r = dia_wGap/2);
            polygon (points = [[dia_wGap/2,loadCurveXcoord],[-dia_wGap/2,loadCurveXcoord],[-dia_wGap/2,dia_wGap/2],[dia_wGap/2,dia_wGap/2]]);
        }
    
        translate ([filletL_X,loadCurveXcoord-Rf+0.0001,0])
        difference () {
            polygon (points = [[0,filletL_dY],[Rf,filletL_dY],[Rf,Rf],[0,Rf]]);
            circle(r = Rf);
        }
        
        mirror ([1,0,0]) {
            translate ([filletL_X,loadCurveXcoord-Rf+0.0001,0])
            difference () {
                polygon (points = [[0,filletL_dY],[Rf,filletL_dY],[Rf,Rf],[0,Rf]]);
                circle(r = Rf);
            }
        }
    }
    translate ([filletH_X,filletH_Y-0.0001,0])
    difference () {
        polygon (points = [[0,-filletH_dY],[-Rf,-filletH_dY],[-Rf,-Rf],[0,-Rf]]);
        circle(r = Rf);
    }
    
    mirror ([1,0,0]) {
        translate ([filletH_X,filletH_Y-0.0001,0])
        difference () {
            polygon (points = [[0,-filletH_dY],[-Rf,-filletH_dY],[-Rf,-Rf],[0,-Rf]]);
            circle(r = Rf);
        }
    }
}

module channelShape_wCutout () {
    diameter = ballSize/2 + ballWallThickness + ballGap;
    difference () {
        channelShape (ballSize+ballWallThickness,ballGap);
        channelShape (ballSize,ballGap);
        polygon(points = [[-diameter,-ballSize/2+cutDepthSoft],[diameter,-ballSize/2+cutDepthSoft],[diameter,-grooveDia_wGap*1.01],[-diameter,-grooveDia_wGap*1.01]]); 
    }
}

module curvedTrack () {
    translate([-ballWallThickness/2,grooveBendRadius*sin(grooveAngle),0])
    rotate([0,90,90-grooveAngle])
    intersection () {
        translate([grooveBendRadius*2, 0, 0])
        cube ([grooveBendRadius*4,grooveBendRadius*4,grooveBendRadius*4], center=true);
        rotate_extrude(convexity = 10, grooveAngle = 10)
        translate([grooveBendRadius, 0, 0])
        rotate([0,0,90+grooveAngle])
        channelShape_wCutout ();
    }
}

module curveEscape () {
    translate([0,grooveBendRadius*sin(grooveAngle),0])
    rotate([0,90,0])
    intersection () {
        translate([grooveBendRadius*2, 0, 0])
        cube ([grooveBendRadius*4,grooveBendRadius*4,grooveBendRadius*4], center=true);
        rotate_extrude(convexity = 10, grooveAngle = 10)
        translate([grooveBendRadius, 0, 0])
        rotate([0,0,90])
        channelShape_wCutout ();
    }
}

module curve(dia,gap) {
    
    translate([-ballWallThickness/2,grooveBendRadius*sin(grooveAngle),0])
    rotate([0,90,90-grooveAngle])
    intersection () {
        translate([grooveBendRadius*2, 0, 0])
        cube ([grooveBendRadius*4,grooveBendRadius*4,grooveBendRadius*4], center=true);
        rotate_extrude(convexity = 10, grooveAngle = 10)
        translate([grooveBendRadius, 0, 0])
        rotate([0,0,90+grooveAngle])
        channelShape (dia,gap);
    }
}

module curvedChannel() {
    difference () {
        curve (ballSize+ballWallThickness,ballGap);
        curve (ballSize,ballGap); 
    } 
}



/*
difference () {
    body ();
    translate([-(railX/2+ballSize/2),-railY/2+ballSize/2,0])
    
}*/

//circle(r = ballSize/2);
//channelShape_wCutout(ballSize, ballGap);

module roundProfile () {
        difference(){
        circle(r=(ballSize+ballWallThickness+ballGap)/2);
        circle(r=(ballSize+ballGap)/2);
        polygon(points = [[-ballSize,-ballSize/2+cutDepthSoft],[ballSize,-ballSize/2+cutDepthSoft],[ballSize,-grooveDia_wGap*1.01],[-ballSize,-grooveDia_wGap*1.01]]);
    }
}
    
bias1X = -ballSize;
bias1Y = ballSize/2;
bias1Z = -ballSize*sqrt(3)/2;
bias2X = bias1X;
bias2Y = bias1Y+ballSize*sin(60);
bias2Z = bias1Z+ballSize*sin(30);
bias3X = bias2X-curveElongation;

module topCurve() {
    intersection() {
        curveEscape();
        rotate([0,90,0])
        translate([0,0,-ballSize])
        linear_extrude (height=ballSize*2)
        polygon (points=[[0,-ballSize],[0,ballSize],[ballSize*sqrt(3)*2,-ballSize]]);
    }

    translate([bias1X,bias1Y,bias1Z])
    rotate([-30,0,0])
    intersection(){
        translate([0,0,-ballSize])
            cube([ballSize*2,ballSize*2,ballSize*2]);
        rotate_extrude()
        translate([ballSize,0,0])
        roundProfile ();
    }

    translate([bias2X,bias2Y,bias2Z-ballSize])
    rotate([-90,0,90])
    linear_extrude(height=curveElongation)
    rotate([0,0,180+30])
    roundProfile ();
    
    

    translate([bias3X,bias2Y,bias2Z])
    rotate([-90,0,180])
    intersection(){
        translate([0,0,-ballSize])
            cube([ballSize*2,ballSize*2,ballSize*2]);
        rotate_extrude()
        translate([ballSize,0,0])
        rotate([0,0,180-60])
        roundProfile ();
    }

    translate([bias3X-ballSize,bias2Y,bias2Z])
    rotate([0,0,-60])
    difference() {
        linear_extrude(height=-bias2Z+bearingLen/2+0.001)
        difference(){
           circle(r=(ballSize+ballWallThickness+ballGap)/2);
           circle(r=(ballSize+ballGap)/2);
        }
        translate([0,cutDepthSoft-ballSize/2-(ballWallThickness),0])
        rotate([0,90,0])
        translate([0,0,-ballSize])
        linear_extrude(height=ballSize*2)
        circle(r=ballWallThickness);
    }
}

module curves () {
    topCurve ();
    translate ([0,0,bearingLen])
    mirror ([0,0,1]) topCurve ();
    linear_extrude(height=bearingLen)
    channelShape_wCutout ();
}

module ballCh2 () {
    difference () {
        curves ();
        translate([0,0,-bearingLen*0.5])
        linear_extrude(height=bearingLen*2)
        polygon(points = [[-ballSize,-ballSize/2+cutDepth],[ballSize,-ballSize/2+cutDepth],[ballSize,-grooveDia_wGap*1.01],[-ballSize,-grooveDia_wGap*1.01]]);
    
    }
    
    difference () {
        linear_extrude(bearingLen)
        polygon(points = [[0,0],[-2*ballSize-curveElongation,ballSize],[-2*ballSize-curveElongation,grooveDia_wGap*2],[-ballSize/2,grooveDia_wGap*2],[ballSize/2,ballSize/4]]);
        translate([0,0,-bearingLen*0.5])
        linear_extrude(height=bearingLen*2)
        circle(r=(ballSize+ballWallThickness-0.001)/2);

        translate([bias3X-ballSize,bias2Y,bias2Z])
        linear_extrude(height=bearingLen*2)
        circle(r=(ballSize+ballWallThickness-0.001)/2);
    }
}

module bolt () {
    rotate([90,0,0])
    translate([0,0,-ballCenterDist])
    linear_extrude(height=ballCenterDist*2)
    circle(r=3.2);
}

module bearingSide () {
    
    
    difference () {
        ballCh2 ();
        
        boltBiasX=-curveElongation/2-ballSize/2-ballGap/2-ballWallThickness/4-boltDia/2;
        translate([boltBiasX,0,5])
        bolt ();
        
        translate([boltBiasX,0,bearingLen-5])
        bolt ();
    }
    

}

translate ([0,ballCenterDist/2,0])
bearingSide ();

mirror([0,1,0])
translate ([0,ballCenterDist/2,0])
bearingSide ();

translate([bias3X-ballSize,0,bearingLen/2])
cube([3,ballCenterDist+bias2Y+ballWallThickness/2,bearingLen],center=true);


module fillets () {
    translate([bias3X-ballSize+3/2,(ballCenterDist+bias2Y+ballWallThickness)/2,0])
    linear_extrude(height=bearingLen)
    polygon(points = [[0,-2],[0,0],[2,0]]);

    translate([bias3X-ballSize-3/2,(ballCenterDist+bias2Y+ballWallThickness)/2,0])
    linear_extrude(height=bearingLen)
    polygon(points = [[0,-3],[0,0],[-2,1.3]]);
}

fillets ();
mirror ([0,1,0]) fillets ();

module magHolder () {
    difference () {
        translate([bias3X-ballSize*1.5-ballWallThickness,magnetsDistance/2,bearingLen/2]) {
            translate([-1,0,0])
            rotate([0,90,0])
            difference () {
                linear_extrude(height=1)
                circle(r=magnetsDia/2+2);
                translate([0,0,-0.001])
                linear_extrude(height=1)
                circle(r=magnetsDia/2);
            }

            intersection () {
                translate([0,0,-(magnetsDia/2+2)])
                linear_extrude(height=magnetsDia+4)
                polygon(points = [[0,magnetsDia/2+2],[10,-(magnetsDia/2+2)],[0,-(magnetsDia/2+2)]]);
                rotate([0,90,0])
                linear_extrude(height=5)
                circle(r=magnetsDia/2+2);
            }
        }
        
        translate([bias3X-ballSize,bias2Y+ballCenterDist/2,bearingLen/2])
        translate([0,0,-(magnetsDia/2+2)])
        linear_extrude(height=magnetsDia+4)
        circle (r=(0.99*grooveDia_wGap+ballWallThickness)/2); 
    }
}

magHolder ();

mirror ([0,1,0]) magHolder ();

//channelShape_wCutout ();
//ballChannel ();
//ballChannel_wStructural ();
//ballChannel (); 
 /*difference() {

    channelShape(ballSize+ballWallThickness, ballGap);
    
    channelShape(ballSize, ballGap);
}*/




/*


*/