
precision mediump float;
uniform float iTime;
uniform vec2 iResolution;
#define PI 3.141592

const vec3 cPos = vec3(0.0, 0.0, -9.0);
const vec3 cDir = vec3(0.0, 0.0, 1.0);
const vec3 cUp = vec3(0.0, 1.0, 0.0);
const vec3 cSide = vec3(1.0,0.0,0.0);
const float depth = 1.0;
const vec3 lPos = vec3(10.0,10.0,-10.0);

vec3 rotate(vec3 p, float angle, vec3 axis){
    vec3 a = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float r = 1.0 - c;
    mat3 m = mat3(
        a.x * a.x * r + c,
        a.y * a.x * r + a.z * s,
        a.z * a.x * r - a.y * s,
        a.x * a.y * r - a.z * s,
        a.y * a.y * r + c,
        a.z * a.y * r + a.x * s,
        a.x * a.z * r + a.y * s,
        a.y * a.z * r - a.x * s,
        a.z * a.z * r + c
    );
    return m * p;
}

vec2 pmod(vec2 p, float r) {
float a = mod(atan(p.x,p.y),PI*2./r)-0.5*PI*2./r;
    return length(p)*vec2(sin(a),cos(a));
}

float distFunc(vec3 p) {     
  p=rotate(p,sin(iTime*1.3)/5.0,vec3(0.,1.,0.0));
  p=rotate(p,cos(iTime*1.7)/2.0,vec3(1.,0.,0.0));
  p=rotate(p,iTime/2.0,vec3(0.,0.,1.0));
  p.y+=sin(iTime);
  p.z+=cos(iTime/2.);
  p.x+=tan(iTime/4.0)*2.0;  
  p.yz = pmod(p.yz,11.0);
  float q = 1.8;
  p.y = mod(p.y, 6.0) - 3.0;
  p.xz = mod(p.xz, 3.0) - 1.5;
  for (float i = 0.0; i < 8.0; i++) {
    p = abs(p) - vec3(3.9 * mix(0.8, 0.2,
                                smoothstep(abs(mod(iTime*10.0, 100.0) - 50.0),
                                           0.0, 1.0)),
                      0.5,1.2);
    float s = clamp(length(p)*(sin(iTime/2.0)/2.0+1.5), 0.13, 0.95);
    p = p / s;
    p -= vec3(0.2, 1.9, 0.1) * exp(-i);
    q /= s;
  }
  return length(p / q);
}

vec3 getNormal(vec3 p) {
  float d = 0.001;
  return normalize(
      vec3(distFunc(p + vec3(d, 0.0, 0.0)) - distFunc(p + vec3(-d, 0.0, 0.0)),
           distFunc(p + vec3(0.0, d, 0.0)) - distFunc(p + vec3(0.0, -d, 0.0)),
           distFunc(p + vec3(0.0, 0.0, d)) - distFunc(p + vec3(0.0, 0.0, -d))));
}

vec3 rayMarching(vec3 color, vec2 p) {  
  vec3 ray = normalize(cSide * p.x + cUp * p.y + cDir * depth);
  vec3 rPos = cPos;
  float rLen = 0.0;
  float maxDist = 20.0;
  for (float i = 0.0; i < 60.0; i++) {
    float distance = distFunc(rPos);
    if (abs(distance) < 0.03) {      
      vec3 normal = getNormal(rPos);
      vec3 lVec = normalize(lPos - rPos);
      float diffuse = clamp(dot(normal, lVec), 0.1, 1.0)+0.5;
      color = (vec3(0.6 * sin(rPos.z + iTime / 50.0 - 5.0),
                    0.2 * cos(rPos.y + iTime / 70.0 - 2.0),
                    0.2 * cos(rPos.z * iTime / 80.0)) *
                   diffuse+0.4);
                   
      break;
    }    
    color+=0.0005/distance*(vec3(0.8 * sin(rPos.z + iTime / 50.0 - 5.0),
                    0.2 * cos(rPos.y + iTime / 70.0 - 2.0),
                    0.3 * cos(rPos.z * iTime / 80.0)) +
                   0.5);;
    rLen += distance;
    if (rLen > maxDist) {
      break;
    }
    rPos = cPos + rLen * ray;
  }
  return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 p =
      (fragCoord.xy * 2.0 - iResolution.xy) / min(iResolution.x, iResolution.y);
  vec3 color = rayMarching(vec3(0.0), p);  
  fragColor = vec4(color, 1.0);
}