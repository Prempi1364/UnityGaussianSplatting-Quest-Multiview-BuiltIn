// SPDX-License-Identifier: MIT
Shader "Hidden/Gaussian Splatting/Composite"
{
    SubShader
    {
        Pass
        {
            ZWrite Off
            ZTest Always
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma require compute
#pragma use_dxc
#include "UnityCG.cginc"

struct v2f
{
    float4 vertex : SV_POSITION;
};

v2f vert (uint vtxID : SV_VertexID)
{
    v2f o;
    float2 quadPos = float2(vtxID&1, (vtxID>>1)&1) * 4.0 - 1.0;
	o.vertex = float4(quadPos, 1, 1);
    return o;
}

Texture2D _GaussianSplatRT;

half4 frag (v2f i) : SV_Target
{
    int2 pixel = int2(i.vertex.xy);
    half4 col = _GaussianSplatRT.Load(int3(pixel, 0));
    if (col.a <= 0.0001)
        return half4(0, 0, 0, 0);
    return float4(GammaToLinearSpace(col.rgb/col.a),col.a);
}
ENDCG
        }

        Pass
        {
            ZWrite Off
            ZTest Always
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma require compute
#pragma use_dxc
#include "UnityCG.cginc"

struct v2f
{
    float4 vertex : SV_POSITION;
};

v2f vert (uint vtxID : SV_VertexID)
{
    v2f o;
    float2 quadPos = float2(vtxID&1, (vtxID>>1)&1) * 4.0 - 1.0;
    o.vertex = float4(quadPos, 1, 1);
    return o;
}

Texture2DArray _GaussianSplatRT;
uint _EyeIndex;

half4 frag (v2f i) : SV_Target
{
    int2 pixel = int2(i.vertex.xy);
    half4 col = _GaussianSplatRT.Load(int4(pixel, _EyeIndex, 0));
    if (col.a <= 0.0001)
        return half4(0, 0, 0, 0);
    return float4(GammaToLinearSpace(col.rgb/col.a), col.a);
}
ENDCG
        }
    }
}
