#ifdef GL_ES
precision highp float;
#endif

uniform vec3 uLightDir;
uniform vec3 uCameraPos;
uniform vec3 uLightRadiance;
uniform sampler2D uGDiffuse;
uniform sampler2D uGDepth;
uniform sampler2D uGNormalWorld;
uniform sampler2D uGShadow;
uniform sampler2D uGPosWorld;

varying mat4 vWorldToScreen;
varying highp vec4 vPosWorld;

#define M_PI 3.1415926535897932384626433832795
#define TWO_PI 6.283185307
#define INV_PI 0.31830988618//pai的倒数
#define INV_TWO_PI 0.15915494309

float Rand1(inout float p) {
  p = fract(p * .1031);
  p *= p + 33.33;
  p *= p + p;
  return fract(p);
}

vec2 Rand2(inout float p) {
  return vec2(Rand1(p), Rand1(p));
}

float InitRand(vec2 uv) {
	vec3 p3  = fract(vec3(uv.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

vec3 SampleHemisphereUniform(inout float s, out float pdf) {
  vec2 uv = Rand2(s);
  float z = uv.x;
  float phi = uv.y * TWO_PI;
  float sinTheta = sqrt(1.0 - z*z);
  vec3 dir = vec3(sinTheta * cos(phi), sinTheta * sin(phi), z);
  pdf = INV_TWO_PI;
  return dir;
}

vec3 SampleHemisphereCos(inout float s, out float pdf) {
  vec2 uv = Rand2(s);
  float z = sqrt(1.0 - uv.x);
  float phi = uv.y * TWO_PI;
  float sinTheta = sqrt(uv.x);
  vec3 dir = vec3(sinTheta * cos(phi), sinTheta * sin(phi), z);
  pdf = z * INV_PI;
  return dir;
}

void LocalBasis(vec3 n, out vec3 b1, out vec3 b2) {
  float sign_ = sign(n.z);
  if (n.z == 0.0) {
    sign_ = 1.0;
  }
  float a = -1.0 / (sign_ + n.z);
  float b = n.x * n.y * a;
  b1 = vec3(1.0 + sign_ * n.x * n.x * a, sign_ * b, -sign_ * n.x);
  b2 = vec3(b, sign_ + n.y * n.y * a, -n.y);
}

vec4 Project(vec4 a) {
  return a / a.w;
}

float GetDepth(vec3 posWorld) {
  float depth = (vWorldToScreen * vec4(posWorld, 1.0)).w;
  return depth;
}

/*
 * Transform point from world space to screen space([0, 1] x [0, 1])
 *
 */
vec2 GetScreenCoordinate(vec3 posWorld) {
  vec2 uv = Project(vWorldToScreen * vec4(posWorld, 1.0)).xy * 0.5 + 0.5;
  return uv;
}

float GetGBufferDepth(vec2 uv) {
  float depth = texture2D(uGDepth, uv).x;
  if (depth < 1e-2) {
    depth = 1000.0;
  }
  return depth;
}

vec3 GetGBufferNormalWorld(vec2 uv) {
  vec3 normal = texture2D(uGNormalWorld, uv).xyz;
  return normal;
}

vec3 GetGBufferPosWorld(vec2 uv) {
  vec3 posWorld = texture2D(uGPosWorld, uv).xyz;
  return posWorld;
}

float GetGBufferuShadow(vec2 uv) {
  float visibility = texture2D(uGShadow, uv).x;
  return visibility;
}

vec3 GetGBufferDiffuse(vec2 uv) {
  vec3 diffuse = texture2D(uGDiffuse, uv).xyz;
  diffuse = pow(diffuse, vec3(2.2));
  return diffuse;
}

/*
 * Evaluate diffuse bsdf value.
 *
 * wi, wo are all in world space.
 * uv is in screen space, [0, 1] x [0, 1].
 *
 */

 //渲染方程中 F项（brdf项） wi 入射方向 wo 出射方向
vec3 EvalDiffuse(vec3 wi, vec3 wo, vec2 uv) {
 //这里用兰伯特光照模型（也可以半兰伯特），为啥除于Π 去看rendering 方程，当L为常量时
  vec3 albedo=GetGBufferDiffuse(uv);
  vec3 normal=GetGBufferNormalWorld(uv);

   float cos= max(0.0,dot(wi,normal));

  return albedo*cos*INV_PI;
}

/*
 * Evaluate directional light with shadow map
 * uv is in screen space, [0, 1] x [0, 1].
 *
 */
  //渲染方程中 L项（光照项）
vec3 EvalDirectionalLight(vec2 uv) {
  vec3 Le =GetGBufferuShadow(uv)*uLightRadiance;
  return Le;
}
//这里算的是间接光照 这是都是世界坐标
bool RayMarch(vec3 ori, vec3 dir, out vec3 hitPos) {
   float maxDis=150.0;//总长
   const int stepNum=3000;
  float step=0.05;
  vec3 realstep=normalize(dir)*step;//真实步长
  vec3 curpos=ori;

 //用当前坐标的深度和当前这个屏幕坐标下的存的深度图对比,如果比Gbuffer深(值更大)说明会收到该点光照
  for(int i = 0; i<=stepNum ;i++)
  {
    float curdepth=GetDepth(curpos);
    vec2 uv=GetScreenCoordinate(curpos);
    float mapdepth=GetGBufferDepth(uv);
    if(curdepth-mapdepth> 0.0001)
    {
      hitPos=curpos;
      return true;
    }
    curpos=curpos+realstep;
  }
  return false;
}

//获取到反射的方向，用法线和视线取反调用 reflect方法
vec3  EvalIndirectionalLight(vec3 ori)
{

  vec3 hitPos;
  vec2 uv=GetScreenCoordinate(ori);
  vec3 dir=reflect(normalize(-(uCameraPos-ori)),GetGBufferNormalWorld(uv));//反射方向

  if(RayMarch(ori,dir,hitPos))
  {
      vec2 screenUV = GetScreenCoordinate(hitPos);
      return GetGBufferDiffuse(screenUV);//获得反射点间接光
  }
  else
  {
    return  vec3(0.); 
  }


}


#define SAMPLE_NUM 1

void main() {
  float s = InitRand(gl_FragCoord.xy);

  vec3 L = vec3(0.0);
  // vec2 uv=GetScreenCoordinate(ori);
  // L = GetGBufferDiffuse(uv);

  vec2 uv=GetScreenCoordinate(vPosWorld.xyz);
  vec3 wo=uLightDir;
  vec3 wi=uCameraPos-vPosWorld.xyz;
  vec3 directional=EvalDirectionalLight(uv)*EvalDiffuse(wo,wi,uv);
  vec3 indirectional=EvalIndirectionalLight(vPosWorld.xyz);

  vec3 color = pow(clamp(L, vec3(0.0), vec3(1.0)), vec3(1.0 / 2.2));
  gl_FragColor = vec4(directional+indirectional, 1.0);
}
