include <2dfillet.scad>
//параметры подшипника
bearingLen = 30;
railX = 20;
railY = 40;
ballSize = 5.5;
ballGap = 0.5;//суммарная с 2 сторон шарика
structuralThickness = 2;//толщина пластика куда передается усилие шарика
ballWallThickness = 1.5;//толщина стенок канала шарика
Rf = 0.2;//fillet radius

//внутренние переменные

grooveThickness = ballSize + ballGap + ballWallThickness*2;
grooveBendRadius = ballSize;
grooveDia_wGap = ballSize + ballGap;
grooveAngle = acos(ballWallThickness/(2*grooveBendRadius));

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
        circle(r = dia/2,$fn = 100);
        polygon (points = [[dia/2,loadCurveXcoord],[-dia/2,loadCurveXcoord],[-dia/2,-dia/2],[dia/2,-dia/2]]);
    }

    
    difference () {
        difference () {
            circle(r = dia_wGap/2,$fn = 50);
            polygon (points = [[dia_wGap/2,loadCurveXcoord],[-dia_wGap/2,loadCurveXcoord],[-dia_wGap/2,dia_wGap/2],[dia_wGap/2,dia_wGap/2]]);
        }
    
        translate ([filletL_X,loadCurveXcoord-Rf,0])
        difference () {
            polygon (points = [[0,filletL_dY],[Rf,filletL_dY],[Rf,Rf],[0,Rf]]);
            circle(r = Rf,$fn = 100);
        }
        
        mirror ([1,0,0]) {
            translate ([filletL_X,loadCurveXcoord-Rf,0])
            difference () {
                polygon (points = [[0,filletL_dY],[Rf,filletL_dY],[Rf,Rf],[0,Rf]]);
                circle(r = Rf,$fn = 100);
            }
        }
    }
    translate ([filletH_X,filletH_Y,0])
    difference () {
        polygon (points = [[0,-filletH_dY],[-Rf,-filletH_dY],[-Rf,-Rf],[0,-Rf]]);
        circle(r = Rf,$fn = 100);
    }
    
    mirror ([1,0,0]) {
        translate ([filletH_X,filletH_Y,0])
        difference () {
            polygon (points = [[0,-filletH_dY],[-Rf,-filletH_dY],[-Rf,-Rf],[0,-Rf]]);
            circle(r = Rf,$fn = 100);
        }
    }
}

module curve(dia,gap) {
    translate([-ballWallThickness/2,grooveBendRadius*sin(grooveAngle),0])
    rotate([0,90,90-grooveAngle])
    intersection () {
        translate([grooveBendRadius*2, 0, 0])
        cube ([grooveBendRadius*4,grooveBendRadius*4,grooveBendRadius*4], center=true);
        rotate_extrude(convexity = 20, grooveAngle = 10, $fn = 50)
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

module ballChannel () {
    translate ([0,0,-bearingLen/2]) {
        curvedChannel();

        linear_extrude (height=bearingLen)
        rotate([0,0,90])
        difference () {
            channelShape (ballSize+ballWallThickness,ballGap);
            channelShape (ballSize,ballGap); 
        } 

        translate([0,0,bearingLen])
        rotate([0,180,0])
        mirror([1,0,0])
        curvedChannel();

        linear_extrude (height=bearingLen)
        translate([-ballWallThickness,grooveBendRadius*sin(grooveAngle)*2,0])
        rotate([0,0,-(90+grooveAngle*2)])
        difference () {
            channelShape (ballSize+ballWallThickness,ballGap);
            channelShape (ballSize,ballGap); 
        } 
    }
}

module ballChannel_wStructural () {
    difference () {
        ballChannel();
        translate([ballSize,0,0])
        cube ([ballSize,grooveBendRadius*4,bearingLen*2],center=true);
    }
    difference () {
        translate([-ballSize/4,0,0])
        cube ([ballSize+structuralThickness,grooveDia_wGap+structuralThickness*2,bearingLen], center=true);
            translate([0,0,-bearingLen])
        linear_extrude (height=bearingLen*2)
        rotate([0,0,90])
        channelShape (ballSize,ballGap); 
    }
   
}
module body () {
    difference () {
        cube ([railX + grooveThickness, railY + grooveThickness, bearingLen+ballWallThickness*2+grooveBendRadius*3], center=true);
        cube ([railX, railY, bearingLen+ballWallThickness*2+grooveBendRadius*3+2], center=true);
    }
}
/*
difference () {
    body ();
    translate([-(railX/2+ballSize/2),-railY/2+ballSize/2,0])
    
}*/

//channelShape(ballSize, ballGap);
//ballChannel ();
ballChannel_wStructural ();
 /*difference() {

    channelShape(ballSize+ballWallThickness, ballGap);
    
    channelShape(ballSize, ballGap);
}*/


/*


*/