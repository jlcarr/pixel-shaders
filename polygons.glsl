// Author: J Carr

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

#define M_PI 3.14159265358979
const float r = 1.0;
const float cycle_len = 6.;
const int n_shapes = 6;

float polygon(vec2 pos, float r, int n){
    float phi = 2. * M_PI / float(n);
    float interior = (M_PI - phi) / 2.;
    float theta = atan(pos.y, pos.x);
    theta = mod(theta, phi);
    float l = sin(interior) * r / sin(M_PI - interior - theta);
    return l;
}

float df(vec2 p, float r){
    return 1. - step(r, length(p));
}

float peak(float p, float w, float t){
    return smoothstep(p-w, p, t) - smoothstep(p, p+w, t);
}

void main(void) {
	vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.y *= u_resolution.y/u_resolution.x;
	st = (st-.5)*2.;

    float color = 0.0;
    
    float cycle_time = mod(u_time, cycle_len);
    float shape_len = cycle_len/float(n_shapes);

    float l = 0.0;
	l += polygon(st, r, 3) * peak(0., shape_len, cycle_time-cycle_len);
    for (int i = 0; i < n_shapes; ++i){
        l += polygon(st, r, 3+i) * peak(float(i)*shape_len, shape_len, cycle_time);
    }
    
    color += df(st, l);
    
	gl_FragColor = vec4(vec3(color), 1.0);
}

