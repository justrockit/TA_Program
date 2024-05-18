#include <iostream>
#include <vector>
#include <algorithm>
#include <cmath>
#include <sstream>
#include <fstream>
#include <random>
#include "vec.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION

#include "stb_image_write.h"

const int resolution = 128;


/*
* 这个函数 Hammersley 实现了一种生成二维均匀分布点集的方法是（（0，1），（0，1））的 点用于从单位正方形 [0,1]^2 中随机采样
*
*/
Vec2f Hammersley(uint32_t i, uint32_t N) { // 0-1
	uint32_t bits = (i << 16u) | (i >> 16u);
	bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
	bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
	bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
	bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
	float rdi = float(bits) * 2.3283064365386963e-10;
	return { float(i) / float(N), rdi };
}

/*
GGX重要性采样 要构建采样向量，
我们需要一些方法定向和偏移采样向量，
以使其朝向特定粗糙度的镜面波瓣方向。
我们可以如理论教程中所述使用 NDF，
并将 GGX NDF 结合到球形采样向量的处理中

有别于均匀或纯随机地（比如蒙特卡洛）在积分半球 Ω
 产生采样向量，我们的采样会根据粗糙度，偏向微表面的半向量的宏观反射方向。
 采样过程将与我们之前看到的过程相似：
 开始一个大循环，生成一个随机（低差异）序列值，用该序列值在切线空间中生成样本向量，
 将样本向量变换到世界空间并对场景的辐射度采样。不同之处在于，我们现在使用低差异序列值作为输入来生成采样向量：
 Xi 低预差得到得点

*/
Vec3f ImportanceSampleGGX(Vec2f Xi, Vec3f N, float roughness) {
	float a = roughness * roughness;

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



float GeometrySchlickGGX(float NdotV, float roughness) {
	// TODO: To calculate Schlick G1 here - Bonus 1
	float a = roughness;
	float k = (a * a) / 2.0f;
	float nom = NdotV;
	float denom = NdotV * (1.0f - k) + k;
	return nom / denom;
}

float GeometrySmith(float roughness, float NoV, float NoL) {
	float ggx2 = GeometrySchlickGGX(NoV, roughness);
	float ggx1 = GeometrySchlickGGX(NoL, roughness);

	return ggx1 * ggx2;
}

Vec3f IntegrateBRDF(Vec3f V, float roughness) {

	const int sample_count = 1024;
	Vec3f N = Vec3f(0.0, 0.0, 1.0);//几何法线
	float Emu = 0.0f;
	for (int i = 0; i < sample_count; i++) {
		Vec2f Xi = Hammersley(i, sample_count);//伪随机坐标
		Vec3f H = ImportanceSampleGGX(Xi, N, roughness);//半程向量H
		Vec3f L = normalize(H * 2.0f * dot(V, H) - V);//Wi(Wo和半程向量H反推)，入射向量

		float NoL = std::max(L.z, 0.0f);
		float NoH = std::max(H.z, 0.0f);
		float VoH = std::max(dot(V, H), 0.0f);
		float NoV = std::max(dot(N, V), 0.0f);

		// TODO: To calculate (fr * ni) / p_o here - Bonus 1 计算Brdf值
		float F = 1;
		float G = GeometrySmith(roughness, NoV, NoL);
		float  weight = G * VoH / (NoV * NoH);//这个是pdf ，去看作业4的公式

		Emu = Emu + weight;
		// Split Sum - Bonus 2

	}
	Emu = Emu / sample_count;

	return Vec3f(Emu);
}

int main() {
	uint8_t* data = new uint8_t[resolution * resolution * 3];
	float step = 1.0 / resolution;
	for (int i = 0; i < resolution; i++) {
		for (int j = 0; j < resolution; j++) {
			float roughness = step * (static_cast<float>(i) + 0.5f);
			float NdotV = step * (static_cast<float>(j) + 0.5f);

			Vec3f V = Vec3f(std::sqrt(1.f - NdotV * NdotV), 0.f, NdotV);

			Vec3f irr = IntegrateBRDF(V, roughness);

			data[(i * resolution + j) * 3 + 0] = uint8_t(irr.x * 255.0);
			data[(i * resolution + j) * 3 + 1] = uint8_t(irr.y * 255.0);
			data[(i * resolution + j) * 3 + 2] = uint8_t(irr.z * 255.0);
		}
	}
	stbi_flip_vertically_on_write(true);
	stbi_write_png("GGX_E_LUT.png", resolution, resolution, 3, data, resolution * 3);

	std::cout << "Finished precomputed!" << std::endl;
	return 0;
}