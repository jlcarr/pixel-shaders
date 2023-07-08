#ifdef GL_ES
precision mediump float;
#endif

#define M_PI 3.1415926535897932384626433832795

// inputs
uniform vec2 u_resolution;
uniform float u_time;

// params
const float head_size = sqrt(1.);
const float tail_length = 0.5;
const int segments = 8;
const int num_comments = 16;

// computed


// primitives
float rand(vec2 st){
    return fract(sin(dot(st,vec2(12.34,56.78)))*81.011);
}

// Draw functions
vec2 circle(vec2 pos, vec2 center){ 
    return vec2(length(pos-center), 0.);
}

vec2 line_seg(vec2 pos, vec2 start, vec2 end){
    vec2 dir = normalize(end-start);
    float l = length(end-start);
    float proj_len = dot(pos-start, dir);
    float t = proj_len/l;
    vec2 proj = proj_len * dir;
    vec2 dist = (pos-start) - proj;
    float inside = step(0., t) * step(0., 1.-t);
    float enddist = min(length(pos-start), length(pos-end));
    float d = length(dist) * inside + enddist*(1.-inside);
    
    return vec2(d, t);
}

float glow(vec2 dt, float mint, float maxt){
    float t = clamp(dt.t, 0.,1.);
    dt.x += 0.01;
    return 0.01 /dt.x * mix(mint, maxt, t);
}

vec2 wandering_path(float t, float seedv){
    vec2 p = vec2(0);
    const int levels = 4;
    for(int level = 1; level <= levels; level++){
        float seed = float(level) + 16.*seedv;
        float r = sqrt(2.) * float(level) / float(levels) / float(levels);
        
        float f = 2. * M_PI * (2.*rand(vec2(seed+0.1))-1.) / float(level);
        
        float phase = 2. * M_PI * rand(vec2(seed+0.2));
        
        p += r * vec2(cos(f * t + phase), sin(f * t + phase));
    }   
    return p;
}

float draw_comet(vec2 pos){
    float result = 0.;
    for (int c = 0; c < num_comments; c ++){
        vec2 pprev = wandering_path(u_time, float(c));
        float tprev = 0.;
        result = max(result, head_size * glow(circle(pos, pprev), 1., 1.));
        for(int i = 1; i <= segments; i++){
            float t = float(i) / float(segments);
            vec2 p = wandering_path(u_time - t*tail_length, float(c));
            result = max(result, glow(line_seg(pos, pprev, p), 1.-tprev, 1.-t));
            pprev = p;
            tprev = t;
        }  
    }
    
    return result;
}

void main(void) {
    vec2 pos = gl_FragCoord.xy/u_resolution.xy;
    pos = pos * 2. - 1.; // convert to [-1,1]

    //draw
    vec3 color = vec3(0.);

    color = max(color, draw_comet(pos));
    //color = max(color, vec3(.0,.0,1.));
    //color *= vec3(.5,.5,1.0);
    //const float r = 1./sqrt(2.);
    //color = max(color, length(pos) > r ? 0.5/(length(pos)+1.-r)/(length(pos)+1.-r)/(length(pos)+1.-r)/(length(pos)+1.-r): 0.);

    gl_FragColor = vec4(color, 1.0);
}

