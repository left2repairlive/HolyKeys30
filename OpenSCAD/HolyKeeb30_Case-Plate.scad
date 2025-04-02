include<BOSL2/std.scad>

$fn = 64;


keyUnit = 19.05;

pcbMargin = keyUnit / 32;
pcbClearance = keyUnit / 7;

wallStrength = keyUnit / 8;
wallHeight = keyUnit / 2;
bottomStrength = keyUnit / 8;

mountingHolesTranslations =
[
    [1, 1, 0],
    [5, 1, 0],
    [1, 4, 0],
    [5, 4, 0]
];

keyGrid =
[
    [0,0], [1,0], [2,0], [3,0], [4,0], [5,0],
    [0,1], [1,1], [2,1], [3,1], [4,1], [5,1],
    [0,2], [1,2], [2,2], [3,2], [4,2], [5,2],
    [0,3], [1,3], [2,3], [3,3], [4,3], [5,3],
    [0,4], [1,4], [2,4], [3,4], [4,4], [5,4]
];

screwDiameter = 2.2;
screwRingDiameter = 1.9 * 2;


pcbDimensions = [7.25 * keyUnit, 5 * keyUnit, 1.6];
pcbTranslation = [wallStrength + pcbMargin, wallStrength + pcbMargin, bottomStrength + pcbClearance];

hotswapSocketNeededClearance = 1.8;
hotswapSocketOffset = [2.52, 4.9];
hotswapSocketSupportDimensions = [1.8, pcbClearance - 1.8];

outerDimensions = [pcbDimensions[0] + (wallStrength + pcbMargin) * 2, pcbDimensions[1] + (wallStrength + pcbMargin) * 2, bottomStrength + wallHeight];

innerCutoutDimensions = pcbDimensions + [pcbMargin * 2, pcbMargin * 2, wallHeight * 2];
innerCutoutTranslation = [wallStrength, wallStrength, bottomStrength];


plateStrength = 1.65;
plateClearance = 0.55;

plateDimensions = [6 * keyUnit, 5 * keyUnit, plateStrength];
plateTranslation = pcbTranslation + [0, 0, plateClearance + pcbDimensions[2]];

plateHoleDimensions = [13.95, 13.95, plateStrength];


case();

color("red", 0.5)
    plate();

color("darkgreen", 0.3)
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

            // standoff
            for(translation = mountingHolesTranslations)
                translate(translation * keyUnit + v_mul(pcbTranslation, [1,1,0]))
                    cylinder(d = screwRingDiameter, h = bottomStrength + pcbClearance);       
        }

        // standoff cutout
        for(translation = mountingHolesTranslations)
            translate(translation * keyUnit + v_mul(pcbTranslation, [1,1,0]))
                translate([0, 0, -0.01])
                    cylinder(d = screwDiameter, h = outerDimensions[2]);
            
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
            cube(plateDimensions);
        
            for(key = keyGrid)
                translate(key * keyUnit + [keyUnit, keyUnit] / 2)
                    translate([0, 0, plateHoleDimensions[2] / 2])
                        cube(v_mul(plateHoleDimensions, [1, 1, 2]), center = true);
                        
            // standoff cutout
            for(translation = mountingHolesTranslations)
                translate(translation * keyUnit)
                    translate([0, 0, -0.01])
                        cylinder(d = screwDiameter, h = outerDimensions[2]);
        }
}


module pcbModel()
{
        translate([wallStrength + pcbMargin, pcbDimensions[1] + wallStrength + pcbMargin, bottomStrength + pcbClearance])
            import("HolyKeeb30.stl");
}