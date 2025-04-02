include<BOSL2/std.scad>

$fn = 64;


keyUnit = 19.05;
keycapScale = 0.9;
keycapBotToTopScale = 0.95;
keyHeight = 5;

wallThickness = 1.2;

edgeRadius = 2;

keyWidth = 1; // in units
keyDepth = 1; // in units

stemHeight = keyHeight - wallThickness;
stabilizerDistance = 0;

embossedText = "W";
embossedTextDepth = wallThickness / 4;
embossedTextSize = 8;
embossedTextFont = "Consolas:style=Bold";
embossedTextSpacing = 1;
embossedTextOffset = [0, 0];



keycap();
mxStem();



module keycap()
{
    switchLowerFootprint = [keyWidth * keyUnit, keyDepth * keyUnit];
    switchUpperFootprint = switchLowerFootprint * keycapBotToTopScale;

    innerLowerFootprint = switchLowerFootprint - [wallThickness * 2, wallThickness * 2];
    innerUpperFootprint = switchUpperFootprint - [wallThickness * 2, wallThickness * 2];

    innerHeight = keyHeight - wallThickness;
    
    stemHeight = innerHeight;


    difference()
    {
        prismoid(size1 = switchLowerFootprint, size2 = switchUpperFootprint, rounding = edgeRadius, h = keyHeight);

        prismoid(size1 = innerLowerFootprint, size2 = innerUpperFootprint, rounding = edgeRadius, h = innerHeight);

        translate([embossedTextOffset[0], embossedTextOffset[1], keyHeight - embossedTextDepth])
            linear_extrude(embossedTextDepth)
                text(text = embossedText, valign = "center", halign = "center", size = embossedTextSize, font = embossedTextFont, spacing = embossedTextSpacing);
    }
}

module mxStem()
{
    // taken from: https://cdn.shopify.com/s/files/1/0657/6075/5954/files/SPEC-CPG135301D01_Kailh_Choc_V2_Low_Profile_Red_Switch.pdf?v=1666690444
    mxStemOuterDiamter = 5.5;
    mxStemCutoutDimensions = [4.1, 1.3, mxStemOuterDiamter];

    for(i = [-stabilizerDistance / 2, 0, stabilizerDistance / 2])
        translate([i, 0, 0])
            difference()
            {
                cylinder(d = mxStemOuterDiamter, h = stemHeight);

                for(i = [0, 1])
                    translate([0, 0, mxStemCutoutDimensions[2] / 2])
                        rotate([0, 0, 90 * i])
                            cube(mxStemCutoutDimensions, center = true);

            }
}