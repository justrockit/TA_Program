#include <iostream>
#include <vector>
#include <algorithm>
#include <cmath>
#include <sstream>
#include <fstream>
#include "vec.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

int resolution = 128;
int channel = 3;

Vec2f Hammersley(uint32_t i, uint32_t N) {
	uint32_t bits = (i << 16u) | (i >> 16u);
	bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
	bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
	bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
	bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
	float rdi = float(bits) * 2.3283064365386963e-10;
	return { float(i) / float(N), rdi };
}

Vec3f ImportanceSampleGGX(Vec2f Xi, Vec3f N, float roughness) {

	float a = roughness * roughness;

	// TODO: Copy the code from your previous work - Bonus 1
   //TODO: in spherical space - Bonus 1 构建球坐标数据
	/*
	 通过Xi.x和Xi.y的值计算出对应的角度（phi）和余弦值（cosTheta）。这里使用了GGX分布的逆CDF（累积分布函数）的近似。
	*/
	float  phi = 2.0 * PI * Xi.x;//把（0，1）的值 阔到（0，2Pi）;phi的范围就是0到 2pi
	float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a * a - 1.0) * Xi.y));
	float sinTheta = sqrt(1.0 - cosTheta * cosTheta);

	//TODO: from spherical space to cartesian space - Bonus 1 转到直角坐标系
	Vec3f  H;
	H.x = sinTheta * cos(phi);
	H.y = sinTheta * sin(phi);
	H.z = cosTheta;

	//TODO: tangent coordinates - Bonus 1
	// 得到TBN矩阵
	Vec3f up = abs(N.z) < 0.999 ? Vec3f(0.0, 0.0, 1.0) : Vec3f(1.0, 0.0, 0.0);
	Vec3f tangent = normalize(cross(up, N));//叉乘
	Vec3f bitangent = cross(N, tangent);
	//TODO: transform H to tangent space - Bonus 1
	Vec3f  T_H = tangent * H.x + bitangent * H.y + N * H.z;//把H向量逆变换到切线空间

	return normalize(T_H);
}


Vec3f IntegrateEmu(Vec3f V, float roughness, float NdotV, Vec3f Ei) {
	Vec3f Eavg = Vec3f(0.0f);
	const int sample_count = 1024;
	Vec3f N = Vec3f(0.0, 0.0, 1.0);

	for (int i = 0; i < sample_count; i++)
	{
		Vec2f Xi = Hammersley(i, sample_count);
		Vec3f H = ImportanceSampleGGX(Xi, N, roughness);
		Vec3f L = normalize(H * 2.0f * dot(V, H) - V);

		float NoL = std::max(L.z, 0.0f);
		float NoH = std::max(H.z, 0.0f);
		float VoH = std::max(dot(V, H), 0.0f);
		float NoV = std::max(dot(N, V), 0.0f);

		// TODO: To calculate Eavg here - Bonus 1
		Eavg += Ei * NoL * 2;

	}

	return Eavg / sample_count;
}

void setRGB(int x, int y, float alpha, unsigned char* data) {
	data[3 * (resolution * x + y) + 0] = uint8_t(alpha);
	data[3 * (resolution * x + y) + 1] = uint8_t(alpha);
	data[3 * (resolution * x + y) + 2] = uint8_t(alpha);
}

void setRGB(int x, int y, Vec3f alpha, unsigned char* data) {
	data[3 * (resolution * x + y) + 0] = uint8_t(alpha.x);
	data[3 * (resolution * x + y) + 1] = uint8_t(alpha.y);
	data[3 * (resolution * x + y) + 2] = uint8_t(alpha.z);
}

Vec3f getEmu(int x, int y, int alpha, unsigned char* data, float NdotV, float roughness) {
	return Vec3f(data[3 * (resolution * x + y) + 0],
		data[3 * (resolution * x + y) + 1],
		data[3 * (resolution * x + y) + 2]);
}

int main() {
	unsigned char* Edata = stbi_load("./GGX_E_LUT.png", &resolution, &resolution, &channel, 3);
	if (Edata == NULL)
	{
		std::cout << "ERROE_FILE_NOT_LOAD" << std::endl;
		return -1;
	}
	else
	{
		std::cout << resolution << " " << resolution << " " << channel << std::endl;
		// | -----> mu(j)
		// | 
		// | rough（i）
		// Flip it, if you want the data written to the texture
		uint8_t* data = new uint8_t[resolution * resolution * 3];
		float step = 1.0 / resolution;
		Vec3f Eavg = Vec3f(0.0);
		for (int i = 0; i < resolution; i++)
		{
			float roughness = step * (static_cast<float>(i) + 0.5f);
			for (int j = 0; j < resolution; j++)
			{
				float NdotV = step * (static_cast<float>(j) + 0.5f);
				Vec3f V = Vec3f(std::sqrt(1.f - NdotV * NdotV), 0.f, NdotV);

				Vec3f Ei = getEmu((resolution - 1 - i), j, 0, Edata, NdotV, roughness);
				Eavg += IntegrateEmu(V, roughness, NdotV, Ei) * step;
				setRGB(i, j, 0.0, data);
			}

			for (int k = 0; k < resolution; k++)
			{
				setRGB(i, k, Eavg, data);
			}

			Eavg = Vec3f(0.0);
		}
		stbi_flip_vertically_on_write(true);
		stbi_write_png("GGX_Eavg_IS_LUT.png", resolution, resolution, channel, data, 0);
	}
	stbi_image_free(Edata);
	return 0;
}