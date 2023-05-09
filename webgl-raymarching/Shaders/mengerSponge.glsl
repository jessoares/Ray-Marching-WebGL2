precision mediump float;

uniform float time;
uniform vec2 resolution;
uniform vec3 position;


#define DEPTH 5

#define inf 1000000.0
#define M_PI 3.1415926

float sdbox(in vec3 p) {
    vec3 q = abs(p) - 1.0;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdbox2d(in vec2 p) {
    vec2 d = abs(p)-1.0;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float sdcross(in vec3 p) {
    float d1 = sdbox2d(p.xy);
    float d2 = sdbox2d(p.yz);
    float d3 = sdbox2d(p.xz);
    return min(d1, min(d2, d3));
}

float map(in vec3 p) {
    float d = inf;

    // fractal
    float d1 = sdbox(p);
    d = min(d, d1);

    float d2 = inf;
    float pw = 1.0;
    for (int i = 0; i < DEPTH; ++i) {
        vec3 r = mod(p + pw, pw * 2.0) - pw;
        float d3 = sdcross(r / (pw / 3.0)) * (pw / 3.0);
        pw /= 3.0;
        d2 = min(d2, d3);
    }
    d = max(d, -d2);

    return d;
}

float cast_ray(in vec3 ro, in vec3 rd) {
    float t = 0.001;
    for (int i = 0; i < 100; ++i) {
        vec3 p = ro + t * rd;

        float h = map(p);
        if (h < 0.0001) break;
        if (t > 10.0) break;
        t += h;
    }
    if (t > 10.0) t = inf;
    return t;
}


mat2 rotate(float theta){
    return mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
}

void main() {
    vec2 uv = (gl_FragCoord.xy - resolution.xy / 2.0) / min(resolution.x, resolution.y);

    float r     = 5.0;
    float theta = 2.0*M_PI * (resolution.x - 0.25);
    float phi   = 0.5*M_PI * (resolution.y + 0.000001);

    vec3 ta = vec3(0.0, 0.0, 0.0);
    vec3 ro = ta + r * vec3(sin(phi) * cos(theta), cos(phi), sin(phi) * sin(theta));

    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
    vec3 vv = normalize(cross(uu, ww));

    vec3 rd = normalize(vec3(uv.x*uu + uv.y*vv + 1.0*ww));

    theta = time / 1.0;
    rd.yz *= rotate(theta);
    rd.xy *= rotate(theta);
    ro.yz *= rotate(theta);
    ro.xy *= rotate(theta);
    vec3 col = vec3(0.0);

    float t = cast_ray(ro, rd);
    if (t < inf - 1.) {
        vec3 p = ro + t * rd;
        float fog = 1.0 / (1.0 + t * t * 0.05);
        col = vec3(0.8+0.2*sin(time * 0.1), 0.8+0.2*sin(time * 1.0),0.9+0.1*cos(time*1.0));
        col = col * vec3(fog);
    }
    gl_FragColor = vec4(col, 1.0);
}