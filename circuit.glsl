#ifdef GL_ES
precision mediump float;
#endif

#define M_PI 3.1415926535897932384626433832795
#define EPSILON 0.01

uniform vec2 u_resolution;
uniform float u_time;
const int grid_size = 8;
const float line_width = 0.2;
const float grid_width = 0.1;

int imod(int a, int b) {
    return a - b*int(a/b);
}


// Draw Primitives
float draw_line(vec2 pos, vec2 dir){
    vec2 proj = dot(pos, dir) / length(dir) * normalize(dir);
    vec2 dist = pos - proj;
    return 1.0 - step(line_width, length(dist));
}

float draw_anulus(float orig, vec2 pos, vec2 center){
    float dist = length(pos-center);
    if (dist < line_width * 3.0 / 2.0) orig = 1.0;
    if (dist < line_width / 2.0) orig = 0.0;
    return orig;
}

float draw_grid(vec2 pos){
    return 1. - step(grid_width/2., 1.-abs(pos.x)) * step(grid_width/2., 1.-abs(pos.y));
}


// Utility
float rad_theta(ivec2 grid_coord){
    return atan(float(2*grid_coord.y - grid_size+1)/2.0, float(2*grid_coord.x - grid_size+1)/2.0);
}

float discretize_theta(float theta){
    return floor(theta * 8.0 / (2.0 * M_PI) + 0.5) * (2.0 * M_PI) / 8.0;
}


float grid_rad(ivec2 grid_coord){
    vec2 pos_vec = vec2(2*grid_coord - grid_size+1)/2.0;
    return length(pos_vec);
}

ivec2 theta_to_discrete_dir(float theta){
    return ivec2((1.0+EPSILON)*sqrt(2.0)*vec2(cos(theta), sin(theta)));
}


// Vector fields
vec2 rad_dir(ivec2 grid_coord){
    float theta = rad_theta(grid_coord);
    theta = discretize_theta(theta);
    return vec2(cos(theta), sin(theta));
}

vec2 NS_field(ivec2 grid_coord){
    return vec2(0.0, 1.0);
}

vec2 rot_field(ivec2 grid_coord){
    float theta = rad_theta(grid_coord);
    theta = discretize_theta(theta);
    return vec2(sin(theta), -cos(theta));
}

vec2 vector_field(ivec2 grid_coord){
    return rad_dir(grid_coord);
}


// Main drawing
float draw_discrete_vector_field(ivec2 grid_coord, vec2 grid_pos){
    // current vector
    vec2 dir = vector_field(grid_coord);
    float drawing = draw_line(grid_pos, dir);
    drawing *= step(0., dot(grid_pos,dir)); // only point past the center
    //drawing *= 0.0;
    
    float entered = 0.0;
    
    for (int i = -1; i <= 1; i++){
        for (int j = -1; j <= 1; j++){
            ivec2 offset = ivec2(i,j);
            vec2 dir2 = vector_field(grid_coord + offset);
            float drawing2 = draw_line(grid_pos-2.*vec2(offset), dir2);
            drawing2 *= step(0., dot(grid_pos,normalize(vec2(offset)))); // only point past the center
            drawing2 *= step(0., dot(dir2,-vec2(offset)));
            drawing2 *= step(EPSILON, length(vec2(offset)));
            drawing = max(drawing, drawing2);
            
            entered += step(1.-EPSILON, dot(normalize(dir2),-normalize(vec2(offset))));
    	}
    }

    //
    entered = step(EPSILON, entered);
    float annus = draw_anulus(drawing, grid_pos, vec2(0.0));
    drawing = (1.-entered) * annus + entered*drawing;
    
    return drawing;
}

void main(void) {
	vec2 pos = gl_FragCoord.xy/u_resolution.xy;
	pos = pos*2.0 - 1.0;

    // grid up
    float grid_length = 2.0/float(grid_size);
    ivec2 grid_coord = ivec2((pos+1.0)/grid_length);
    vec2 grid_pos = mod(pos, grid_length);
    grid_pos = (grid_pos - grid_length/2.0)*float(grid_size);
    
    //if (imod(grid_coord.x, 2) == imod(grid_coord.y, 2)) grid_pos.xy = grid_pos.yx;
    
    // main drawing
    float drawing = draw_discrete_vector_field(grid_coord, grid_pos);
    
    
    //draw grid;
    float grid_drawing = draw_grid(grid_pos);
    drawing = max(drawing, grid_drawing);
    
    // circle boundary
    const int rad = grid_size/2;
    drawing *= 1.-step(float(rad), grid_rad(grid_coord));
    drawing *= 1.-0.5*step(float(rad)/float(grid_size/2), length(pos));
    
    
    //if (grid_rad(grid_coord) <= float(rad) && grid_rad(grid_coord) > float(rad-1)) drawing = draw_anulus(drawing, grid_pos, vec2(0.0));
    
	gl_FragColor = vec4(1.0-vec3(drawing), 1.0);
}

