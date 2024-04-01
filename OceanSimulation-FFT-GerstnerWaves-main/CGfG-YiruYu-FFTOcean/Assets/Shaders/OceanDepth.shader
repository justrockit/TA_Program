Shader "FFTOcean/OceanDepth"
{
    Properties
    {
        
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
          

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                
            };

            struct v2f
            {
               // float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

           
            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
               
                float depthV = Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)).r);
                half4 depthTex;
                depthTex.r = depthV;
                depthTex.b = depthV;
                depthTex.g = depthV;
                depthTex.a = 1;

                return depthTex;
            }
            ENDCG
        }
    }
}
