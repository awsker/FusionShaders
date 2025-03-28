// Card3D
// v1.0
// By asker

// Pixel shader input structure
struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
  float4 Position : SV_POSITION;
};



Texture2D<float4> img : register(t0);
sampler imgSampler : register(s0);

static const float RAD_TO_DEG = 3.14159265359f / 180.0f;

cbuffer PS_VARIABLES:register(b0)
{
	float fX, fY, fZ, fD, fZoom;
}

float4 Demultiply(float4 _color)
{
	float4 color = _color;
	if ( color.a != 0 )
		color.xyz /= color.a;
	return color;
}

float4 ps_main( in PS_INPUT In ) : SV_TARGET {
	float dX = fX * RAD_TO_DEG;
	float dY = fY * RAD_TO_DEG;
	float dZ = fZ * RAD_TO_DEG;

	// Compute sin/cos values once
	float cx = cos(dX), sx = sin(dX);
	float cy = cos(dY), sy = sin(dY);
	float cz = cos(dZ), sz = sin(dZ);

	// 3x3 Rotation Matrix
	float3x3 rotMatrix = float3x3(
	  cx * cz,    sy * sx * cz - cy * sz,   cy * sx * cz + sy * sz,
	  cx * sz,    sy * sx * sz + cy * cz,   cy * sx * sz - sy * cz,
	  -sx,        sy * cx,                  cy * cx
	);

	// Offset pixel coordinates to center
	float3 p = mul(rotMatrix, float3(In.texCoord.x - 0.5, In.texCoord.y - 0.5, 0.0)) + float3(0.5, 0.5, 0);

	// Transform camera position (0, 0, -fD) using the same matrix
	float3 c = mul(rotMatrix, float3(0.0, 0.0, -fD)) + float3(0.5, 0.5, 0);

	// Compute intersection with z = 0 plane
	float s = -c.z / (p.z - c.z);
	float2 xy = lerp(c.xy, p.xy, s);

	float4 outColor = Demultiply(img.Sample(imgSampler, ((xy - 0.5) / fZoom) + 0.5));
	outColor.rgb *= outColor.a;
	return outColor * In.Tint;
}

float4 ps_main_pm( in PS_INPUT In ) : SV_TARGET {
	float dX = fX * RAD_TO_DEG;
	float dY = fY * RAD_TO_DEG;
	float dZ = fZ * RAD_TO_DEG;

	// Compute sin/cos values once
	float cx = cos(dX), sx = sin(dX);
	float cy = cos(dY), sy = sin(dY);
	float cz = cos(dZ), sz = sin(dZ);

	// 3x3 Rotation Matrix
	float3x3 rotMatrix = float3x3(
	  cx * cz,    sy * sx * cz - cy * sz,   cy * sx * cz + sy * sz,
	  cx * sz,    sy * sx * sz + cy * cz,   cy * sx * sz - sy * cz,
	  -sx,        sy * cx,                  cy * cx
	);

	// Offset pixel coordinates to center
	float3 p = mul(rotMatrix, float3(In.texCoord.x - 0.5, In.texCoord.y - 0.5, 0.0)) + float3(0.5, 0.5, 0);

	// Transform camera position (0, 0, -fD) using the same matrix
	float3 c = mul(rotMatrix, float3(0.0, 0.0, -fD)) + float3(0.5, 0.5, 0);

	// Compute intersection with z = 0 plane
	float s = -c.z / (p.z - c.z);
	float2 xy = lerp(c.xy, p.xy, s);

	float4 outColor = Demultiply(img.Sample(imgSampler, ((xy - 0.5) / fZoom) + 0.5));
	outColor.rgb *= outColor.a;
	return outColor * In.Tint;
}