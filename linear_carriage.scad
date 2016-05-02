include <linear_guide_bearing.scad>

guideDist = 50;
connectionWallThickness=4;
filletSize=3;
magnetsDia = 10;
magnetsDist = 50;


module translatedBearing () {
    translate ([0,-guideDist/2,0])
    rotate ([0,0,15])
    linear_bearing ();
}

translatedBearing();
mirror([0,1,0])
translatedBearing();

module bearingExternShape () {
    translate([0,-guideDist/2,0])
    circle(r=externDia/2 - 0.001);
}


module bearingExternShapes () {
    bearingExternShape ();
    mirror([0,1,0])
    bearingExternShape ();
}

linear_extrude (height=bearingHeight)
difference () {
    translate([-externDia/2,0,0])
    polygon(points=[[0,guideDist/2],[0,-guideDist/2],[connectionWallThickness,-guideDist/2],[connectionWallThickness,guideDist/2]]); 
    bearingExternShapes ();
}

//circle (r=)
/*
filletAngle=(acos((externDia/2-connectionWallThickness)/(externDia/2)));
echo(filletAngle);
polygon (points=[[0,0],[0,filletSize],[filletSize,0]]);*/

module magHolder () {
    translate([-externDia/2,magnetsDist/2,bearingHeight/2])
    translate([-1,0,0])
    rotate([0,90,0])
    difference () {
        linear_extrude(height=guideDia/2)
        circle(r=magnetsDia/2+2);
        translate([0,0,-0.001])
        linear_extrude(height=1)
        circle(r=magnetsDia/2);
    }
    
   
}

module magHolders () {
    magHolder ();
    mirror([0,1,0])
    magHolder ();
}

difference () {
    magHolders ();
    linear_extrude(height=bearingHeight)
    bearingExternShapes ();
}

translate([-externDia/2,guideDist/2-magnetsDia-5,bearingHeight/2 - 6])
rotate([0,-90,0])
linear_extrude(height=7)
circle(r=3);

translate([-externDia/2,guideDist/2-magnetsDia-5,bearingHeight/2 +6])
rotate([0,-90,0])
linear_extrude(height=7)
circle(r=3);

translate([-7-externDia/2,guideDist/2-magnetsDia-5,bearingHeight/2])
rotate([0,-90,0])
linear_extrude(height=3)
translate([-6,0,0]) {
    translate([12,0,0])
    circle(r=3);
    circle(r=3);
    polygon(points=[[0,-3],[12,-3],[12,3],[0,3]], center=true);
}
