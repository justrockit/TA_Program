Shader "FFTOcean/InfiniteView"
{
    Properties
    {
        //_MainTex("Main Texture", 2D) = "white" {}
        _Opacity("Opacity", Range(0, 1)) = 1
        _ReflectFog("Reflect Fog", Color) = (1, 1, 1, 1)
        _RefractFog("Refract Fog", Color) = (1, 1, 1, 1)
        _RefractStrength("Refract Strength", Float) = 1
        
        _OceanShallowColor("Ocean Shallow Color", Color) = (1, 1, 1, 1)
        _OceanDeepColor("Ocean Deep Color", Color) = (1, 1, 1, 1)
        _FresnelScale("Fresnel Scale", Range(0, 1)) = 0.5
        _WaveScale("Wave Scale", Float) = 1
        _WaveSpeed("Wave Speed", Float) = 1
        _WaveStrength("Wave Strength", Float) = 1
        _WaveAtten("Wave Attenuation", Float) = 2.3
        /*
        _BubbleColor("Bubble Color", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8, 256)) = 20
        
        _Reflection("Reflection Texture", Cube) = "_Skybox" {}
        _Displace("Displace", 2D) = "white" {}
        _Normal("Normal", 2D) = "white" {}
        _Bubble("Bubble", 2D) = "white" {}
        
        _DiffuseColor("Diffuse Color", Color) = (1, 1, 1, 1)
        */
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase"}
        LOD 100
       // Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;          
                float4 vertex : SV_POSITION;
                float4 screenWorldPos : TEXCOORD1;
                float3 ray : TEXCOORD2;
            };

            float4x4 _ViewProjectionInverseMatrix;     //projection to world space transform matrix
            float3 _CameraPos;
            float3 _CameraClipPlane;      //(near, far, near - far) in world space
            float _OceanHeight;
            float _NearOceanHeight;
            fixed4 _OceanShallowColor;
            fixed4 _OceanDeepColor;
            fixed4 _BubbleColor;
            fixed4 _Specular;
            fixed4 _ReflectFog;
            fixed4 _RefractFog;
            fixed4 _DiffuseColor;
            float _RefractStrength;      
            float _Opacity;
            fixed _FresnelScale;

            float _WaveScale;
            float _WaveSpeed;
            float _WaveStrength;
            float _WaveAtten;
            
            sampler2D _ScreenImage;
            float4 _ScreenImage_TexelSize;
            sampler2D _OceanImage;
            float4 _OceanImage_TexelSize;
            sampler2D _CameraDepthTexture;
            sampler2D _OceanDepthTex;
            sampler2D _ScreenSpaceShadow;
            samplerCUBE _Reflection;
            sampler2D _Displace;
            half4 _Displace_TexelSize;
            float4 _Displace_ST;
            sampler2D _Normal;
            half4 _Normal_TexelSize;
            sampler2D _Bubble;
          

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                //o.uv = TRANSFORM_TEX(v.uv, _Displace);
                //float4 displace = tex2Dlod(_MainTex, float4(o.uv, 0, 0)); 
                //displace += tex2Dlod(_Displace, float4(o.uv + _Displace_TexelSize.xy, 0, 0));
                //v.vertex += float4(displace.xyz, 0);
                o.vertex = UnityObjectToClipPos(v.vertex);
    
                //float4 p = float4(o.vertex.x, o.vertex.y, -1, 1);
               // p *= _CameraClipPlane.x;
                //o.screenWorldPos = mul(_ViewProjectionInverseMatrix, p);
                o.screenWorldPos = ComputeScreenPos(o.vertex);
                o.ray = o.screenWorldPos - _CameraPos;
                o.ray = normalize(o.ray) * length(o.ray) / _CameraClipPlane.x;
                
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            inline float3 getWorldPos(float depth, float3 ray) {
                return _CameraPos + LinearEyeDepth(depth) * ray.xyz;
            }

            inline float3 waveNormal(float2 pos, float dist)
            {
                
                float omega[4] = { 37, 17, 23, 16 };
                float phi[4] = { 7, 5, 3, 11 };
                float2 dir[4] = {
                    float2(1, 0),
                    float2(1, 0.1),
                    float2(1, 0.3),
                    float2(1, 0.57)
                };
                float t = _Time.y * _WaveSpeed;
                float3 normal = 0;
                for (int i = 0; i < 4; i++)
                {
                    omega[i] *= _WaveScale;
                    normal += float3(
                        omega[i] * dir[i].x * 1 * cos(dot(dir[i], pos) * omega[i] + t * phi[i]),
                        1,
                        omega[i] * dir[i].y * 1 * cos(dot(dir[i], pos) * omega[i] + t * phi[i])
                        );
                }
                normal.xz = normal.xz * _WaveStrength * exp(-1 / _WaveAtten * dist);

                return normalize(normal);
            }
            
            inline float3 infiniteView(float3 worldPos, float3 ray, float t, float2 fuv) {
                float3 groundPos = _CameraPos + ray * t;
                float3 viewDir = normalize(_CameraPos - groundPos);
                float2 uv = groundPos.xz;
         
                //fixed3 normal = UnityObjectToWorldNormal(tex2D(_Normal, uv + _Normal_TexelSize.xy).rgb);
                fixed3 normal = waveNormal(uv, length(groundPos - _CameraPos));
               // fixed bubble = tex2D(_Bubble, uv).r;

                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(groundPos));
                viewDir = normalize(UnityWorldSpaceViewDir(groundPos));
                fixed3 reflectDir = reflect(-viewDir, normal);
     
               // half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, 0);
               // half3 reflection = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                half3 reflection = _ReflectFog.rgb * _ReflectFog.a;  // +reflection.rgb * (1 - _ReflectFog.a);
                
                //refraction
                
                float depth = length(worldPos - groundPos);
                float density = 1 / 1 - pow(_RefractFog.a, 0.5f) + 0.00001f;
                float f = 1 - exp(-pow(density * abs(depth), 1));
                float3 color = tex2D(_OceanImage, fuv + normal.xz * _RefractStrength * _OceanImage_TexelSize.xy);
                color = _RefractFog.rgb * f + color * (1 - f);
                
                /*
                half facing = saturate(dot(-viewDir, normal));
                fixed3 oceanColor = lerp(_OceanShallowColor, _OceanDeepColor, facing);
                
                fixed3 oceanDiffuse = oceanColor * _LightColor0.rgb * saturate(dot(lightDir, normal));                
                float3 color = tex2D(_ScreenImage, fuv + normal.xz * _ScreenImage_TexelSize.xy);
                color = oceanDiffuse + color;
                */

                // Shadow
                float shadow = tex2D(_ScreenSpaceShadow, fuv);

                fixed fresnel = saturate(_FresnelScale + (1 - _FresnelScale) * pow(1 - dot(normal, viewDir), 5));
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                // fixed3 bubblesDiffuse = _BubbleColor.rbg * _LightColor0.rgb * saturate(dot(lightDir, normal));

                // fixed3 oceanDiffuse = oceanColor * _LightColor0.rgb * saturate(dot(lightDir, normal));
               // fixed3 halfDir = normalize(lightDir + viewDir);
               // fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normal, halfDir)), _Gloss);

                 // fixed3 diffuse = lerp(oceanDiffuse, bubblesDiffuse, bubble);
                  // Diffuse
                float3 diffuse = _OceanDeepColor.rgb * saturate(dot(normal, lightDir)) * _LightColor0.rgb;

                //color = ambient + lerp(diffuse, reflection, fresnel) + reflection * fresnel + (1 - fresnel) * (diffuse);
                color = reflection * fresnel + (1 - fresnel) * ((diffuse + color) * shadow) + ambient;  //
                return color;
            }
            

            inline fixed overlay(fixed basePixel, fixed blendPixel, float baseDepth, float blendDepth) {
                /*
                if (blendDepth == 0 && baseDepth > 0) {
                    return basePixel;
                }
                else {
                    return blendPixel;
                }
               
                if (baseDepth < blendDepth || blendDepth == 0) {
                    return basePixel;
                }
                else {
                    return blendPixel;
                }*/
              
               //&& blendPixel > 0.0f
                /*
                if (blendDepth > 0.0f && blendDepth <= 1.0f && (blendPixel > 0.0f)) {
                    return blendPixel;
                }
                else {
                    return basePixel;
                }*/
                
                if (basePixel < 0.5f) {
                    return 2.0 * basePixel * blendPixel;
                }
                else {
                    return 1.0 - 2.0 * (1.0 - basePixel) * (1.0 - blendPixel);
                       
                }
                
            }

            inline fixed overlay2(fixed basePixel, fixed blendPixel) {
                fixed finalPixel = basePixel >= blendPixel ? basePixel : blendPixel;
                return finalPixel;
            }

            inline fixed overlay3(fixed basePixel, fixed blendPixel) {
                if (basePixel < 0.5f) {
                    return 2.0 * blendPixel;
                }
                else {
                    return 1.0 - 2.0 * (1.0 - basePixel) * (1.0 - blendPixel);
                }

            }

            

            fixed4 frag(v2f i) : SV_Target
            {

                //float depth = tex2D(_CameraDepthTexture, i.uv).r;
               float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenWorldPos)).r;
                 half depth01 = Linear01Depth(depth);
                // half depthEye = LinearEyeDepth(depth);
                 half oceanDepth = tex2D(_OceanDepthTex, i.uv).r;
                 float3 worldPos = getWorldPos(depth, i.ray);
                 float3 ray = worldPos - _CameraPos;
            // + _Displace_TexelSize.xy  + _Normal_TexelSize.xy
                // float height = _OceanHeight + tex2D(_Displace, i.uv + _Displace_TexelSize.xy).g;
                 float t = (_OceanHeight - _CameraPos.y) / ray.y;

                 fixed4 oceanTex = tex2D(_OceanImage, i.uv);
                 fixed4 tempOceanTex = oceanTex;
                 // (depth01 >= 1 && t > 0)

                 if (_CameraPos.y <= _OceanHeight) {

                     oceanTex.r = overlay3(oceanTex.r, _OceanDeepColor.r);
                     oceanTex.g = overlay3(oceanTex.g, _OceanDeepColor.g);
                     oceanTex.b = overlay3(oceanTex.b, _OceanDeepColor.b);
                     fixed4 screenTex = tex2D(_ScreenImage, i.uv);

                     fixed4 color = screenTex;
                     color.r = overlay3(screenTex.r, oceanTex.r);
                     color.g = overlay3(screenTex.g, oceanTex.g);
                     color.b = overlay3(screenTex.b, oceanTex.b);
                     color.a = overlay3(screenTex.a, oceanTex.a);
                    // color.a = screenTex.a;
                     color = lerp(screenTex, color, _Opacity);
                     return color;
                 }
                 else if ((t >= 1 && t < abs(_OceanHeight - _CameraPos.y))) {
                     fixed3 farOceanColor = infiniteView(worldPos, ray, t, i.uv);
                     tempOceanTex = fixed4(farOceanColor, 1.0f);
                     //oceanTex += tempOceanTex * 0.1f;
                     
                     oceanTex.r = overlay3(oceanTex.r, tempOceanTex.r * 0.4f);
                     oceanTex.g = overlay3(oceanTex.g, tempOceanTex.g * 0.4f);
                     oceanTex.b = overlay3(oceanTex.b, tempOceanTex.b * 0.4f);
                    
                 }
                
                

                fixed4 screenTex = tex2D(_ScreenImage, i.uv);
                
                fixed4 color = screenTex;
                
                color.r = overlay(screenTex.r, oceanTex.r, depth01, oceanDepth);
                color.g = overlay(screenTex.g, oceanTex.g, depth01, oceanDepth);
                color.b = overlay(screenTex.b, oceanTex.b, depth01, oceanDepth);
                //color.a = overlay(screenTex.a, oceanTex.a);
                color.a = screenTex.a;
                
                /*
                if (depth01 < oceanDepth) {
                    color = screenTex;
                }
                else {
                    color = oceanTex;
                }*/
                color = lerp(screenTex, color, _Opacity);
                return color;

            }
            ENDCG
        }
    }
}
