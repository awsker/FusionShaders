Texture2D<float4> tex : register(t0);
sampler texSampler : register(s0);

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
  float4 Position : SV_POSITION;
};

cbuffer PS_VARIABLES : register(b0)
{
    float4 outlineColor;
}

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

float4 Demultiply(float4 _color)
{
	float4 color = _color;
	if ( color.a != 0 )
		color.xyz /= color.a;
	return color;
}

float4 ps_main(PS_INPUT In) : SV_TARGET
{
    float4 texColor = tex.Sample(texSampler, In.texCoord);
    float neighborPixel = 0.0;
    if (texColor.a == 0.0) {
        neighborPixel = tex.Sample(texSampler, In.texCoord + float2(fPixelWidth, 0)).a;
        neighborPixel = max(neighborPixel, tex.Sample(texSampler, In.texCoord + float2(-fPixelWidth, 0)).a);
        neighborPixel = max(neighborPixel, tex.Sample(texSampler, In.texCoord + float2(0, fPixelHeight)).a);
        neighborPixel = max(neighborPixel, tex.Sample(texSampler, In.texCoord + float2(0, -fPixelHeight)).a);
    }
    float edge = step(0.01, neighborPixel);
    texColor.rgb = lerp(texColor.rgb, outlineColor.rgb, edge);
    texColor.a = max(texColor.a, edge);
    return Demultiply(texColor) * In.Tint;
}

float4 ps_main_pm(PS_INPUT In) : SV_TARGET
{
    float4 texColor = tex.Sample(texSampler, In.texCoord);
    float neighborPixel = 0.0;
    if (texColor.a == 0.0) {
        neighborPixel = tex.Sample(texSampler, In.texCoord + float2(fPixelWidth, 0)).a;
        neighborPixel = max(neighborPixel, tex.Sample(texSampler, In.texCoord + float2(-fPixelWidth, 0)).a);
        neighborPixel = max(neighborPixel, tex.Sample(texSampler, In.texCoord + float2(0, fPixelHeight)).a);
        neighborPixel = max(neighborPixel, tex.Sample(texSampler, In.texCoord + float2(0, -fPixelHeight)).a);
    }
    float edge = step(0.01, neighborPixel);
    texColor.rgb = lerp(texColor.rgb, outlineColor.rgb, edge);
    texColor.a = max(texColor.a, edge);
    return texColor * In.Tint;
}