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
	std::vector<float> PDFs;//���ʷֲ�ֵ ����Ȩ��
}samplePoints;

//������Ҫ�Բ���
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
			Vec3f wi = Vec3f(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));//������ϵתֱ������ϵ,�ѹ�ʽ
			float pdf = wi.z / PI;

			samlpeList.directions.push_back(wi);
			samlpeList.PDFs.push_back(pdf);
		}
	}
	return samlpeList;
}

/*
����ͬ��GGX,�ѹ�ʽ
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

//SchlickGGX �������� G��,�ѹ�ʽ
float GeometrySchlickGGX(float NdotV, float roughness) {
	float a = roughness;
	float k = (a * a) / 2.0f;

	float nom = NdotV;
	float denom = NdotV * (1.0f - k) + k;

	return nom / denom;
}
// �������� G��
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

		  //׼�� F��G��D����������
		Vec3f L = normalize(sampleList.directions[i]);//���շ���
		float pdf = sampleList.PDFs[i];//���ʷֲ�ֵ
		float NdotL = std::max(dot(N, L), 0.0f);//��ȡ��ֵ
		//�������
		Vec3f H = normalize(V + L);
		//f��
		float f = 1.0f;
		float d = DistributionGGX(N, H, roughness);
		float g = GeometrySmith(roughness, NdotV, NdotL);
		// ����Brdf
		//��ʽ�°벿
		float value = 4 * NdotV * NdotL;
		// ��NdotL����ʵ������Ⱦ���̵�cos�

		/*
		Ϊɶ�ǳ��� PDF��������
		���嵽BRDF�ļ����У������ĳ���ֲ��в�����������շ���L��΢ƽ��ķ��߷���ȣ���
		�÷���ѡ�еĸ�����PDF������Ϊ�˵õ����ֵ�����ֵ����ȫ�ֵ�ƽ��Ч����
		������Ҫȷ�����������Ĺ�����ƽ�ȵġ����ĳЩ���򱻸�Ƶ���ز���������PDFֵ�ϴ󣩣�
		��ô��Щ�����Ĺ��׾�Ӧ����Ӧ��С����֮��Ȼ������ͨ���������ļ���������PDFֵ��ʵ�ֵģ��Ӷ�ʵ���ˡ��ز���������Ҫ�Բ�������
		*/

		float brdf = (f * d * g * NdotL) / value / pdf;
		A = A + brdf;
		B = B + brdf;
		C = C + brdf;
	}
	return { A / sample_count, B / sample_count, C / sample_count };
}

/*
Ԥ���� һ�� roughness��NdotV��ɵ�ͼ ������ÿ�������ϲ�ͬ�ֲڶȵ�����������
*/
int main() {
	uint8_t* data = new uint8_t[resolution * resolution * 3];//�ֱ���*3 ��ΪRGB��һ��
	float step = 1.0 / resolution;
	for (int i = 0; i < resolution; i++) {
		for (int j = 0; j < resolution; j++) {
			//NdotV��roughnessֱ��ȡֵ ������������������ͼƬ�ĺ�����
			float roughness = step * (static_cast<float>(i) + 0.5f);
			float NdotV = step * (static_cast<float>(j) + 0.5f);

			//ͨ��NdotV ����V,�ڵ�λ�������ϣ�����y��Ϊ0,z�����ΪNdotV��rΪ1�������x�������õ�v����
			//��Ϊ�趨Ϊ����ͬ�ԣ����� ����޹� ����й� ��phi�Ƿ�λ�棨ˮƽ�棩�ڵĽǶȣ���Χ0~360�ȣ��� theta�Ǹ����棨��ֱ�棩�ڵĽǶȣ���Χ0~180�ȣ����Ŧȣ�
			Vec3f V = Vec3f(std::sqrt(1.f - NdotV * NdotV), 0.f, NdotV);
			//���������������ֵ
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