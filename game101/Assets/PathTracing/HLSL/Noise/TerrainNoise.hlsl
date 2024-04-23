#ifndef TERRAINNOISE_HLSL
#define TERRAINNOISE_HLSL
#include "NoiseCommonDef.hlsl"
//Auto Generated by CosFBM
//Texture2D CosFBM_height;
//Texture2D CosFBM_grad;

float CosFBM(float2 p)
{
	float re = 0;
	re += 25 * cos(dot(float2(0.8619711, -0.5069574), 0.02*p) + 98.56716);
	re += 12.5*cos(dot(float2(0.9921913, 0.124726), 0.03*p) + 27.27358);
	re += 6.25*cos(dot(float2(-0.8505982, -0.5258163), 0.045*p) + 78.25523);
	re += 3.125*cos(dot(float2(-0.8797794, -0.4753822), 0.0675*p) + 78.9523);
	return re;
}

float2 CosFBM_Dxy(float2 p)
{
	float2 re = 0;
	re += -sin(dot(float2(0.8619711, -0.5069574), 0.02* p) + 98.56716) *float2(0.8619711, -0.5069574) * 0.5;
	re += -sin(dot(float2(0.9921913, 0.124726), 0.03* p) + 27.27358) *float2(0.9921913, 0.124726) * 0.375;
	re += -sin(dot(float2(-0.8505982, -0.5258163), 0.045* p) + 78.25523) *float2(-0.8505982, -0.5258163) * 0.28125;
	re += -sin(dot(float2(-0.8797794, -0.4753822), 0.0675* p) + 78.9523) *float2(-0.8797794, -0.4753822) * 0.2109375;
	return re;
}

float CosFBM(float3 pos)
{
	return CosFBM(pos.xz);
}

float2 CosFBM_DisSquareGrad(float2 p, float3 target)
{
	return 2 * (p - target.xz) + 2 * (CosFBM(p) - target.y)*CosFBM_Dxy(p);
}

float3 CosFBM_NearestPoint(float3 target, int loopNum, float step)
{
	float2 p = target.xz;
	for (int i = 0; i < loopNum; i++)
	{
		p -= CosFBM_DisSquareGrad(p, target) * step;
	}
	return float3(p.x, CosFBM(p), p.y);
}

Texture2D terrainDetail;
SamplerState noise_point_repeat_sampler;
float TerrainDetailNoise(float2 p)
{
    float3 hBound = float3(300, 50, 300);
    float2 ndc = p / hBound.xz;
    float2 uv = (1 + ndc) * 0.5;
    return terrainDetail.SampleLevel(noise_linear_repeat_sampler, uv, 0).x;
}
#endif