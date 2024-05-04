// attribute vec3 aVertexPosition;
// attribute vec3 aNormalPosition;
// attribute vec2 aTextureCoord;

// attribute mat3 aPrecomputeLT;

// uniform mat3 aPrecomputeLR;
// uniform mat3 aPrecomputeLG;
// uniform mat3 aPrecomputeLB;
// uniform mat4 uModelMatrix;
// uniform mat4 uViewMatrix;
// uniform mat4 uProjectionMatrix;
// uniform mat4 uLightMVP;

// varying highp vec3 vNormal;
// varying highp vec2 vTextureCoord;
// varying highp  vec3 vColor;

// vec3 dotcolor(mat3 Lt, mat3 L)
// {
// vec3 L0=L[0];
// vec3 L1=L[1];
// vec3 L2=L[2];

// vec3 Lt0=Lt[0];
// vec3 Lt1=Lt[1];
// vec3 Lt2=Lt[2];

// return dot(L0,Lt0)+dot(L1,Lt1)+dot(L2,Lt2);

// }

// void main(void) {

//   vNormal = aNormalPosition;
//   vTextureCoord = aTextureCoord;

// vColor[0]=1;
// vColor[1]=1;
// vColor[2]=1;


//   gl_Position = uLightMVP * vec4(aVertexPosition, 1.0);
// }


attribute vec3 aVertexPosition;
attribute vec3 aNormalPosition;
attribute mat3 aPrecomputeLT;

uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uProjectionMatrix;

//uniform mat3 uPrecomputeL[3];
 uniform mat3 aPrecomputeLR;
uniform mat3 aPrecomputeLG;
 uniform mat3 aPrecomputeLB;
varying highp vec3 vNormal;
varying highp mat3 vPrecomputeLT;
varying highp vec3 vColor;

float L_dot_LT(mat3 PrecomputeL, mat3 PrecomputeLT) {
  vec3 L_0 = PrecomputeL[0];
  vec3 L_1 = PrecomputeL[1];
  vec3 L_2 = PrecomputeL[2];
  vec3 LT_0 = PrecomputeLT[0];
  vec3 LT_1 = PrecomputeLT[1];
  vec3 LT_2 = PrecomputeLT[2];
  return dot(L_0, LT_0) + dot(L_1, LT_1) + dot(L_2, LT_2);
}

void main(void) {
  // 无实际作用，避免aNormalPosition被优化后产生警告
  vNormal = (uModelMatrix * vec4(aNormalPosition, 0.0)).xyz;

  // for(int i = 0; i < 3; i++)
  // {
  //   vColor[i] = L_dot_LT(uPrecomputeL[i],aPrecomputeLT);
  // }
vColor[0]=L_dot_LT(aPrecomputeLR,aPrecomputeLT);
vColor[1]=L_dot_LT(aPrecomputeLG,aPrecomputeLT);
vColor[2]=L_dot_LT(aPrecomputeLB,aPrecomputeLT);
  gl_Position = uProjectionMatrix * uViewMatrix * uModelMatrix * vec4(aVertexPosition, 1.0);
}