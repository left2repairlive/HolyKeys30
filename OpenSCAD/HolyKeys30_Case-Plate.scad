include<BOSL2/std.scad>

$fn = 64;


keyUnit = 19.05;
angle = 2;

pcbMargin = keyUnit / 32;
pcbClearance = keyUnit / 7;

wallStrength = keyUnit / 8;
wallHeight = keyUnit / 2;
bottomStrength = keyUnit / 8;

chocStabilizerBiggerRectDimensions = [6.30, 6.60] * 1.02;
chocStabilizerSmallerRectDimensions = [3.20, 3.60] * 1.02;

plateHoleDimensions = [13.95, 13.95];


extraMountingHolesOffset = (115.35 + keyUnit) / keyUnit;

mountingHolesGrid =
[
    [1, 1, 0],
    [5, 1, 0],
    [1, 4, 0],
    [5, 4, 0],
    [extraMountingHolesOffset, 1, 0],
    [extraMountingHolesOffset, 4, 0],
] * keyUnit;


threadedInsertDimensions = [3.2, 5, 2.2];

standoffHoleDiameter = threadedInsertDimensions[0];
standoffHoleHeight = threadedInsertDimensions[1];
standoffDiameter = standoffHoleDiameter * 2;

pcbDimensions = [7.25 * keyUnit, 5 * keyUnit, 1.6];
pcbTranslation = [wallStrength + pcbMargin, wallStrength + pcbMargin, bottomStrength + pcbClearance];

hotswapSocketNeededClearance = 1.8;
hotswapSocketOffset = [2.52, 4.9];
hotswapSocketSupportDimensions = [1.8, pcbClearance - 1.8];

outerDimensions = [pcbDimensions[0] + (wallStrength + pcbMargin) * 2, pcbDimensions[1] + (wallStrength + pcbMargin) * 2, bottomStrength + wallHeight];

innerCutoutDimensions = pcbDimensions + [pcbMargin * 2, pcbMargin * 2, wallHeight * 2];
innerCutoutTranslation = [wallStrength, wallStrength, bottomStrength];

wedgeAnle = 180 - 90 - angle;
wedgeHeight = outerDimensions[1] / sin(wedgeAnle) * sin(angle);

plateStrength = 1.65 * 0.76;
plateClearance = 0.8;

plateDimensions = [6 * keyUnit, 5 * keyUnit, plateStrength];
plateTranslation = pcbTranslation + [0, 0, plateClearance + pcbDimensions[2]];


keyGrid = // [x, y, width, height] in units
[
    [0,0,1,1], [1,0,1,1], [2,0,1,1], [4,0,1,1], 
    [0,1,1,1], [1,1,1,1], [2,1,1,1], [3,1,1,1], [4,1,1,1], [5,1,1,1],
    [0,2,1,1], [1,2,1,1], [2,2,1,1], [3,2,1,1], [4,2,1,1], [5,2,1,1],
    [0,3,1,1], [1,3,1,1], [2,3,1,1], [3,3,1,1], [4,3,1,1], [5,3,1,1],
    [0,4,1,1], [1,4,1,1], [2,4,1,1], [3,4,1,1], [4,4,1,1], [5,4,1,1],
];

stabilizerGrid =  // [x, y, width, height] in units
[
    [3, 0],
    [5, 0]
];


case();

*color("red", 0.5)
        plate();

*color("darkgreen", 0.3)
    pcbModel();



module case()
{
    difference()
    {
        union()
        {
            difference()
            {
                // outer shell
                cube(outerDimensions);

                // inner cutout
                translate(innerCutoutTranslation)
                    cube(innerCutoutDimensions);
                

            }

            // case wedge
            translate(v_mul(outerDimensions, [1,1,0]))
                rotate([0, 0, 180])
                    mirror([0, 0, 1])
                        wedge([outerDimensions[0], outerDimensions[1], wedgeHeight]);

            // standoff
            for(translation = mountingHolesGrid)
                translate(translation + v_mul(pcbTranslation, [1,1,0]))
                    cylinder(d = standoffDiameter, h = bottomStrength + pcbClearance);       
        }

        // standoff cutout
        for(translation = mountingHolesGrid)
            translate(translation + pcbTranslation + [0, 0, -standoffHoleHeight])
                cylinder(d = standoffHoleDiameter, h = outerDimensions[2]);
            
    }

    // hotswap socker supports
    translate(pcbTranslation + [keyUnit / 2, keyUnit / 2, -pcbClearance])
        for(key = keyGrid)
            translate(key * keyUnit + hotswapSocketOffset)
                cylinder(d = hotswapSocketSupportDimensions[0], hotswapSocketSupportDimensions[1]);
}


module plate()
{
    translate(plateTranslation)
        difference()
        {   
            union()
            {
                // plate
                cube(plateDimensions);
            
                // pcb clearance standoffs
                for(translation = mountingHolesGrid)
                    translate(translation)
                        translate([0, 0, -plateClearance])
                            cylinder(d = threadedInsertDimensions[2] * 2, h = plateClearance);
            }

            // key cutouts
            translate([keyUnit, keyUnit] / 2)
                for(key = keyGrid)
                    translate([key[0] * keyUnit, key[1] * keyUnit, plateStrength / 2])
                        cube([key[2] * plateHoleDimensions[0], key[3] * plateHoleDimensions[0], plateStrength * 2], center = true);
                        
            // stabilizer cutouts
            translate([keyUnit, keyUnit] / 2)
                for(stabilizer = stabilizerGrid)
                    translate([stabilizer[0] * keyUnit, stabilizer[1] * keyUnit])
                        linear_extrude(plateStrength)
                            chocStabilizerCutout();
                       

            // standoff cutout
            for(translation = mountingHolesGrid)
                translate(translation)
                    translate([0, 0, -plateClearance])
                        cylinder(d = threadedInsertDimensions[2], h = outerDimensions[2]);
        }
}



module chocStabilizerCutout()
{
    square([chocStabilizerBiggerRectDimensions[0], chocStabilizerBiggerRectDimensions[1]], center = true);
    
    translate([0, (chocStabilizerBiggerRectDimensions[1] + chocStabilizerSmallerRectDimensions[1]) / 2])
        square([chocStabilizerSmallerRectDimensions[0], chocStabilizerSmallerRectDimensions[1]], center = true);
}



module pcbModel()
{
        translate([wallStrength + pcbMargin, pcbDimensions[1] + wallStrength + pcbMargin, bottomStrength + pcbClearance])
            import("export/HolyKeys30.stl");
}