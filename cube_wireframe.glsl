#ifdef GL_ES
precision mediump float;
#endif

#define M_PI 3.1415926535897932384626433832795

// inputs
uniform vec2 u_resolution;
uniform float u_time;

// params
const float line_width = 0.02;

// computed


// primitives
mat3 rot3d_spherical(float phi, float theta){
    return mat3(
        cos(theta), -sin(theta), 0.,
        sin(theta), cos(theta), 0.,
        0., 0., 1.
    ) * mat3(
        cos(phi), 0., -sin(phi),
        0., 1., 0.,
        sin(phi), 0., cos(phi)
    );
}

// Draw functions
float circle(vec2 pos, vec2 center, float r){
    return 1. - step(r, length(pos-center));
}

float line_seg(vec2 pos, vec2 start, vec2 end){
    vec2 dir = normalize(end-start);
    float proj_len = dot(pos-start, dir);
    vec2 proj = proj_len * dir;
    vec2 dist = (pos-start) - proj;
    float result = 1.0 - step(line_width / 2., length(dist));
    result *= step(0., proj_len) * step(0., length(end-start)-proj_len);
    return result;
}

float draw_cube_wireframe(vec2 pos, mat3 transform){
    float result = 0.;
    for(int x = -1; x <= 1; x += 2){
        for(int y = -1; y <= 1; y += 2){
            for(int z = -1; z <= 1; z += 2){
				vec3 start = vec3(x, y, z);
                vec3 start_t = transform * start;
                vec3 end = start;
                vec3 end_t = transform * end;
                // x
                end.x = -end.x;
                end_t = transform * end;
                result = max(result, line_seg(pos, start_t.xz, end_t.xz));
                end.x = -end.x;
                // y
                end.y = -end.y;
                end_t = transform * end;
                result = max(result, line_seg(pos, start_t.xz, end_t.xz));
                end.y = -end.y;
                // z
                end.z = -end.z;
                end_t = transform * end;
                result = max(result, line_seg(pos, start_t.xz, end_t.xz));
                
                result = max(result, circle(pos, start_t.xz, line_width/2.));
            }
        }
    }
    
    return result;
}

void main(void) {
	vec2 pos = gl_FragCoord.xy/u_resolution.xy;
	pos = pos * 2. - 1.; // convert to [-1,1]

    
    //draw
    vec3 color = vec3(0.);
    
    
    // draw grid
    mat3 trans = mat3(
        1.,0.,0.,
        0.,1.,0.,
        0.,0.,1.
    );
    trans = trans * 0.5;
    //trans = rot3d_spherical(M_PI/4., M_PI/4.) * trans;
    trans = rot3d_spherical(1.*u_time, 2.*u_time) * trans;
    color = max(color, draw_cube_wireframe(pos, trans));
    //color = max(color, vec3(.0,.0,1.));
    
    gl_FragColor = vec4(color, 1.0);
}

