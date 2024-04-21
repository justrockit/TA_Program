#ifdef GL_ES
precision mediump float;
#endif

// Phong related variables
uniform sampler2D uSampler;
uniform vec3 uKd;
uniform vec3 uKs;
uniform vec3 uLightPos;
uniform vec3 uCameraPos;
uniform vec3 uLightIntensity;

varying highp vec2 vTextureCoord;
varying highp vec3 vFragPos;
varying highp vec3 vNormal;

// Shadow map related variables
#define NUM_SAMPLES 50
#define BLOCKER_SEARCH_NUM_SAMPLES NUM_SAMPLES
#define PCF_NUM_SAMPLES NUM_SAMPLES
#define NUM_RINGS 10


#define FILTER_RADIUS 10.0 
#define SHADOW_MAP_SIZE 2048.0//设定为方形
#define FRUSTUM_SIZE 400.0 //截面尺寸
#define LIGHT_WORLD_SIZE 5. //光照尺寸设定为方形
#define NEAR_PLANE 0.01 //近平面到光照距离

#define LIGHT_UV_SIZE  LIGHT_WORLD_SIZE/FRUSTUM_SIZE

#define EPS 1e-3
#define PI 3.141592653589793
#define PI2 6.283185307179586

uniform sampler2D uShadowMap;

varying vec4 vPositionFromLight;

highp float rand_1to1(highp float x ) { 
  // -1 -1
  return fract(sin(x)*10000.0);
}

highp float rand_2to1(vec2 uv ) { 
  // 0 - 1
	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
	return fract(sin(sn) * c);
}

float unpack(vec4 rgbaDepth) {
    const vec4 bitShift = vec4(1.0, 1.0/256.0, 1.0/(256.0*256.0), 1.0/(256.0*256.0*256.0));
    return dot(rgbaDepth, bitShift);
}

vec2 poissonDisk[NUM_SAMPLES];

void poissonDiskSamples( const in vec2 randomSeed ) {

  float ANGLE_STEP = PI2 * float( NUM_RINGS ) / float( NUM_SAMPLES );
  float INV_NUM_SAMPLES = 1.0 / float( NUM_SAMPLES );

  float angle = rand_2to1( randomSeed ) * PI2;
  float radius = INV_NUM_SAMPLES;
  float radiusStep = radius;

  for( int i = 0; i < NUM_SAMPLES; i ++ ) {
    poissonDisk[i] = vec2( cos( angle ), sin( angle ) ) * pow( radius, 0.75 );
    radius += radiusStep;
    angle += ANGLE_STEP;
  }
}

void uniformDiskSamples( const in vec2 randomSeed ) {

  float randNum = rand_2to1(randomSeed);
  float sampleX = rand_1to1( randNum ) ;
  float sampleY = rand_1to1( sampleX ) ;

  float angle = sampleX * PI2;
  float radius = sqrt(sampleY);

  for( int i = 0; i < NUM_SAMPLES; i ++ ) {
    poissonDisk[i] = vec2( radius * cos(angle) , radius * sin(angle)  );

    sampleX = rand_1to1( sampleY ) ;
    sampleY = rand_1to1( sampleX ) ;

    angle = sampleX * PI2;
    radius = sqrt(sampleY);
  }
}

/*
pcss shading point 到光照近平面 锥体范围里 阻挡物体的平均深度
*/
float findAvgBlocker( sampler2D shadowMap,  vec4 coords ) {
  float blockerNum=0.0;// 阻挡物体点的数量
  float blockerAllLength=0.0;// 阻挡物体点的总长
  float zDepth=vPositionFromLight.z;//光照在光照空间深度


   //相似三角形原理，从光源放大到近平面
  float searchSize= LIGHT_UV_SIZE*(zDepth-NEAR_PLANE)/zDepth;
   poissonDiskSamples(coords.xy);//泊松分布随机顶点

     for( int i = 0; i < NUM_SAMPLES; i ++ ) 
     {
      float depth=  unpack(texture2D(shadowMap, coords.xy+poissonDisk[i]*searchSize));
      //depth小于 说明是阻挡物
          if(depth<coords.z)
          {
         blockerNum++;
          blockerAllLength=blockerAllLength+depth;
          }

     }
 if(blockerNum == 0.0)
    return -1.;
  else
    return blockerAllLength / float(blockerNum);
}

/*
Radius 硬阴影是0 pcf 要算
*/
float  getShadowBias (float OffsetValue,float Radius) 
{
  vec3 lightDir= normalize(uLightPos-vFragPos);
  float value=1.0- dot(lightDir,normalize(vNormal));
  float fragSize = (1.0-ceil(Radius))*( float(FRUSTUM_SIZE) / float( SHADOW_MAP_SIZE ) / 2.0);

  return max(fragSize, fragSize * value)*OffsetValue;
}

// float getShadowBias(float c, float filterRadiusUV){
//   vec3 normal = normalize(vNormal);
//   vec3 lightDir = normalize(uLightPos - vFragPos);
//   float fragSize = (1.0 + ceil(filterRadiusUV)) * (float(FRUSTUM_SIZE) / float(SHADOW_MAP_SIZE) / 2.0);
//   return max(fragSize, fragSize * (1.0 - dot(normal, lightDir))) * c;
// }


// float BlockDis[9];
// float PCF(sampler2D shadowMap, vec4 coords,float range) {
// float depth=coords.z;
// float offset=range;
// //先试试简单卷积加权平均 ,思路是对周围的点采样深度，判断是阴影就+1  效果看起来像素太明显
//     BlockDis[0]=unpack(texture2D(shadowMap,vec2(coords.x-1.0*offset,coords.y+1.0*offset)));
//     BlockDis[1]=unpack(texture2D(shadowMap,vec2(coords.x,coords.y+1.0*offset)));
//     BlockDis[2]=unpack(texture2D(shadowMap,vec2(coords.x+1.0*offset,coords.y+1.0*offset)));
//     BlockDis[3]=unpack(texture2D(shadowMap,vec2(coords.x-1.0*offset,coords.y)));
//     BlockDis[4]=unpack(texture2D(shadowMap,vec2(coords.x,coords.y)));
//     BlockDis[5]=unpack(texture2D(shadowMap,vec2(coords.x+1.0*offset,coords.y)));
//     BlockDis[6]=unpack(texture2D(shadowMap,vec2(coords.x-1.0*offset,coords.y-1.0*offset)));
//     BlockDis[7]=unpack(texture2D(shadowMap,vec2(coords.x,coords.y-1.0*offset)));
//     BlockDis[8]=unpack(texture2D(shadowMap,vec2(coords.x+1.0*offset,coords.y-1.0*offset)));

// float value=0.0;
//   for( int i = 0; i < 9; i ++ ) {
//     if(BlockDis[i]+EPS>depth)
//     {
//   value++;
//     }
   
//   }


//   return value/9.0;
// }


float useShadowMap(sampler2D shadowMap, vec4 shadowCoord,float bias)
{
  float lightdepth=unpack(texture2D(shadowMap,shadowCoord.xy));
  float depth=shadowCoord.z;

  if(lightdepth+EPS>depth-bias)
     {
      return 1.0;
     }
  else
    {
      return 0.0;
    }
}
 float PCF(sampler2D shadowMap, vec4 coords,float range) {
  float depth=coords.z;
  float offset=range;//    采样范围/shadowMap尺寸（归一化的意思）,得到uv的值
  float pcfBiasC = .08;//bias 值
  float value=0.0;
  poissonDiskSamples(coords.xy);//泊松分布随机顶点

  for( int i = 0; i < NUM_SAMPLES; i ++ ) {
    vec2 Bias = poissonDisk[i] * offset;
   // float dis=unpack(texture2D(shadowMap,coords.xy+Bias)); 
   pcfBiasC= getShadowBias(pcfBiasC,range);
   float shadowDepth = useShadowMap(shadowMap, coords + vec4(Bias, 0., 0.), pcfBiasC);
    if(shadowDepth+EPS>depth)
     {
        value++;
     }
  }
  return value/float(NUM_SAMPLES);
}




float PCSS(sampler2D shadowMap, vec4 coords){

  // STEP 1: avgblocker depth
float avgblocker= findAvgBlocker(shadowMap,coords);
  if(avgblocker < -EPS)
    return 1.0;
  // STEP 2: penumbra size
//相似三角形原理
float  Wpernumber=(coords.z-avgblocker)*LIGHT_UV_SIZE/avgblocker;
  // STEP 3: filtering
  //pcf
 return PCF(shadowMap,coords,Wpernumber);


}



vec3 blinnPhong() {
  vec3 color = texture2D(uSampler, vTextureCoord).rgb;
  color = pow(color, vec3(2.2));

  vec3 ambient = 0.05 * color;

  vec3 lightDir = normalize(uLightPos);
  vec3 normal = normalize(vNormal);
  float diff = max(dot(lightDir, normal), 0.0);
  vec3 light_atten_coff =
      uLightIntensity / pow(length(uLightPos - vFragPos), 2.0);
  vec3 diffuse = diff * light_atten_coff * color;

  vec3 viewDir = normalize(uCameraPos - vFragPos);
  vec3 halfDir = normalize((lightDir + viewDir));
  float spec = pow(max(dot(halfDir, normal), 0.0), 32.0);
  vec3 specular = uKs * light_atten_coff * spec;

  vec3 radiance = (ambient + diffuse + specular);
  vec3 phongColor = pow(radiance, vec3(1.0 / 2.2));
  return phongColor;
}

void main(void) {

 vec3  shadowCoord=vPositionFromLight.xyz/vPositionFromLight.w;//vPositionFromLight为光源空间下投影的裁剪坐标，除以w结果为NDC坐标
  shadowCoord.xyz = (shadowCoord.xyz + 1.0) / 2.0; //把[-1,1]的NDC坐标转换为[0,1]的坐标


 // PCF的采样范围，因为是在Shadow Map上采样，需要除以Shadow Map大小，得到uv坐标上的范围
  float filterRadiusUV = FILTER_RADIUS / SHADOW_MAP_SIZE;

  float visibility;
  //visibility = useShadowMap(uShadowMap, vec4(shadowCoord, 1.0),getShadowBias(0.4,0.0));

  //visibility = PCF(uShadowMap, vec4(shadowCoord, 1.0),filterRadiusUV);
  visibility = PCSS(uShadowMap, vec4(shadowCoord, 1.0));

  vec3 phongColor = blinnPhong();

  gl_FragColor = vec4( phongColor*visibility , 1.0);
 // gl_FragColor = vec4(phongColor, 1.0);
}