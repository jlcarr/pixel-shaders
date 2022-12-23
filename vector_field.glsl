#ifdef GL_ES
precision mediump float;
#endif

#define M_PI 3.1415926535897932384626433832795
#define EPSILON 0.01

// inputs
uniform vec2 u_resolution;
uniform float u_time;

// params
const int grid_num_cells = 8;
const float grid_line_width = 0.05;
const float global_line_width = grid_line_width / float(grid_num_cells);

// computed
const float grid_cell_width = 2.0/float(grid_num_cells);

// primitives
mat2 rot2d(float theta){
    return mat2(cos(theta),-sin(theta),
                sin(theta),cos(theta));
}

// Draw functions
float draw_grid(vec2 grid_cell_pos){
    vec2 bounds = step(1.-grid_line_width/2., abs(grid_cell_pos));
    return float(bool(bounds.x) || bool(bounds.y));
}

float circle(vec2 pos, vec2 center, float r){
    return 1.0 - step(r, length(pos-center));;
}

float line_seg(vec2 pos, vec2 start, vec2 end){
    vec2 dir = normalize(end-start);
    float proj_len = dot(pos-start, dir);
    vec2 proj = proj_len * dir;
    vec2 dist = (pos-start) - proj;
    float result = 1.0 - step(grid_line_width / 2., length(dist));
    result *= step(0., proj_len) * step(0., length(end-start)-proj_len);
    return result;
}

vec3 float2color(float v){
    return vec3(step(0.,v)*v, 0., -step(0.,-v)*v);
}

// field operations

vec2 rotating_field(vec2 pos){
    return vec2(cos(u_time),sin(u_time));
}

float sinusoidal_field(vec2 pos){
    pos *= 1.;
    //pos += vec2(u_time);
    return sin(2. * M_PI * pos.x / 4.) * sin(2. * M_PI * pos.y / 4.); //* sin(u_time);
}

float scalar_field(vec2 pos){
    return sinusoidal_field(pos);
}

vec2 gradient_field(vec2 pos){
    float h = EPSILON;
    vec2 dx = vec2(h, 0.);
	vec2 dy = vec2(0., h);
    return vec2(
        scalar_field(pos+dx) - scalar_field(pos-dx),
        scalar_field(pos+dy) - scalar_field(pos-dy)
    ) / (2. * h); // central difference
}

vec2 vector_field(vec2 pos){
    return gradient_field(pos);
	//return rotating_field(pos);
}

float draw_vector_field(ivec2 grid_cell_coord, vec2 grid_cell_pos){
    float head_length = 1./4.;
    // setup
    vec2 pos = vec2(grid_cell_coord);
    pos = pos - .5 * sign(pos);
    // the actual vector field
    vec2 dir = vector_field(pos);
    dir = normalize(dir) / sqrt(2.);
    // drawing
    float result = 0.;
    result = max(result, line_seg(grid_cell_pos, vec2(0.), dir));
    //result = max(result, line_seg(grid_cell_pos, vec2(0.), -dir));
    // arrowhead
    result = max(result, line_seg(grid_cell_pos, dir, dir + head_length*rot2d(3.*M_PI/4.)*dir));
    result = max(result, line_seg(grid_cell_pos, dir, dir + head_length*rot2d(-3.*M_PI/4.)*dir));
    //caps
    result = max(result, circle(grid_cell_pos, vec2(0.), grid_line_width / 2.));
    result = max(result, circle(grid_cell_pos, dir, grid_line_width / 2.));
    //result = max(result, circle(grid_cell_pos, -dir, grid_line_width / 2.));
    return result;
}

void main(void) {
	vec2 pos = gl_FragCoord.xy/u_resolution.xy;
	pos = pos * 2. - 1.; // convert to [-1,1]

    // get grid
    ivec2 grid_cell_coord = ivec2(pos/grid_cell_width + sign(pos));
    vec2 grid_cell_pos = mod(pos, grid_cell_width) / grid_cell_width;
    grid_cell_pos =  grid_cell_pos * 2. - 1.; // convert to [-1,1]
    
    //draw
    vec3 color = vec3(0.);
    
    // field
    color = float2color(scalar_field(pos/grid_cell_width));
    color = max(color, draw_vector_field(grid_cell_coord, grid_cell_pos));
    
    // draw grid
    color = max(color, draw_grid(grid_cell_pos));
    
	gl_FragColor = vec4(color, 1.0);
}


