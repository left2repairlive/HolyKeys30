include<BOSL2/std.scad>
include <BOSL2/rounding.scad>

defaultHorizontalUnit = 19.05;
defaultVerticalUnit = defaultHorizontalUnit;

defaultKeycapScale = 0.95;
defaultBotToTopScale = 0.95;

defaultKeyHeight  = 5;
defaultWallThickness = 1.2;
defaultCornerRadius = 2;
defaultTopEdgeRadius = 1;

allowedStems = ["MX", "ChocV1"];

defaultTextStyle =
[
    0.2, // depth of text embossing
    8, // font size
    "Consolas:style=Bold", // font family
    1, // text spacing
    [0, 0] // offset
];




module keycap(
    size = [1, 1],
    stabilizerStemDistance = 0,
    stem = "MX",
    stabilizerStem = "MX",
    horizontalUnit = defaultHorizontalUnit,
    verticalUnit = defaultVerticalUnit,
    keycapScale = defaultKeycapScale,
    botToTopScale = defaultBotToTopScale,
    keyHeight = defaultKeyHeight,
    wallThickness = defaultWallThickness,
    cornerRadius = defaultCornerRadius,
    topEdgeRadius = defaultTopEdgeRadius,
    text = "",
    textStyle = defaultTextStyle
)
{
    width = size[0];
    depth = size[1];

    keycapSizeAbsoluteReduction = verticalUnit * (1 - keycapScale);
    keycapBotToTopAbsoluteReduction = keycapSizeAbsoluteReduction * botToTopScale;

    switchLowerFootprint = [width * horizontalUnit - keycapSizeAbsoluteReduction, depth * verticalUnit - keycapSizeAbsoluteReduction];
    switchUpperFootprint = switchLowerFootprint - [keycapBotToTopAbsoluteReduction, keycapBotToTopAbsoluteReduction];

    innerLowerFootprint = switchLowerFootprint - [wallThickness * 2, wallThickness * 2];
    innerUpperFootprint = switchUpperFootprint - [wallThickness * 2, wallThickness * 2];

    innerHeight = keyHeight - wallThickness;
    
    innerEdgeRadius = cornerRadius - wallThickness;

    stemHeight = innerHeight;


    difference()
    {
        //prismoid(size1 = switchLowerFootprint, size2 = switchUpperFootprint, rounding = edgeRadius, h = keyHeight);

        up(keyHeight / 2)
            rounded_prism(bottom = rect(switchLowerFootprint, rounding = cornerRadius), top = rect(switchUpperFootprint, rounding = cornerRadius), height = keyHeight, joint_top = topEdgeRadius, joint_bot = 0);

        prismoid(size1 = innerLowerFootprint, size2 = innerUpperFootprint, rounding = innerEdgeRadius, h = innerHeight);

        translate([textStyle[4][0], textStyle[4][1], keyHeight - textStyle[0]])
            linear_extrude(textStyle[0])
                text(text = text, valign = "center", halign = "center", size = textStyle[1], font = textStyle[2], spacing = textStyle[3]);
    }

    if(len(search([stem], allowedStems)) > 0)
    {
        if(stem == "MX")
        {
            mxStem();
        }
    }

    if(stabilizerStemDistance > 0)
    {
        if(len(search([stem], allowedStems)) > 0)
        {
            if(stem == "MX")
            {
                for(i = [-stabilizerStemDistance / 2, stabilizerStemDistance / 2])
                    translate([i, 0, 0])
                        mxStem();
            }
        }
    }
}



module mxStem(stemHeight = defaultKeyHeight - defaultWallThickness)
{
    // taken from: https://cdn.shopify.com/s/files/1/0657/6075/5954/files/SPEC-CPG135301D01_Kailh_Choc_V2_Low_Profile_Red_Switch.pdf?v=1666690444
    mxStemOuterDiamter = 5.5;
    mxStemCutoutDimensions = [4.1, 1.3, mxStemOuterDiamter] * 1.06;

    difference()
    {
        cylinder(d = mxStemOuterDiamter, h = stemHeight);

        for(i = [0, 1])
            translate([0, 0, mxStemCutoutDimensions[2] / 2])
                rotate([0, 0, 90 * i])
                    cube(mxStemCutoutDimensions, center = true);

    }

 
}