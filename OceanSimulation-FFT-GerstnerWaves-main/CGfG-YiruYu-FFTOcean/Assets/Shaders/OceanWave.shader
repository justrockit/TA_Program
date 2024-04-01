Shader "FFTOcean/OceanWave"
{
    Properties
    {
        _OceanShallowColor ("Ocean Shallow Color", Color) = (1, 1, 1, 1)
        _OceanDeepColor ("Ocean Deep Color", Color) = (1, 1, 1, 1)
        _BubbleColor ("Bubble Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 256)) = 20
        _FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
        _Displace ("Displace", 2D) = "white" {}
        _Normal ("Normal", 2D) = "white" {}
        _Bubble("Bubble", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {               
                //UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            fixed4 _OceanShallowColor;
            fixed4 _OceanDeepColor;
            fixed4 _BubbleColor;
            fixed4 _Specular;
            float _Gloss;
            fixed _FresnelScale;
            sampler2D _Displace;
            float4 _Displace_ST;
            sampler2D _Normal;
            //float4 _Normal_ST;
            sampler2D _Bubble;
            //float4 _Bubble_ST;

            
            inline half3 SamplerReflectProbe(UNITY_ARGS_TEXCUBE(tex), half3 refDir, half roughness, half4 hdr)
            {
                roughness = roughness * (1.7 - 0.7 * roughness);
                half mip = roughness * 6;
              
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(tex, refDir, mip);
               
                return DecodeHDR(rgbm, hdr);
            }
            

            v2f vert (appdata v)
            {
                v2f o;
              
                o.uv = TRANSFORM_TEX(v.uv, _Displace);
                float4 displace = tex2Dlod(_Displace, float4(o.uv, 0, 0));
                v.pos += float4(displace.xyz, 0);
                o.pos = UnityObjectToClipPos(v.pos);
                o.worldPos = mul(unity_ObjectToWorld, v.pos).xyz;
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // apply fog
               // UNITY_APPLY_FOG(i.fogCoord, col);
                fixed3 normal = UnityObjectToWorldNormal(tex2D(_Normal, i.uv).rgb);
                fixed bubble = tex2D(_Bubble, i.uv).r;

                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 reflectDir = reflect(-viewDir, normal);

                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, 0);
                half3 sky = DecodeHDR(rgbm, unity_SpecCube0_HDR);

                fixed fresnel = saturate(_FresnelScale + (1 - _FresnelScale) * pow(1 - dot(normal, viewDir), 5));

                half facing = saturate(dot(viewDir, normal));
                fixed3 oceanColor = lerp(_OceanShallowColor, _OceanDeepColor, facing);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 bubblesDiffuse = _BubbleColor.rbg * _LightColor0.rgb * saturate(dot(lightDir, normal));
                
                fixed3 oceanDiffuse = oceanColor * _LightColor0.rgb * saturate(dot(lightDir, normal));
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normal, halfDir)), _Gloss);

                fixed3 diffuse = lerp(oceanDiffuse, bubblesDiffuse, bubble);

                fixed3 col = ambient + lerp(diffuse, sky, fresnel) + specular;

                return fixed4(col, 1);
              
            }
            ENDCG
        }
    }
}
