// Global variables	
sampler2D tex : register(s0);

float4 outlineColor;

float fPixelWidth;
float fPixelHeight;

float4 ps_main(float2 texCoord : TEXCOORD) : COLOR
{
	float4 texColor = tex2D(tex, texCoord);
    float neighborPixel = 0.0;
    if (texColor.a == 0.0) {
        neighborPixel = tex2D(tex, texCoord + float2(fPixelWidth, 0)).a;
        neighborPixel = max(neighborPixel, tex2D(tex, texCoord + float2(-fPixelWidth, 0)).a);
        neighborPixel = max(neighborPixel, tex2D(tex, texCoord + float2(0, fPixelHeight)).a);
        neighborPixel = max(neighborPixel, tex2D(tex, texCoord + float2(0, -fPixelHeight)).a);
    }
    float edge = step(0.01, neighborPixel);
    texColor.rgb = lerp(texColor.rgb, outlineColor.rgb, edge);
    texColor.a = max(texColor.a, edge);
    return texColor;
}

// Effect technique
technique tech_main
{
    pass P0
    {
        // shaders
        VertexShader = NULL;
        PixelShader  = compile ps_2_0 ps_main();
    }  
}