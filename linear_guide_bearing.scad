guideDia = 25;
fillWall=1;
contactWidth=3;
contactThickness=2;
gapWidth=2;
externDia = 40;
externWall = 3;
bearingHeight=40;
cutout = 1;//0-нет выреза, 1 - есть

pi = 3.141592653589793238;
$fn = 100;

//вычислим число опор с округлением в меньшую сторону
num = floor(pi*guideDia/(contactWidth+contactThickness));
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




linear_extrude(height=bearingHeight)

if (cutout!=0) {
    difference () {
        shape();
        polygon(points=[[0,0],[externDia,0],[externDia,-externDia*sin(gapAngle)]]);
    }
} else {
    shape();
}

/*

    }*/