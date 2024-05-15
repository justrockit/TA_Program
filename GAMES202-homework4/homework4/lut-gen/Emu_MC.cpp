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

typedef struct samplePoints {
	std::vector<Vec3f> directions;
	std::vector<float> PDFs;//概率分布值 类似权重
}samplePoints;

//余弦重要性采样
samplePoints squareToCosineHemisphere(int sample_count) {
	samplePoints samlpeList;
	const int sample_side = static_cast<int>(floor(sqrt(sample_count)));

	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_real_distribution<> rng(0.0, 1.0);
	for (int t = 0; t < sample_side; t++) {
		for (int p = 0; p < sample_side; p++) {
			double samplex = (t + rng(gen)) / sample_side;
			double sampley = (p + rng(gen)) / sample_side;

			double theta = 0.5f * acos(1 - 2 * samplex);
			double phi = 2 * PI * sampley;
			Vec3f wi = Vec3f(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));//球坐标系转直角坐标系,搜公式
			float pdf = wi.z / PI;

			samlpeList.directions.push_back(wi);
			samlpeList.PDFs.push_back(pdf);
		}
	}
	return samlpeList;
}

/*
各向同性GGX,搜公式
*/
float DistributionGGX(Vec3f N, Vec3f H, float roughness)
{
	float a = roughness * roughness;
	float a2 = a * a;
	float NdotH = std::max(dot(N, H), 0.0f);
	float NdotH2 = NdotH * NdotH;

	float nom = a2;
	float denom = (NdotH2 * (a2 - 1.0) + 1.0);
	denom = PI * denom * denom;

	return nom / std::max(denom, 0.0001f);
}

//SchlickGGX 用来计算 G项,搜公式
float GeometrySchlickGGX(float NdotV, float roughness) {
	float a = roughness;
	float k = (a * a) / 2.0f;

	float nom = NdotV;
	float denom = NdotV * (1.0f - k) + k;

	return nom / denom;
}
// 用来计算 G项
float GeometrySmith(float roughness, float NoV, float NoL) {
	float ggx2 = GeometrySchlickGGX(NoV, roughness);
	float ggx1 = GeometrySchlickGGX(NoL, roughness);

	return ggx1 * ggx2;
}

Vec3f IntegrateBRDF(Vec3f V, float roughness, float NdotV) {
	float A = 0.0;
	float B = 0.0;
	float C = 0.0;
	const int sample_count = 1024;
	Vec3f N = Vec3f(0.0, 0.0, 1.0);

	samplePoints sampleList = squareToCosineHemisphere(sample_count);
	for (int i = 0; i < sample_count; i++) {
		// TODO: To calculate (fr * ni) / p_o here

		  //准备 F，G，D项所需数据
		Vec3f L = normalize(sampleList.directions[i]);//光照方向
		float pdf = sampleList.PDFs[i];//概率分布值
		float NdotL = std::max(dot(N, L), 0.0f);//不取负值
		//半角向量
		Vec3f H = normalize(V + L);
		//f项
		float f = 1.0f;
		float d = DistributionGGX(N, H, roughness);
		float g = GeometrySmith(roughness, NdotV, NdotL);
		// 计算Brdf
		//公式下半部
		float value = 4 * NdotV * NdotL;
		// 乘NdotL（其实就是渲染方程的cos项）

		/*
		为啥是除于 PDF！！！！
		具体到BRDF的计算中，当你从某个分布中采样方向（如光照方向L或微平面的法线方向等），
		该方向被选中的概率由PDF给出。为了得到积分的期望值，即全局的平均效果，
		我们需要确保所有样本的贡献是平等的。如果某些方向被更频繁地采样（即其PDF值较大），
		那么这些样本的贡献就应该相应减小，反之亦然。这是通过将样本的计算结果除以PDF值来实现的，从而实现了“重采样”或“重要性采样”。
		*/

		float brdf = (f * d * g * NdotL) / value / pdf;
		A = A + brdf;
		B = B + brdf;
		C = C + brdf;
	}
	return { A / sample_count, B / sample_count, C / sample_count };
}

/*
预计算 一张 roughness和NdotV组成的图 来描述每个方向上不同粗糙度的能量补偿项
*/
int main() {
	uint8_t* data = new uint8_t[resolution * resolution * 3];//分辨率*3 因为RGB各一个
	float step = 1.0 / resolution;
	for (int i = 0; i < resolution; i++) {
		for (int j = 0; j < resolution; j++) {
			//NdotV和roughness直接取值 ，用来做打表参数，做图片的横竖轴
			float roughness = step * (static_cast<float>(i) + 0.5f);
			float NdotV = step * (static_cast<float>(j) + 0.5f);

			//通过NdotV 反推V,在单位半球面上，假设y轴为0,z轴分量为NdotV，r为1，可算出x分量，得到v向量
			//因为设定为各向同性，所以 与φ无关 与θ有关 （phi是方位面（水平面）内的角度，范围0~360度，φ theta是俯仰面（竖直面）内的角度，范围0~180度，符号θ）
			Vec3f V = Vec3f(std::sqrt(1.f - NdotV * NdotV), 0.f, NdotV);
			//计算能量补偿项的值
			Vec3f irr = IntegrateBRDF(V, roughness, NdotV);

			//RGB
			data[(i * resolution + j) * 3 + 0] = uint8_t(irr.x * 255.0);
			data[(i * resolution + j) * 3 + 1] = uint8_t(irr.y * 255.0);
			data[(i * resolution + j) * 3 + 2] = uint8_t(irr.z * 255.0);
		}
	}
	stbi_flip_vertically_on_write(true);
	stbi_write_png("GGX_E_MC_LUT.png", resolution, resolution, 3, data, resolution * 3);

	std::cout << "Finished precomputed!" << std::endl;
	return 0;
}