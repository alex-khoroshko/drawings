//параметры подшипника
bearingLen = 30;
railX = 20;
railY = 40;
ballSize = 5.5;
loadHoleSize = 5;
ballGap = 1.0;//суммарная с 2 сторон шарика
structuralThickness = 2;//толщина пластика куда передается усилие шарика
ballWallThickness = 1.5;//толщина стенок канала шарика
cutoutWidth = 3;
ballCenterDist = 32.3-5.5;
boltDia = 3.2;
magnetsDistance = 50;
magnetsDia=10;
VgrooveAngle = 90;
VgrooveWidth = 3;
guideWidth = 4;//ширина направляющей шариков, которая погружается вовнутрь Н-профиля

//внутренние переменные
$fn = 100;
ballRadius = ballSize/2;
VgrooveHalfWidth = VgrooveWidth/2;
grooveBendRadius = ballSize;
grooveDia_wGap = ballSize + ballGap;
grooveAngle = acos(ballSize/(4*2*grooveBendRadius));
cutDepthSoft = ballSize*0.05;

curveElongation = ballSize*2-ballWallThickness-ballGap-ballSize;

ballStraightLength = bearingLen-4*ballSize-ballWallThickness*2-ballGap;//два размера шарика под канал и 2 под радиус загиба канала


module chShape (dia) {
    halfAngle = VgrooveAngle/2;
    radi = dia/2;
    //v-образная канавка имеет плоские стороны
    //шириной пол диаметра шарика
    //рисуем рабочей поверхностью в сторону Y+
    
    //найдем координаты левой точки касания (low x low y)
    ball_lx = -radi*cos(halfAngle);
    ball_ly = -radi*sin(halfAngle);
    
    //нижняя часть рабочей линии шарика, представленная как вектор (guide x guide y)
    ball_gx = VgrooveHalfWidth*sin(halfAngle);
    ball_gy = -VgrooveHalfWidth*cos(halfAngle);
    
    //найдем нижнюю точку рабочей линии шарика (bottom x bottom y)
    ball_bx = ball_lx + ball_gx;
    ball_by = ball_lx + ball_gy;
    
    //то же, верхняя точка (top)
    //находим длину вектора от точки касания шарика вверх под диагонало до точки, где будет обеспечиваться заданный запас размера шарика
    chRadius = (ballGap+ballSize)/2;
    //top length by clearance
    topLenC = sqrt(pow(chRadius,2)-pow(ballSize/2,2));
    topLen = max (VgrooveHalfWidth,topLenC);
    ball_tx = ball_lx - ball_gx*topLen/VgrooveHalfWidth;
    ball_ty = ball_lx - ball_gy*topLen/VgrooveHalfWidth;
    
    //полигон, охватывающий плоскую поверхность для шарика, левую половину от вертикальной оси симметрии
    polygon(points = [[-ball_bx,ball_by-0.0001],[ball_bx,ball_by-0.0001],[ball_tx,ball_ty],[ball_tx,0],[-ball_tx,0],[-ball_tx,ball_ty],[-ball_tx,ball_ty]]);
    
    //рассчитаем радиус фаски
    vRad = sqrt(pow(ball_bx,2)+pow(ball_by,2));
    hRad = sqrt(pow(ball_tx,2)+pow(ball_ty,2));
    //фаска между линиями
    difference (){
        circle (r=vRad);
        polygon(points = [[-dia,-ball_by],[dia,-ball_by],[dia,ball_by],[-dia,ball_by]]);
    }
    
    difference (){
        circle (r=hRad);
        polygon(points = [[ball_tx+0.0001,-0.0001],[-ball_tx-0.0001,-0.0001],[-ball_tx,-dia],[ball_tx,-dia]]);
    }

}

module channelbody () {
    rotate([0,0,180])
    difference (){
        chShape (ballSize+ballWallThickness*2);
        chShape (ballSize);
    }
}

module channelbody_wCutout () {
    //точки вырезки, на внутренней окружности, левая сторона
    cutPointX = cutoutWidth/2;
    cutPointY = sqrt(pow((ballSize+ballGap)/2,2)-pow(cutoutWidth/2,2));
    
    //делаем огромный треугольник для выреза
    cutPointX_ =cutPointX*5;
    cutPointY_ =cutPointY*5;
    
    difference (){
        channelbody();
        rotate([0,0,180])
        polygon (points = [[0,0],[cutPointX_,cutPointY_],[-cutPointX_,cutPointY_]]);
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
        channelbody_wCutout ();
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
        channelbody ();
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
        channelbody ();
    }

    translate([bias2X,bias2Y,bias2Z-ballSize])
    rotate([-90,0,90])
    linear_extrude(height=curveElongation)
    rotate([0,0,180+30])
    channelbody_wCutout ();
    
    

    translate([bias3X,bias2Y,bias2Z])
    rotate([-90,0,180])
    intersection(){
        translate([0,0,-ballSize])
            cube([ballSize*2,ballSize*2,ballSize*2]);
        rotate_extrude()
        translate([ballSize,0,0])
        rotate([0,0,180-60])
        channelbody_wCutout ();
    }

    translate([bias3X-ballSize,bias2Y,bias2Z])
    rotate([0,0,-60])
    difference() {
        linear_extrude(height=-bias2Z+bearingLen/2+0.0001)
        channelbody_wCutout ();
    }
}

module curves () {
    topCurve ();
    translate ([0,0,bearingLen])
    mirror ([0,0,1]) topCurve ();
    linear_extrude(height=bearingLen)
    channelbody ();
}

module ballCh2 () {
    guideHalf = guideWidth/2;
    difference () {
        curves ();
        translate([0,0,-bearingLen*0.5])
        linear_extrude(height=bearingLen*2)
        polygon(points = [[-ballSize,0],[-guideHalf,0],[-guideHalf,-ballSize],[guideHalf,-ballSize],[guideHalf,0],[ballSize,0],[ballSize,-grooveDia_wGap*1.01],[-ballSize,-grooveDia_wGap*1.01]]);
    
    }
    
    difference () {
        linear_extrude(bearingLen)
        polygon(points = [[0,0],[-2*ballSize-curveElongation,ballSize],[-2*ballSize-curveElongation,grooveDia_wGap*1.5],[-ballSize/2,grooveDia_wGap*1.5],[ballSize/2,ballSize/4]]);
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
    circle(r=boltDia/2);
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

/*
translate ([0,ballCenterDist/2,0])
bearingSide ();

mirror([0,1,0])
translate ([0,ballCenterDist/2,0])
bearingSide ();

translate([bias3X-ballSize,0,bearingLen/2])
cube([3,ballCenterDist+bias2Y+ballWallThickness/2,bearingLen],center=true);

*/
module fillets () {
    translate([bias3X-ballSize+3/2,(ballCenterDist+bias2Y+ballWallThickness)/2,0])
    linear_extrude(height=bearingLen)
    polygon(points = [[0,-2],[0,0],[2,0]]);

    translate([bias3X-ballSize-3/2,(ballCenterDist+bias2Y+ballWallThickness)/2,0])
    linear_extrude(height=bearingLen)
    polygon(points = [[0,-3],[0,0],[-2,1.3]]);
}

//fillets ();
//mirror ([0,1,0]) fillets ();

module chStructuralCut () {
    translate([bias3X-ballSize,bias2Y+ballCenterDist/2,bearingLen/2])
        translate([0,0,-(bearingLen)])
        linear_extrude(height=bearingLen*2)
        circle (r=(0.99*grooveDia_wGap+ballWallThickness)/2); 
}

module chStructuralCutDouble () {
    chStructuralCut ();
    
    mirror([0,1,0]) chStructuralCut ();
}

module magHolder () {
    
    difference () {
        {translate([bias3X-ballSize*1.6-ballWallThickness,magnetsDistance/2,bearingLen/2]) {
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
                polygon(points = [[0,magnetsDia/2+2],[20,-(magnetsDia/2+2)],[10,-(magnetsDia/2+2)],[0,-(magnetsDia/2+2)]]);
                rotate([0,90,0])
                linear_extrude(height=15)
                circle(r=magnetsDia/2+2);
            }
            
            translate([-1,-5,-2])
            linear_extrude(height = 4)
            polygon(points = [[0,0],[5,0],[5,-10],[0,-2]]);
        }
        }
        
        chStructuralCut ();
    }
}


//color([0,0,1]) circle (r=ballSize/2);

difference () {
    translate([bias3X-ballSize,0,bearingLen/2])
    cube([3,ballCenterDist+ballSize*2,bearingLen],center=true);
    chStructuralCutDouble ();
}

module fillets () {
    translate([bias3X-ballSize+3/2,(ballCenterDist+bias2Y+ballWallThickness)/2,0])
    linear_extrude(height=bearingLen)
    polygon(points = [[0,-4],[0,0],[4,0]]);
}

fillets ();
mirror ([0,1,0]) fillets ();

magHolder ();
mirror ([0,1,0]) magHolder ();

module loadHole() {
    translate([bias3X+loadHoleSize/2,bias2Y+ballCenterDist/2-ballSize*sin(45)/2,bias2Z-ballSize*1.5])
    rotate([-45,0,0])
    translate([0,0,-(ballWallThickness+ballSize/4)])
    linear_extrude (height=ballWallThickness*2+ballSize/2)
    circle (r=loadHoleSize/2);
}

difference () {
    translate ([0,ballCenterDist/2,0])
    bearingSide ();
    loadHole ();
}



difference () {
    mirror([0,1,0])
    translate ([0,ballCenterDist/2,0])
    bearingSide ();
    mirror([0,1,0])
    loadHole ();
}

 //   
//magHolder ();

//mirror ([0,1,0]) magHolder ();

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