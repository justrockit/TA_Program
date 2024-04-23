Shader "SDF URP Unlit"
{
    Properties
    {
        [NoScaleOffset]_MainTex("SDF", 2D) = "white" {}
        _ContoursManualSmoothing("Contours & Manual Smoothing", Vector) = (0.5, 0.25, 0, 0)
        _ColorA("Color A", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_BaseA("Base A", 2D) = "white" {}
        _ColorB("Color B", Color) = (0, 0, 0, 1)
        [NoScaleOffset]_BaseB("Base B", 2D) = "white" {}
        _Cutoff("Clip Threshold", Range(0, 1)) = 0.01
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        [Toggle]_SUPERSAMPLE("Supersample", Float) = 0
        [Toggle]_AUTOMATIC_SMOOTHING("Automatic Smoothing", Float) = 1
        [Toggle]_TWO_CONTOURS("Two Contours", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 interp0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 interp1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp2 : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.BaseColor = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TANGENT_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 interp0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp2 : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 interp0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp1 : INTERP1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp0 : INTERP0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp0 : INTERP0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 interp0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp1 : INTERP1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 interp0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 interp1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp2 : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.BaseColor = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TANGENT_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 interp0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp2 : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 interp0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp1 : INTERP1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp0 : INTERP0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp0 : INTERP0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        #pragma shader_feature_local _ _SUPERSAMPLE_ON
        #pragma shader_feature_local _ _AUTOMATIC_SMOOTHING_ON
        #pragma shader_feature_local _ _TWO_CONTOURS_ON
        
        #if defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_0
        #elif defined(_SUPERSAMPLE_ON) && defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_1
        #elif defined(_SUPERSAMPLE_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_2
        #elif defined(_SUPERSAMPLE_ON)
            #define KEYWORD_PERMUTATION_3
        #elif defined(_AUTOMATIC_SMOOTHING_ON) && defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_4
        #elif defined(_AUTOMATIC_SMOOTHING_ON)
            #define KEYWORD_PERMUTATION_5
        #elif defined(_TWO_CONTOURS_ON)
            #define KEYWORD_PERMUTATION_6
        #else
            #define KEYWORD_PERMUTATION_7
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float3 interp0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             float4 interp1 : INTERP1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float4 _ContoursManualSmoothing;
        float4 _ColorA;
        float4 _BaseA_TexelSize;
        float4 _ColorB;
        float4 _BaseB_TexelSize;
        float _Cutoff;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_BaseA);
        SAMPLER(sampler_BaseA);
        TEXTURE2D(_BaseB);
        SAMPLER(sampler_BaseB);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_Equal_float(float A, float B, out float Out)
        {
            Out = A == B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float
        {
        };
        
        void SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(UnityTexture2D Texture2D_381420DD, float2 Vector2_7FDA4897, float Boolean_DE0E2434, Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float IN, out float Distance_1)
        {
        float _Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0 = Boolean_DE0E2434;
        UnityTexture2D _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0 = Texture2D_381420DD;
        float2 _Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0 = Vector2_7FDA4897;
        #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
        #else
          float4 _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0), 0);
        #endif
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_R_5 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.r;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_G_6 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.g;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_B_7 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.b;
        float _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8 = _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_RGBA_0.a;
        float4 _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.tex, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.samplerstate, _Property_fb6d17dcaa9ea58aa6a2b3b3c9777ba4_Out_0.GetTransformedUV(_Property_f28a9bf8e192cf86a0de2c8640214ba6_Out_0));
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_R_4 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.r;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_G_5 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.g;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_B_6 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.b;
        float _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7 = _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_RGBA_0.a;
        float _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        Unity_Branch_float(_Property_6d38e7f0fc9be28eaf9ae98b55e14be2_Out_0, _SampleTexture2DLOD_91af89c50842a38cb4cd6707eb961fd6_A_8, _SampleTexture2D_4d8b6ee0a3ea8288810f4ceff3a01e98_A_7, _Branch_93f9be3a0c3091848e935b3382668a50_Out_3);
        Distance_1 = _Branch_93f9be3a0c3091848e935b3382668a50_Out_3;
        }
        
        void Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(float In, out float Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDXY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = abs(ddx(In)) + abs(ddy(In));
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Branch_float2(float Predicate, float2 True, float2 False, out float2 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float
        {
        };
        
        void SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(UnityTexture2D Texture2D_4B7678DB, float2 Vector2_C5F2A8C4, float2 Vector2_1700F402, float Boolean_25F4A713, float Boolean_F1841D7A, Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float IN, out float2 Smoothing_1)
        {
        float _Property_80a31e67dcdcd58389d73b418101c9d7_Out_0 = Boolean_25F4A713;
        UnityTexture2D _Property_73960cc35e302f889df36492c644bebc_Out_0 = Texture2D_4B7678DB;
        float2 _Property_7cd71c9950abce829c716023f4f34e28_Out_0 = Vector2_C5F2A8C4;
        float _Property_c25592165aeef38cbad6dc375fa2701c_Out_0 = Boolean_F1841D7A;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9;
        float _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_73960cc35e302f889df36492c644bebc_Out_0, _Property_7cd71c9950abce829c716023f4f34e28_Out_0, _Property_c25592165aeef38cbad6dc375fa2701c_Out_0, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9, _SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1);
        float _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1;
        Unity_DDXY_569817bd65ca0b85a386557b58c0e596_float(_SDFSampleOnce_8d69b4c250718f8db9ae764d8662d5a9_Distance_1, _DDXY_569817bd65ca0b85a386557b58c0e596_Out_1);
        float2 _Property_72be058c6f9b138b8d676bc78e867db9_Out_0 = Vector2_1700F402;
        float2 _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2;
        Unity_Add_float2((_DDXY_569817bd65ca0b85a386557b58c0e596_Out_1.xx), _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2);
        float2 _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        Unity_Branch_float2(_Property_80a31e67dcdcd58389d73b418101c9d7_Out_0, _Add_227f2048bdbfbb8c973f01c00f1bfe45_Out_2, _Property_72be058c6f9b138b8d676bc78e867db9_Out_0, _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3);
        Smoothing_1 = _Branch_dd1a0f8a5112168d8f824f9989251bbe_Out_3;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Smoothstep_float2(float2 Edge1, float2 Edge2, float2 In, out float2 Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float
        {
        };
        
        void SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(float2 Vector2_E7DD724A, UnityTexture2D Texture2D_F3E730E7, float2 Vector2_8D190DD7, float Boolean_BEA25EA1, float2 Vector2_34159B6E, Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float IN, out float2 Weights_1)
        {
        float2 _Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0 = Vector2_E7DD724A;
        float2 _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0 = Vector2_34159B6E;
        float2 _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2;
        Unity_Subtract_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2);
        float2 _Add_bf01e33e6b29d38d8838880923abfe79_Out_2;
        Unity_Add_float2(_Property_b98d59fef33ce489be5dd3f0fa170ba5_Out_0, _Property_2c908ff9e1bda084a9aeafe1776022e4_Out_0, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2);
        UnityTexture2D _Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0 = Texture2D_F3E730E7;
        float2 _Property_a97dc36081fc778891e5cfec9936c826_Out_0 = Vector2_8D190DD7;
        float _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0 = Boolean_BEA25EA1;
        Bindings_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a;
        float _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1;
        SG_SDFSampleOnce_eac60465e6c2d45e1bdb4670854cbd71_float(_Property_e2e2532d889815809d8d6f1d9bc82f9a_Out_0, _Property_a97dc36081fc778891e5cfec9936c826_Out_0, _Property_c8818e0e305bfc82a8cf08ea98567f8b_Out_0, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a, _SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1);
        float2 _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        Unity_Smoothstep_float2(_Subtract_1a8c1d3827e7da8fb0e10a972419af96_Out_2, _Add_bf01e33e6b29d38d8838880923abfe79_Out_2, (_SDFSampleOnce_5f623fb3e2be778bb9d720ab64e5989a_Distance_1.xx), _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3);
        Weights_1 = _Smoothstep_6328e227f7164881b6e4a0d317e88d2a_Out_3;
        }
        
        void Unity_DDX_0290f945e23d508788908ab13842f30c_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDX' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddx(In);
        }
        
        void Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(float2 In, out float2 Out)
        {
            
                    #if defined(SHADER_STAGE_RAY_TRACING)
                    #error 'DDY' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                    #endif
            Out = ddy(In);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float
        {
        };
        
        void SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(float2 Vector2_F8381FB7, Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float IN, out float2 UVA_1, out float2 UVB_2, out float2 UVC_3, out float2 UVD_4)
        {
        float2 _Property_491260c120a48081be93dc975a7dd5ad_Out_0 = Vector2_F8381FB7;
        float2 _DDX_0290f945e23d508788908ab13842f30c_Out_1;
        Unity_DDX_0290f945e23d508788908ab13842f30c_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDX_0290f945e23d508788908ab13842f30c_Out_1);
        float2 _DDY_71175bfa734a9880b07007e31b32c21b_Out_1;
        Unity_DDY_71175bfa734a9880b07007e31b32c21b_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1);
        float2 _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2;
        Unity_Add_float2(_DDX_0290f945e23d508788908ab13842f30c_Out_1, _DDY_71175bfa734a9880b07007e31b32c21b_Out_1, _Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2);
        float2 _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2;
        Unity_Multiply_float2_float2(_Add_304cbb2325becc8da4aa6e36df5a5fa8_Out_2, float2(0.3535534, 0.3535534), _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2);
        float2 _Add_5306bd323794af8eb76f9521036c847a_Out_2;
        Unity_Add_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Add_5306bd323794af8eb76f9521036c847a_Out_2);
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[0];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2 = _Add_5306bd323794af8eb76f9521036c847a_Out_2[1];
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_B_3 = 0;
        float _Split_49d3a9cd0b5b878e93c620d8bbb875ad_A_4 = 0;
        float2 _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2;
        Unity_Subtract_float2(_Property_491260c120a48081be93dc975a7dd5ad_Out_0, _Multiply_809da01fee4cfe838675bd9fa5a22687_Out_2, _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2);
        float _Split_c65d806353ddf787a01c540d9db3dd3d_R_1 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[0];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_G_2 = _Subtract_fda8ebfef5a8e38fa27f74b99e539b2a_Out_2[1];
        float _Split_c65d806353ddf787a01c540d9db3dd3d_B_3 = 0;
        float _Split_c65d806353ddf787a01c540d9db3dd3d_A_4 = 0;
        float2 _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0 = float2(_Split_49d3a9cd0b5b878e93c620d8bbb875ad_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        float2 _Vector2_337fd89c84680687af77b2173ecc0314_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_49d3a9cd0b5b878e93c620d8bbb875ad_G_2);
        float2 _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0 = float2(_Split_c65d806353ddf787a01c540d9db3dd3d_R_1, _Split_c65d806353ddf787a01c540d9db3dd3d_G_2);
        UVA_1 = _Vector2_6b99d721fe73ed8ebdb517a3c5f982b3_Out_0;
        UVB_2 = _Vector2_0b2359f69bd2858e8c9842b77ad314c8_Out_0;
        UVC_3 = _Vector2_337fd89c84680687af77b2173ecc0314_Out_0;
        UVD_4 = _Vector2_ae2e4e07b3f06c808d210611073c1247_Out_0;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float
        {
        };
        
        void SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(UnityTexture2D Texture2D_DDEBD6BB, float2 Vector2_175A1671, float4 Vector4_ACDEF101, float Boolean_F5F1E333, float Boolean_8FBD007D, float Boolean_ca0189e70a0a42d29fc2a199411f13fd, Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float IN, out float2 Weights_3, out float4 WeightsAB_4, out float4 WeightsCD_5, out float Supersample_6, out float TwoContours_7)
        {
        float4 _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0 = Vector4_ACDEF101;
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_R_1 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[0];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[1];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_B_3 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[2];
        float _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4 = _Property_69f97bee413b3c8b8e0fca93d876c4b0_Out_0[3];
        float2 _Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_R_1, _Split_77497af94580c28d8b0b0a2d9e8c216f_G_2);
        UnityTexture2D _Property_186b6e47186bd7878d0948667e567470_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_59a8a97b33831187956d58faaf2f2cad_Out_0 = Vector2_175A1671;
        float _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0 = Boolean_8FBD007D;
        UnityTexture2D _Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0 = Texture2D_DDEBD6BB;
        float2 _Property_073f3459bebaf4808852dc66e24a3b11_Out_0 = Vector2_175A1671;
        float2 _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0 = float2(_Split_77497af94580c28d8b0b0a2d9e8c216f_B_3, _Split_77497af94580c28d8b0b0a2d9e8c216f_A_4);
        float _Property_e0699f71d12ece868b32b020b242b0c2_Out_0 = Boolean_F5F1E333;
        float _Property_701459c7900e47848c1f29dd2c33a361_Out_0 = Boolean_8FBD007D;
        Bindings_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c;
        float2 _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1;
        SG_SDFSmoothing_a97ff25f6144e4366b7e4bd7204beceb_float(_Property_3ad7cfb53a232a8ca65a939d455a6c04_Out_0, _Property_073f3459bebaf4808852dc66e24a3b11_Out_0, _Vector2_3c27d5701220da8a8e3737953d1f15ac_Out_0, _Property_e0699f71d12ece868b32b020b242b0c2_Out_0, _Property_701459c7900e47848c1f29dd2c33a361_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_dbc590281a12248dabd2ea65768c3b11;
        float2 _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _Property_59a8a97b33831187956d58faaf2f2cad_Out_0, _Property_11f0b036aa665a8daa56ae64f64f5465_Out_0, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_dbc590281a12248dabd2ea65768c3b11, _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1);
        float _Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0 = Boolean_8FBD007D;
        float2 _Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0 = Vector2_175A1671;
        Bindings_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3;
        float2 _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4;
        SG_SDFSupersampleUVs_2d4e8fb4d6a5a464daf9a34e48140036_float(_Property_dc3d9750d9b8db8696a658cb6ff3f7b9_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b;
        float2 _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVA_1, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b, _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1);
        float _Split_adfa6bf7105c938daf804717f961bd3b_R_1 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[0];
        float _Split_adfa6bf7105c938daf804717f961bd3b_G_2 = _SDFWeights_06e2df7072f3ad85b1e4b8932d5c701b_Weights_1[1];
        float _Split_adfa6bf7105c938daf804717f961bd3b_B_3 = 0;
        float _Split_adfa6bf7105c938daf804717f961bd3b_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_24d80466cd409383b133efd936658ea5;
        float2 _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVB_2, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_24d80466cd409383b133efd936658ea5, _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1);
        float _Split_38722b74f54ca98babe00a394e40b33c_R_1 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[0];
        float _Split_38722b74f54ca98babe00a394e40b33c_G_2 = _SDFWeights_24d80466cd409383b133efd936658ea5_Weights_1[1];
        float _Split_38722b74f54ca98babe00a394e40b33c_B_3 = 0;
        float _Split_38722b74f54ca98babe00a394e40b33c_A_4 = 0;
        float4 _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0 = float4(_Split_adfa6bf7105c938daf804717f961bd3b_R_1, _Split_adfa6bf7105c938daf804717f961bd3b_G_2, _Split_38722b74f54ca98babe00a394e40b33c_R_1, _Split_38722b74f54ca98babe00a394e40b33c_G_2);
        float4 _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_4051e60ffcd3f78ca651848df38833a9_Out_0, float4(0, 0, 0, 0), _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3);
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_0ba8e40bc094138eba2e7629d92b532a;
        float2 _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVC_3, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a, _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1);
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_R_1 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[0];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2 = _SDFWeights_0ba8e40bc094138eba2e7629d92b532a_Weights_1[1];
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_B_3 = 0;
        float _Split_43158260dd6bfd80aade5399ae1b0f0a_A_4 = 0;
        Bindings_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float _SDFWeights_de455574c4b1d9889a71648f7c47610c;
        float2 _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1;
        SG_SDFWeights_80497d3ea7fb146b4bff2e848b6435fa_float(_Vector2_9a2cd8d7bf364387bd1b7b3925f8f323_Out_0, _Property_186b6e47186bd7878d0948667e567470_Out_0, _SDFSupersampleUVs_fefc6e20564cab819ea3b655ee07b9b4_UVD_4, 1, _SDFSmoothing_81e66ffe0da9bb89b6421696dff5d58c_Smoothing_1, _SDFWeights_de455574c4b1d9889a71648f7c47610c, _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1);
        float _Split_d09d54379aadc386a77079fe59a617cf_R_1 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[0];
        float _Split_d09d54379aadc386a77079fe59a617cf_G_2 = _SDFWeights_de455574c4b1d9889a71648f7c47610c_Weights_1[1];
        float _Split_d09d54379aadc386a77079fe59a617cf_B_3 = 0;
        float _Split_d09d54379aadc386a77079fe59a617cf_A_4 = 0;
        float4 _Vector4_59addb9634145484a2949ba85509bb9b_Out_0 = float4(_Split_43158260dd6bfd80aade5399ae1b0f0a_R_1, _Split_43158260dd6bfd80aade5399ae1b0f0a_G_2, _Split_d09d54379aadc386a77079fe59a617cf_R_1, _Split_d09d54379aadc386a77079fe59a617cf_G_2);
        float4 _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Unity_Branch_float4(_Property_a8c85a24cd5d419b95bf42557f0aaa60_Out_0, _Vector4_59addb9634145484a2949ba85509bb9b_Out_0, float4(0, 0, 0, 0), _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3);
        float _Property_1edfa85be253411a980d8e04b3add9ab_Out_0 = Boolean_8FBD007D;
        float _Property_8c618623ca584a4aa1c859efe9965736_Out_0 = Boolean_ca0189e70a0a42d29fc2a199411f13fd;
        Weights_3 = _SDFWeights_dbc590281a12248dabd2ea65768c3b11_Weights_1;
        WeightsAB_4 = _Branch_4d3426c60721208aaf798f5d77eedcfd_Out_3;
        WeightsCD_5 = _Branch_6c4ec291ba03d3899a36ed27698e9810_Out_3;
        Supersample_6 = _Property_1edfa85be253411a980d8e04b3add9ab_Out_0;
        TwoContours_7 = _Property_8c618623ca584a4aa1c859efe9965736_Out_0;
        }
        
        void Unity_And_float(float A, float B, out float Out)
        {
            Out = A && B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        struct Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float
        {
        };
        
        void SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(float4 Vector4_5D6F5A8, float4 Vector4_7E437CD2, float Boolean_610647E4, float2 Vector2_A2C6C9B6, Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float IN, out float4 Output_1)
        {
        float _Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0 = Boolean_610647E4;
        float4 _Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0 = Vector4_7E437CD2;
        float4 _Property_42f492ffd09b368f958e0b49defc239d_Out_0 = Vector4_5D6F5A8;
        float2 _Property_94d95a3780c5708ab5201298023a6e27_Out_0 = Vector2_A2C6C9B6;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_R_1 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[0];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_G_2 = _Property_94d95a3780c5708ab5201298023a6e27_Out_0[1];
        float _Split_2403a0a7fddd048583ac07c1f94f797d_B_3 = 0;
        float _Split_2403a0a7fddd048583ac07c1f94f797d_A_4 = 0;
        float4 _Lerp_8478baccf780ac869637030996a5aaad_Out_3;
        Unity_Lerp_float4(_Property_d4b037a6ffa60b88a637c1e5b0826ebf_Out_0, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, (_Split_2403a0a7fddd048583ac07c1f94f797d_R_1.xxxx), _Lerp_8478baccf780ac869637030996a5aaad_Out_3);
        float4 _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        Unity_Branch_float4(_Property_8a59d1366b249c8e9386d7bfdc650ce3_Out_0, _Lerp_8478baccf780ac869637030996a5aaad_Out_3, _Property_42f492ffd09b368f958e0b49defc239d_Out_0, _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3);
        Output_1 = _Branch_62ea03bcbc86db82918a81dda6ad183b_Out_3;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        struct Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float
        {
        };
        
        void SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(float4 Vector4_493F9091, float4 Vector4_D656C1F4, float2 Vector2_AA670347, float4 Vector4_3C643EA0, float4 Vector4_9F0AE7B7, float Boolean_44982BDC, float Boolean_98A8FEA8, Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float IN, out float4 Output_1)
        {
        float _Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0 = Boolean_44982BDC;
        float _Property_1e153929737f868083c42ecdbbad2235_Out_0 = Boolean_98A8FEA8;
        float _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2;
        Unity_And_float(_Property_308c9c92eadf5389a7264cf0bbeacc48_Out_0, _Property_1e153929737f868083c42ecdbbad2235_Out_0, _And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2);
        float4 _Property_f7439b842fd399818ae6367106ac3ba5_Out_0 = Vector4_493F9091;
        float4 _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0 = Vector4_D656C1F4;
        float _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0 = Boolean_98A8FEA8;
        float2 _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0 = Vector2_AA670347;
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9;
        float4 _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_f7439b842fd399818ae6367106ac3ba5_Out_0, _Property_d1a255c446f4e78eaf30c344c3cdd322_Out_0, _Property_1fa09d486814af80ae66b6c5ebc243e5_Out_0, _Property_b6f525b0282c1c89bce5b9342fc3173d_Out_0, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1);
        float4 _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2;
        Unity_Add_float4(_SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2);
        float4 _Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0 = Vector4_493F9091;
        float4 _Property_0042c36823e5438baf06f192296566f9_Out_0 = Vector4_D656C1F4;
        float _Property_44196fb43719648e9e3ed95a70a39434_Out_0 = Boolean_98A8FEA8;
        float4 _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0 = Vector4_3C643EA0;
        float _Split_d6412a1ea869358784ced1028ca9e5cb_R_1 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[0];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_G_2 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[1];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_B_3 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[2];
        float _Split_d6412a1ea869358784ced1028ca9e5cb_A_4 = _Property_c0ef0e0beb0fd5849a4177fc1cff6a8f_Out_0[3];
        float2 _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_R_1, _Split_d6412a1ea869358784ced1028ca9e5cb_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008;
        float4 _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_bc5d54d46ff4738f91cff409945489e7_Out_0, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008, _SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1);
        float2 _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0 = float2(_Split_d6412a1ea869358784ced1028ca9e5cb_B_3, _Split_d6412a1ea869358784ced1028ca9e5cb_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05;
        float4 _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_1bb3d6e1227e9d8aa0eaea765fb6cca2_Out_0, _Property_0042c36823e5438baf06f192296566f9_Out_0, _Property_44196fb43719648e9e3ed95a70a39434_Out_0, _Vector2_d516fea1ebbd968fae353f06b7841b34_Out_0, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1);
        float4 _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2;
        Unity_Add_float4(_SDFBlendOnce_1b063e45c7f6a08db2ff288197651008_Output_1, _SDFBlendOnce_efad20cabc3e298a8559198a3b786d05_Output_1, _Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2);
        float4 _Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0 = Vector4_493F9091;
        float4 _Property_33577a0508d69184b1d77842895fc45e_Out_0 = Vector4_D656C1F4;
        float _Property_65d2073e70f30088b1157631cbb36cee_Out_0 = Boolean_98A8FEA8;
        float4 _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0 = Vector4_9F0AE7B7;
        float _Split_45f661e2148a708f81b4606bd2c88097_R_1 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[0];
        float _Split_45f661e2148a708f81b4606bd2c88097_G_2 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[1];
        float _Split_45f661e2148a708f81b4606bd2c88097_B_3 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[2];
        float _Split_45f661e2148a708f81b4606bd2c88097_A_4 = _Property_8ead6ea8d25ba68fa3a35d7849f55636_Out_0[3];
        float2 _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_R_1, _Split_45f661e2148a708f81b4606bd2c88097_G_2);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a;
        float4 _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_af14a7d083f74989af3e29c57eae775c_Out_0, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a, _SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1);
        float2 _Vector2_dc709c910a76968691591f7dff43e37f_Out_0 = float2(_Split_45f661e2148a708f81b4606bd2c88097_B_3, _Split_45f661e2148a708f81b4606bd2c88097_A_4);
        Bindings_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f;
        float4 _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1;
        SG_SDFBlendOnce_1b1ebaee69e174d04a023e746c1fcda1_float(_Property_7471222a03f3528aa0cab6b80e5f81bb_Out_0, _Property_33577a0508d69184b1d77842895fc45e_Out_0, _Property_65d2073e70f30088b1157631cbb36cee_Out_0, _Vector2_dc709c910a76968691591f7dff43e37f_Out_0, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1);
        float4 _Add_df12c557acfc4685b1573a09d58057de_Out_2;
        Unity_Add_float4(_SDFBlendOnce_e25d8e73d6be128f8dc2bfedab3daf5a_Output_1, _SDFBlendOnce_d44f09af18f99a80a5b95b68b7fc8e0f_Output_1, _Add_df12c557acfc4685b1573a09d58057de_Out_2);
        float4 _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2;
        Unity_Add_float4(_Add_c99ab06fd6c35984a065dbb9e6d9b320_Out_2, _Add_df12c557acfc4685b1573a09d58057de_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2);
        float4 _Add_038408b6f4348d87868c46779b1af825_Out_2;
        Unity_Add_float4(_Add_4ab9ab50fdf6eb8c9d95c190361239e3_Out_2, _Add_99ba8ce8c72183868dfea6b864a4cf46_Out_2, _Add_038408b6f4348d87868c46779b1af825_Out_2);
        float _Divide_62e56498f3b75d89a55a9382f239880f_Out_2;
        Unity_Divide_float(1, 6, _Divide_62e56498f3b75d89a55a9382f239880f_Out_2);
        float4 _Multiply_254695846bf15883a4784ac22b912709_Out_2;
        Unity_Multiply_float4_float4(_Add_038408b6f4348d87868c46779b1af825_Out_2, (_Divide_62e56498f3b75d89a55a9382f239880f_Out_2.xxxx), _Multiply_254695846bf15883a4784ac22b912709_Out_2);
        float4 _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        Unity_Branch_float4(_And_17c3f4b8935c708ab538e47b6c2ee92a_Out_2, _Multiply_254695846bf15883a4784ac22b912709_Out_2, _SDFBlendOnce_07598c5f5ab63681b38719067934b7c9_Output_1, _Branch_655ed9f3591b428e96d11fd896465168_Out_3);
        Output_1 = _Branch_655ed9f3591b428e96d11fd896465168_Out_3;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        struct Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float
        {
        };
        
        void SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(float2 Vector2_D70D3355, float4 Vector4_69DCA0F9, float4 Vector4_258F8364, float Boolean_585CC389, float Boolean_5B8AFCA4, Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float IN, out float Weight_1)
        {
        float _Property_31e716792150708c87b440d7bac87b7b_Out_0 = Boolean_585CC389;
        float _Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0 = Boolean_5B8AFCA4;
        float2 _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0 = Vector2_D70D3355;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_R_1 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[0];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_G_2 = _Property_aca7daa52cbb3c8cbbe0df2fc8bc7dd3_Out_0[1];
        float _Split_9b40c545c207a080b18f2c297e7f45d6_B_3 = 0;
        float _Split_9b40c545c207a080b18f2c297e7f45d6_A_4 = 0;
        float _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3;
        Unity_Branch_float(_Property_086e3e4df52830878cb6d98f25ff6ffe_Out_0, _Split_9b40c545c207a080b18f2c297e7f45d6_G_2, _Split_9b40c545c207a080b18f2c297e7f45d6_R_1, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3);
        float _Add_05ecebbae6d91483878c92ab79263090_Out_2;
        Unity_Add_float(_Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Add_05ecebbae6d91483878c92ab79263090_Out_2);
        float _Property_03914fa3519e4082a642fe87d831034d_Out_0 = Boolean_5B8AFCA4;
        float4 _Property_a4238c69c0c0058d84ffc8144903502b_Out_0 = Vector4_69DCA0F9;
        float _Split_497383462fa4b18686f71045ac40546f_R_1 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[0];
        float _Split_497383462fa4b18686f71045ac40546f_G_2 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[1];
        float _Split_497383462fa4b18686f71045ac40546f_B_3 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[2];
        float _Split_497383462fa4b18686f71045ac40546f_A_4 = _Property_a4238c69c0c0058d84ffc8144903502b_Out_0[3];
        float _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_G_2, _Split_497383462fa4b18686f71045ac40546f_R_1, _Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3);
        float _Branch_73e089673091cd8d8b82c1290642b003_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_497383462fa4b18686f71045ac40546f_A_4, _Split_497383462fa4b18686f71045ac40546f_B_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3);
        float _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2;
        Unity_Add_float(_Branch_ad0797ede46ecc84b70b39bc07e1e5d3_Out_3, _Branch_73e089673091cd8d8b82c1290642b003_Out_3, _Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2);
        float4 _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0 = Vector4_258F8364;
        float _Split_baa0a6b2b85b298993275602ed4c803d_R_1 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[0];
        float _Split_baa0a6b2b85b298993275602ed4c803d_G_2 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[1];
        float _Split_baa0a6b2b85b298993275602ed4c803d_B_3 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[2];
        float _Split_baa0a6b2b85b298993275602ed4c803d_A_4 = _Property_c5236a8c001eec8698e4a93235aa9acb_Out_0[3];
        float _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_G_2, _Split_baa0a6b2b85b298993275602ed4c803d_R_1, _Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3);
        float _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3;
        Unity_Branch_float(_Property_03914fa3519e4082a642fe87d831034d_Out_0, _Split_baa0a6b2b85b298993275602ed4c803d_A_4, _Split_baa0a6b2b85b298993275602ed4c803d_B_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3);
        float _Add_9d739f822f19cd8584924a980188eda9_Out_2;
        Unity_Add_float(_Branch_9d3f9497c8a7aa8eaed5e24ff0ce78c3_Out_3, _Branch_78312829c2c50480b0f7400bfa79ac64_Out_3, _Add_9d739f822f19cd8584924a980188eda9_Out_2);
        float _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2;
        Unity_Add_float(_Add_3a922bfe97ba448e8930ed73b3b304d6_Out_2, _Add_9d739f822f19cd8584924a980188eda9_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2);
        float _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2;
        Unity_Add_float(_Add_05ecebbae6d91483878c92ab79263090_Out_2, _Add_2e3d4579f275ed81a23876d0e0677f7c_Out_2, _Add_e010e0c417e727839bb8a5f6ad78274b_Out_2);
        float _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2;
        Unity_Divide_float(1, 6, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2);
        float _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2;
        Unity_Multiply_float_float(_Add_e010e0c417e727839bb8a5f6ad78274b_Out_2, _Divide_0bad3c8f44123c8bbb7cff71cc3912b6_Out_2, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2);
        float _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        Unity_Branch_float(_Property_31e716792150708c87b440d7bac87b7b_Out_0, _Multiply_bdc77eb7230fe8869b2ac84c3492e11b_Out_2, _Branch_e7bd74dd9c480288a8e6346fafc09748_Out_3, _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3);
        Weight_1 = _Branch_7356ec5da873cc89b763a32bc5c87f4c_Out_3;
        }
        
        struct Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float
        {
        };
        
        void SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(float4 Vector4_5010D68C, float Vector1_DC6277FA, Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float IN, out float3 Color_3, out float Alpha_2)
        {
        float4 _Property_961b5821dac94384a11e3d26e790ae3e_Out_0 = Vector4_5010D68C;
        float _Split_3ad551ce9445a08591ca8844129f718b_R_1 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[0];
        float _Split_3ad551ce9445a08591ca8844129f718b_G_2 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[1];
        float _Split_3ad551ce9445a08591ca8844129f718b_B_3 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[2];
        float _Split_3ad551ce9445a08591ca8844129f718b_A_4 = _Property_961b5821dac94384a11e3d26e790ae3e_Out_0[3];
        float _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0 = Vector1_DC6277FA;
        float _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        Unity_Multiply_float_float(_Split_3ad551ce9445a08591ca8844129f718b_A_4, _Property_f3c21b288130298ab9d25794a02bc5b9_Out_0, _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2);
        Color_3 = (_Property_961b5821dac94384a11e3d26e790ae3e_Out_0.xyz);
        Alpha_2 = _Multiply_1a4c2ba9bedd0f868329769e973c0ae6_Out_2;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_a8219096f7ce21829d43ce3fc2675608_Out_0 = UnityBuildTexture2DStructNoScale(_BaseA);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_a8219096f7ce21829d43ce3fc2675608_Out_0.tex, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.samplerstate, _Property_a8219096f7ce21829d43ce3fc2675608_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_R_4 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.r;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_G_5 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.g;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_B_6 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.b;
            float _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_A_7 = _SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_f069d3d416755c86be92d2e39a679463_Out_0 = _ColorA;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_52b91c5022ad8e8c8eda878d356ed29f_RGBA_0, _Property_f069d3d416755c86be92d2e39a679463_Out_0, _Multiply_724870bdd515278c9b9e90d47fb383af_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_91e7349a99556d8782d8e391512d36ed_Out_0 = UnityBuildTexture2DStructNoScale(_BaseB);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0 = SAMPLE_TEXTURE2D(_Property_91e7349a99556d8782d8e391512d36ed_Out_0.tex, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.samplerstate, _Property_91e7349a99556d8782d8e391512d36ed_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_R_4 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.r;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_G_5 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.g;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_B_6 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.b;
            float _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_A_7 = _SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0 = _ColorB;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_aa526119c999da8f91c26ebbfe2397b1_RGBA_0, _Property_7c5205298b4bb582855dcb54f63d79cf_Out_0, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            UnityTexture2D _Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0 = IN.uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float4 _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0 = _ContoursManualSmoothing;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_AUTOMATIC_SMOOTHING_ON)
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 1;
            #else
            float _AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_11f640065dcca48da3265498367d0ae4_Out_2;
            Unity_Comparison_Equal_float(_AutomaticSmoothing_27491a2e210c4c8eb6bdf2e070f162ec_Out_0, 1, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_SUPERSAMPLE_ON)
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 1;
            #else
            float _Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2;
            Unity_Comparison_Equal_float(_Supersample_cbd39d9f096fdb86bc7b6166ff2f13a2_Out_0, 1, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFSample_0aca36758d36b44db8274e48cea30195_float _SDFSample_3248df8779a21388a4e961c8b0d70599;
            float2 _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4;
            float4 _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6;
            float _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7;
            SG_SDFSample_0aca36758d36b44db8274e48cea30195_float(_Property_e3c5707663da8d8e9b1e3d44f92ee49c_Out_0, (_UV_549333e2f3ebee80920a0a2aeb7f1f64_Out_0.xy), _Property_8d238d2af59d8a8ebffd14d5050c8d72_Out_0, _Comparison_11f640065dcca48da3265498367d0ae4_Out_2, _Comparison_33ff3a1785633180a3c8dff2882396b4_Out_2, 0, _SDFSample_3248df8779a21388a4e961c8b0d70599, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _SDFSample_3248df8779a21388a4e961c8b0d70599_TwoContours_7);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #if defined(_TWO_CONTOURS_ON)
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 1;
            #else
            float _TwoContours_e1bdea9440bd158da899652a9f070055_Out_0 = 0;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2;
            Unity_Comparison_Equal_float(_TwoContours_e1bdea9440bd158da899652a9f070055_Out_0, 1, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3;
            float4 _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1;
            SG_SDFBlend_2477f7fb2a4f2492a850f76bdab96939_float(_Multiply_724870bdd515278c9b9e90d47fb383af_Out_2, _Multiply_c41ecfc078f4b48f9172b2c094157a01_Out_2, _SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3, _SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda;
            float _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1;
            SG_SDFOuterWeight_ee91197363430436da3ed5afb63d3195_float(_SDFSample_3248df8779a21388a4e961c8b0d70599_Weights_3, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsAB_4, _SDFSample_3248df8779a21388a4e961c8b0d70599_WeightsCD_5, _SDFSample_3248df8779a21388a4e961c8b0d70599_Supersample_6, _Comparison_21fa8eadda77d28dabaf72896124053b_Out_2, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            Bindings_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2;
            float3 _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3;
            float _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            SG_SDFColorAlpha_489d5493d653545078ca7a8dba14dd90_float(_SDFBlend_001ad7e4a24e4187ae085712c62cb9e3_Output_1, _SDFOuterWeight_a74c994ff42fee859b600b293ed13eda_Weight_1, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Color_3, _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            float _Property_ad413585b130598a9651af9a358c83ac_Out_0 = _Cutoff;
            #endif
            surface.Alpha = _SDFColorAlpha_aa7ff044689cb68bb5f87e1886f943d2_Alpha_2;
            surface.AlphaClipThreshold = _Property_ad413585b130598a9651af9a358c83ac_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}