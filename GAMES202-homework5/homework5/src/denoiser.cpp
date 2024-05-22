#include "denoiser.h"

Denoiser::Denoiser() : m_useTemportal(false) {}

// Screeni−1 = Pi−1Vi−1Mi−1M−1i Worldi
/*
做矩阵的逆变换 投影上一帧结果
计算当前帧每个像素在上一帧的对应点，并将上一帧的
结果投影到当前帧。
思路：1.先得到一个点的世界坐标
2.再用M矩阵逆变换到局部坐标
3.再用前一帧的M矩阵变化到世界坐标
4.再用前一帧PV矩阵变化到前一帧的屏幕
*/
void Denoiser::Reprojection(const FrameInfo &frameInfo) {
    int height = m_accColor.m_height;
    int width = m_accColor.m_width;

    //前一帧的FrameInfo  m_preFrameInfo PV矩阵
    Matrix4x4 preWorldToScreen =
        m_preFrameInfo.m_matrix[m_preFrameInfo.m_matrix.size() - 1];
    Matrix4x4 preWorldToCamera =
        m_preFrameInfo.m_matrix[m_preFrameInfo.m_matrix.size() - 2];
#pragma omp parallel for
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // TODO: Reproject
            m_valid(x, y) = false;
            m_misc(x, y) = Float3(0.f);
            //剔除非移动物体的计算
            auto id = frameInfo.m_id(x, y);
            if (id == -1) {

                continue;
            }
            //当前点的世界坐标
            Float3 currentWorldPos = frameInfo.m_position(x, y);
            //当前有id点的矩阵M
            Matrix4x4 currentMatrix_M = frameInfo.m_matrix[id];

            //前一帧相同id点的矩阵M
            Matrix4x4 beforeMatrix_M = m_preFrameInfo.m_matrix[id];

            //逆变换M
            currentMatrix_M = Inverse(currentMatrix_M);
            //得到当前点的local坐标
            Float3 currentLocalPos =
                currentMatrix_M(currentWorldPos, Float3::EType::Point);
            //得到当前点前一帧的世界坐标
            Float3 beforeWorldPos = beforeMatrix_M(currentLocalPos, Float3::EType::Point);
            //得到当前点前一帧的屏幕坐标，用PV矩阵
            Float3 beforeScreenPos =
                preWorldToScreen(beforeWorldPos, Float3::EType::Point);

            //范围外不计算入内
            if (beforeScreenPos.x > width || beforeScreenPos.y > height ||
                beforeScreenPos.x < 0 || beforeScreenPos.y < 0) {
                continue;
            } else {
                auto pre_id = m_preFrameInfo.m_id(beforeScreenPos.x, beforeScreenPos.y);
                if (pre_id == id) {
                    m_valid(x, y) = true;
                    m_misc(x, y) = m_accColor(beforeScreenPos.x, beforeScreenPos.y);
                }
            }
        }
    }
    std::swap(m_misc, m_accColor);
}
/*
解决outlier点（颜色值远高于1的点，对滤波造成的影响），将其clamping 到(µ − kσ, µ + kσ)范围
*/
void Denoiser::TemporalAccumulation(const Buffer2D<Float3> &curFilteredColor) {
    int height = m_accColor.m_height;
    int width = m_accColor.m_width;
    int kernelRadius = 3;
#pragma omp parallel for
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // TODO: Temporal clamp
            Float3 color = m_accColor(x, y);
            // TODO: Exponential moving average
            float alpha = 1.0f;
     
            if (m_valid(x, y))
            {
                alpha = m_alpha;
                /*
          算当前帧的 7X7  均值 µ 和方差 σ ，给出(µ − kσ, µ + kσ)范围
      ，对上一帧的点进行clamping,这样相差很大的颜色会被补平
      */
                int max_x = std::min(width - 1, x + kernelRadius);
                int max_y = std::min(height - 1, y + kernelRadius);
                int min_x = std::max(0, x - kernelRadius);
                int min_y = std::max(0, y - kernelRadius);
                Float3 mu = .0;    // 均值
                Float3 sigma = .0; // 方差
                int count = kernelRadius * 2 + 1;
                count *= count;
                for (int i = min_x; i <= max_x; i++) {
                    for (int j = min_y; j <= max_y; j++) {
                        mu += curFilteredColor(i, j);
                    }
                }
                mu = mu / float(count);
                for (size_t i = min_x; i < max_x; i++) {
                    for (size_t j = min_y; j < max_y; j++) {
                        auto value = curFilteredColor(i, j) - mu;
                        sigma = sigma + value * value;
                    }
                }
                sigma = sigma / float(count);
                color =
                    Clamp(color, mu - sigma * m_colorBoxK, mu + sigma * m_colorBoxK);

            }   
            m_misc(x, y) = Lerp(color, curFilteredColor(x, y), alpha);
        }
    }
    std::swap(m_misc, m_accColor);
}

void Denoiser::Reprojection1(const FrameInfo &frameInfo) {
    int height = m_accColor.m_height;
    int width = m_accColor.m_width;
    Matrix4x4 preWorldToScreen =
        m_preFrameInfo.m_matrix[m_preFrameInfo.m_matrix.size() - 1];
    Matrix4x4 preWorldToCamera =
        m_preFrameInfo.m_matrix[m_preFrameInfo.m_matrix.size() - 2];
#pragma omp parallel for
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // TODO: Reproject
            m_valid(x, y) = false;
            m_misc(x, y) = Float3(0.f);
        }
    }
    std::swap(m_misc, m_accColor);
}

void Denoiser::TemporalAccumulation1(const Buffer2D<Float3> &curFilteredColor) {
    int height = m_accColor.m_height;
    int width = m_accColor.m_width;
    int kernelRadius = 3;
#pragma omp parallel for
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            // TODO: Temporal clamp
            Float3 color = m_accColor(x, y);
            // TODO: Exponential moving average
            float alpha = 1.0f;
            m_misc(x, y) = Lerp(color, curFilteredColor(x, y), alpha);
        }
    }
    std::swap(m_misc, m_accColor);
}



Buffer2D<Float3> Denoiser::Filter(const FrameInfo &frameInfo) {
    int height = frameInfo.m_beauty.m_height;
    int width = frameInfo.m_beauty.m_width;
    Buffer2D<Float3> filteredImage = CreateBuffer2D<Float3>(width, height);
    int kernelRadius = 16;
#pragma omp parallel for
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
           // std::cout << "X+" << x << "Y+" << y << std::endl;
            // TODO: Joint bilateral filter
            //联合双边滤波 具体去看公式
            //滤波范围
            int max_x = std::min(width - 1, x + kernelRadius);
            int max_y = std::min(height - 1, y + kernelRadius);
            int min_x = std::max(0, x - kernelRadius);
            int min_y = std::max(0, y - kernelRadius);

            Float3 c_normal = frameInfo.m_normal(x, y);
            Float3 c_pos = frameInfo.m_position(x, y);
            //Float3 c_depth = frameInfo.m_depth(x, y);
            Float3 c_color = frameInfo.m_beauty(x, y);
         
            /*            float m_alpha = 0.2f;
                    float m_sigmaPlane = 0.1f;
                    float m_sigmaColor = 0.6f;
                    float m_sigmaNormal = 0.1f;
                    float m_sigmaCoord = 32.0f;
                    float m_colorBoxK = 1.0f;*/

            float filterValues = 0.0;
            Float3 finalColor;
            for (int i = min_x; i <= max_x; i++) {
                for (int j = min_y; j <= max_y; j++) {
                
                      //    std::cout <<  "I+" << i << "J+" << j  << std::endl;
                    auto o_normal = frameInfo.m_normal(i, j);
                    // o_depth = frameInfo.m_depth(i, j);
                    auto o_color = frameInfo.m_beauty(i, j);
                    auto o_pos = frameInfo.m_position(i, j);
                    //像素距离参数
                    auto pos_value =
                        SqrDistance(Float3(i, j, 0.0f), Float3(x, y, 0.0f)) /
                                      (2.0f * m_sigmaCoord * m_sigmaCoord);
                    //像素颜色参数
                    auto color_value = SqrDistance(c_color, o_color) /
                                   (2.0f * m_sigmaColor * m_sigmaColor);


                       // 像素法线参数
                    auto d_normal = SafeAcos(Dot(c_normal, o_normal));
                    auto normal_value =
                        d_normal * d_normal / (2.0f * m_sigmaNormal * m_sigmaNormal);

                    //像素坐标参数
                    float d_plane = .0f;
                    if (Length(o_pos - c_pos) > 0.f) {
                        d_plane = Dot(c_normal, Normalize(o_pos - c_pos));
                    }
                   // std::cout << " o_pos " << o_pos << " c_pos " << c_pos << " Dot "<< Normalize(o_pos - c_pos) << std::endl;
                  

                    float plane_value = d_plane * d_plane / (2.0f * m_sigmaPlane * m_sigmaPlane);


                    //  float d_plane = .0f;
                    //if (d_position > 0.f) {
                    //    d_plane = Dot(center_normal, Normalize(postion - center_postion));
                    //}
                    //d_plane *= d_plane;
                    //d_plane /= (2.0f * m_sigmaPlane * m_sigmaPlane);

               
                   


                    float filterValue =
                        exp(-pos_value - color_value - plane_value - normal_value);

                   //  std::cout << pos_value << "+" << color_value << "+" << d_plane << "+" << normal_value << "+" << filterValue <<"\n"<< std::endl;
                    //滤波值
                    filterValues = filterValues + filterValue;
                    //滤波颜色叠加
                    finalColor = finalColor + o_color * filterValue;
                }
            }
          //  std::cout << finalColor << "+" << filterValues << "\n" << std::endl;
            filteredImage(x, y) = finalColor / filterValues;
           
        
        }
    }
   
    return filteredImage;
}

void Denoiser::Init(const FrameInfo &frameInfo, const Buffer2D<Float3> &filteredColor) {
    m_accColor.Copy(filteredColor);
    int height = m_accColor.m_height;
    int width = m_accColor.m_width;
    m_misc = CreateBuffer2D<Float3>(width, height);
    m_valid = CreateBuffer2D<bool>(width, height);
}

void Denoiser::Maintain(const FrameInfo &frameInfo) { m_preFrameInfo = frameInfo; }

Buffer2D<Float3> Denoiser::ProcessFrame(const FrameInfo &frameInfo) {
    // Filter current frame
    Buffer2D<Float3> filteredColor;
    std::cout << "Filter" << std::endl;
    filteredColor = Filter(frameInfo);

    // Reproject previous frame color to current
    if (m_useTemportal) {
        std::cout << "Reprojection" << std::endl;
        Reprojection(frameInfo);
        std::cout << "TemporalAccumulation" << std::endl;
        TemporalAccumulation(filteredColor);
    } else {
        std::cout << "Init" << std::endl;
        Init(frameInfo, filteredColor);
    }

    // Maintain
    Maintain(frameInfo);
    if (!m_useTemportal) {
        m_useTemportal = true;
    }
    return m_accColor;
}
