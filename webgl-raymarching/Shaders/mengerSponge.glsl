precision mediump float;

uniform float time;
uniform vec2 resolution;
uniform vec3 position;

#define distfar 6.
#define iterations 6.0

float maxcomp(vec3 p) {
    return max(p.x,max(p.y,p.z));
}

float sdBox( vec3 p, vec3 b )
{
  vec3  di = abs(p) - b;
  float mc = maxcomp(di);
  return min(mc,length(max(di,0.0)));
}

float sdBox2D(vec2 p, vec2 b) {
	vec2  di = abs(p) - b;
    float mc = max(di.x,di.y);
    return min(mc,length(max(di,0.0)));
}

float sdCross( in vec3 p )
{
  float da = sdBox2D(p.xy,vec2(1.0));
  float db = sdBox2D(p.yz,vec2(1.0));
  float dc = sdBox2D(p.zx,vec2(1.0));
  return min(da,min(db,dc));
}

#define MENGER_ITERATIONS	2



vec2 map1(vec3 p) 
{
    float d = sdBox(p,vec3(1.0));
    
    for (float i = 0.0; i < iterations; i++) {

        float scale = pow(2.0,i);
        vec3 q = mod(scale*p,2.0)-1.0;
        q = 1.0-abs(q);
        float c = sdCross(q*3.0)/(scale*3.0);
        d = max(d,-c),1.0;
        
        p += scale/3.0;
		
    }
    
    return vec2(d,1.0);
    
}




vec2 map(vec3  p)
{

   p.xz = mod(p.xz + 5.0, 2.0) - 1.0;
   p.y  = mod(p.y + 1.0, 2.0) - 1.0;
   float t=mod(time,10.0); 
   float t1=mod(t,4.0);
   float t2=mod(t,3.0);
   float d1;

   d1=map1(p).x;
   
   return vec2(d1,1.0);
    
}

/*
*/

float trace(vec3 ro, vec3 rd) {
    float t = 0.0;
    for (float i = 0.0; i < 1000.0; i++) {
        if (t > distfar) break;
        vec2 d = map(ro + rd*t);
        if (d.x < 0.0001) return t;
        t += d.x;
    }
    return 0.;
}

void main() 
{
	vec2 uv = gl_FragCoord.xy / resolution.xy * 2.0 - 1.0;
    uv.x *= resolution.x/resolution.y;
    
    vec3 ro = vec3(0.0,0.0,1.5);
    vec3 rd = normalize(vec3(uv,-1.5));
    ro.z -= 1. * time;

    float t = trace(ro, rd);
    
    vec3 col = vec3(0.0);
    
    if (t !=0.) {
        
    
        col = vec3(0.5);
        
    }
    float fog = 1.0 / (1.0 + (t) * t + 0.05);
    col = mix(vec3(0), col, fog);
	gl_FragColor = vec4(col , 1.);
}