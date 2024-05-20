#include "denoiser.h"

Denoiser::Denoiser() : m_useTemportal(false) {}

void Denoiser::Reprojection(const FrameInfo &frameInfo) {
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
            // TODO: Joint bilateral filter
            //ÁªºÏË«±ßÂË²¨
            //¾ØÐÎ
            int max_x = std::min(width - 1, x + kernelRadius);
            int max_y = std::min(height - 1, y + kernelRadius);
            int min_x = std::max(0, x - kernelRadius);
            int min_y = std::min(0, y - kernelRadius);

            Float3 c_normal = frameInfo.m_normal(x, y);
            Float3 c_pos = frameInfo.m_position(x, y);
            Float3 c_depth = frameInfo.m_depth(x, y);
            Float3 c_color = frameInfo.m_beauty(x, y);

    /*            float m_alpha = 0.2f;
            float m_sigmaPlane = 0.1f;
            float m_sigmaColor = 0.6f;
            float m_sigmaNormal = 0.1f;
            float m_sigmaCoord = 32.0f;
            float m_colorBoxK = 1.0f;*/

            for (size_t i = min_x; i < max_x; i++) {
                for (size_t j = min_y; j < max_y; j++) {

                    Float3 o_normal = frameInfo.m_normal(i,j);
                    Float3 o_depth = frameInfo.m_depth(i, j);
                    Float3 o_color = frameInfo.m_beauty(i, j);

                    o_normal = () / (2 * m_sigmaPlane * m_sigmaPlane);



                }
            }



            filteredImage(x, y) = frameInfo.m_beauty(x, y);
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
    filteredColor = Filter(frameInfo);

    // Reproject previous frame color to current
    if (m_useTemportal) {
        Reprojection(frameInfo);
        TemporalAccumulation(filteredColor);
    } else {
        Init(frameInfo, filteredColor);
    }

    // Maintain
    Maintain(frameInfo);
    if (!m_useTemportal) {
        m_useTemportal = true;
    }
    return m_accColor;
}
