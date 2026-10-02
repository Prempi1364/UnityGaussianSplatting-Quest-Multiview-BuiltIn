// SPDX-License-Identifier: MIT
Shader "Gaussian Splatting/Render Splats"
{
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        Pass
        {
            ZWrite Off
            ZTest LEqual
            Blend OneMinusDstAlpha One
            Cull Off
            
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma require compute
#pragma use_dxc
#pragma multi_compile _ STEREO_INSTANCING_ON STEREO_MULTIVIEW_ON

#include "UnityCG.cginc"
#include "GaussianSplatting.hlsl"

StructuredBuffer<uint> _OrderBuffer;
uint _SplatCount;

struct appdata
{
    uint vertexID : SV_VertexID;
    uint instanceID : SV_InstanceID;
};

struct v2f
{
    half4 col : COLOR0;
    float2 pos : TEXCOORD0;
    float4 screenPos : TEXCOORD1;
    float splatEyeDepth : TEXCOORD2;
    float4 vertex : SV_POSITION;
};

StructuredBuffer<SplatViewData> _SplatViewData;
ByteAddressBuffer _SplatSelectedBits;
uint _SplatBitsValid;
uint _EyeIndex;
uint _UseForcedEyeIndex;
uint _UseCameraDepthTexture;
float _SplatDepthBias;

#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON) || defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
UNITY_DECLARE_TEX2DARRAY(_CameraDepthTexture);
float SampleGaussianSceneDepth(float2 uv, uint eyeIndex)
{
    return UNITY_SAMPLE_TEX2DARRAY(_CameraDepthTexture, float3(uv, eyeIndex)).r;
}
#else
UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
float SampleGaussianSceneDepth(float2 uv, uint eyeIndex)
{
    return SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
}
#endif

v2f vert (appdata v)
{
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f, o);

    uint vtxID = v.vertexID;
    uint instID = v.instanceID;
    if (instID >= _SplatCount)
    {
        o.vertex = asfloat(0x7fc00000);
        return o;
    }

    instID = _OrderBuffer[instID];
    uint eyeIndex = _UseForcedEyeIndex != 0 ? _EyeIndex : 0;
	SplatViewData view = _SplatViewData[instID + eyeIndex * _SplatCount];

    float4 centerClipPos = view.pos;
    o.splatEyeDepth = centerClipPos.w;

	bool behindCam = centerClipPos.w <= 0;
	if (behindCam)
	{
		o.vertex = asfloat(0x7fc00000); // NaN discards the primitive
	}
	else
	{
		o.col.r = f16tof32(view.color.x >> 16);
		o.col.g = f16tof32(view.color.x);
		o.col.b = f16tof32(view.color.y >> 16);
		o.col.a = f16tof32(view.color.y);

		uint idx = vtxID;
		float2 quadPos = float2(idx&1, (idx>>1)&1) * 2.0 - 1.0;
		quadPos *= 2;

		o.pos = quadPos;

		float2 deltaScreenPos = (quadPos.x * view.axis1 + quadPos.y * view.axis2) * 2 / _ScreenParams.xy;
		o.vertex = centerClipPos;
		o.vertex.xy += deltaScreenPos * centerClipPos.w;

		// is this splat selected?
		if (_SplatBitsValid)
		{
			uint wordIdx = instID / 32;
			uint bitIdx = instID & 31;
			uint selVal = _SplatSelectedBits.Load(wordIdx * 4);
			if (selVal & (1 << bitIdx))
			{
				o.col.a = -1;				
			}
		}
	}
	FlipProjectionIfBackbuffer(o.vertex);
    o.screenPos = ComputeScreenPos(o.vertex);
    return o;
}

half4 frag (v2f i) : SV_Target
{
    if (_UseCameraDepthTexture != 0)
    {
        float2 uv = i.screenPos.xy / i.screenPos.w;
        if (uv.x < 0 || uv.x > 1 || uv.y < 0 || uv.y > 1)
            discard;

        float sceneRawDepth = SampleGaussianSceneDepth(uv, _EyeIndex);
        float sceneEyeDepth = LinearEyeDepth(sceneRawDepth);
        if (i.splatEyeDepth > sceneEyeDepth + _SplatDepthBias)
            discard;
    }

	float power = -dot(i.pos, i.pos);
	half alpha = exp(power);
	if (i.col.a >= 0)
	{
		alpha = saturate(alpha * i.col.a);
	}
	else
	{
		// "selected" splat: magenta outline, increase opacity, magenta tint
		half3 selectedColor = half3(1,0,1);
		if (alpha > 7.0/255.0)
		{
			if (alpha < 10.0/255.0)
			{
				alpha = 1;
				i.col.rgb = selectedColor;
			}
			alpha = saturate(alpha + 0.3);
		}
		i.col.rgb = lerp(i.col.rgb, selectedColor, 0.5);
	}
	
    if (alpha < 1.0/255.0)
        discard;

    half4 res = half4(i.col.rgb * alpha, alpha);
    return res;
}
ENDCG
        }
    }
}
