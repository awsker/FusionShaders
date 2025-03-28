// Card3D
// v1.0
// By asker

sampler2D img = sampler_state {
  MinFilter = Linear;
  MagFilter = Linear;
  AddressU = Border;
  AddressV = Border;
  BorderColor = float4(0, 0, 0, 0);
};

float fX, fY, fZ, fD, fZoom;

static const float RAD_TO_DEG = 3.14159265359f / 180.0f;

float4 ps_main( in float2 In : TEXCOORD0 ) : COLOR0 {
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
    float3 p = mul(rotMatrix, float3(In.x - 0.5, In.y - 0.5, 0.0)) + float3(0.5, 0.5, 0);

    // Transform camera position (0, 0, -fD) using the same matrix
    float3 c = mul(rotMatrix, float3(0.0, 0.0, -fD)) + float3(0.5, 0.5, 0);

    // Compute intersection with z = 0 plane
    float s = -c.z / (p.z - c.z);
    float2 xy = lerp(c.xy, p.xy, s);

    return tex2D(img, ((xy - 0.5) / fZoom) + 0.5);
}

technique tech_main {
  pass P0 {
    PixelShader = compile ps_2_0 ps_main();
  }
}