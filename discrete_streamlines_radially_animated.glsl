#ifdef GL_ES
precision mediump float;
#endif

#define M_PI 3.1415926535897932384626433832795
#define EPSILON 0.01
const float discrete_sweep = 2. * M_PI / 8.;

// inputs
uniform vec2 u_resolution;
uniform float u_time;

// params
const int grid_num_cells = 16;
const float grid_line_width = 0.05;
const float global_line_width = grid_line_width / float(grid_num_cells);
const float line_width = 0.2;

// computed
const float grid_cell_width = 2.0/float(grid_num_cells);

// primitives
mat2 rot2d(float theta){
    return mat2(cos(theta),-sin(theta),
                sin(theta),cos(theta));
}

float rand(vec2 st) {
    //return fract(sin(dot(st,vec2(12.9898,78.233)))*43758.5453123);
    return fract(sin(dot(st,vec2(12.34,56.78)))*81.011);
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
    float result = 1.0 - step(line_width / 2., length(dist));
    result *= step(0., proj_len) * step(0., length(end-start)-proj_len);
    return result;
}

vec3 float2color(float v){
    return vec3(step(0.,v)*v, 0., -step(0.,-v)*v);
}

vec2 discretize_dir(vec2 dir){
    float theta = atan(dir.y,dir.x);
    float discrete_theta = floor(theta / discrete_sweep + 0.5) * discrete_sweep; // round to nearest multiple
    return vec2(cos(discrete_theta), sin(discrete_theta));
}

// field operations
// default fields
vec2 rad_field(vec2 pos){
    return pos;
}

vec2 rotating_field(vec2 pos){
    return vec2(cos(u_time),sin(u_time));
}

vec2 rotational_field(vec2 pos){
    return vec2(-pos.y,pos.x);
}

float sinusoidal_field(vec2 pos){
    pos *= 1.;
    //pos += vec2(u_time);
    //pos += vec2(cos(u_time), sin(u_time));
    return sin(2. * M_PI * pos.x / float(grid_num_cells)) * sin(2. * M_PI * pos.y / float(grid_num_cells)); //* sin(u_time);
}

// computed fields
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

vec2 stear_random_field(vec2 pos){
    const float range = 3. * M_PI / 8.;
    vec2 dir = rad_field(pos); // replace with any vector field
    float theta = atan(dir.y,dir.x);
    float offset = (rand(pos)-0.5) * range;
    theta += offset;
    return vec2(cos(theta), sin(theta));
}

vec2 vector_field(vec2 pos){
    return stear_random_field(pos); // replace with any vector field
    //return rad_field(pos);
    //return rotational_field(pos);
    //return gradient_field(pos);
	//return rotating_field(pos);
}

float draw_discrete_streamlines(ivec2 grid_cell_coord, vec2 grid_cell_pos){
    const float period = float(grid_num_cells);
    const float head_length = 1./2.;
    float result = 0.;
    // setup
    vec2 pos = vec2(grid_cell_coord);
    pos = pos - .5 * sign(pos);
    
    for (int i = -1; i <= 1; i++){
        for (int j = -1; j <= 1; j++){
            // move to cell
            vec2 pos_offset = vec2(ivec2(i,j));
            vec2 offset_pos = pos + pos_offset;
            vec2 grid_cell_pos_offset = 2.*vec2(ivec2(i,j));
            // animate
            float dist = max(abs(offset_pos.x),abs(offset_pos.y));
            dist = length(offset_pos);
            float cell_time = clamp(mod(u_time, period) - dist, 0., 1.0);
            float is_drawn = float(cell_time > 0.);
            // the actual vector field
            vec2 dir = vector_field(offset_pos);
            dir = discretize_dir(dir);
            dir = 2.*sign(dir)*ceil(abs(dir)); // round to hit centers of neighboring cells
            dir *= cell_time;
            vec2 offset_dir = dir+grid_cell_pos_offset;
            // drawing
            result = max(result, is_drawn*line_seg(grid_cell_pos, grid_cell_pos_offset, offset_dir));
            // arrowhead
            //result = max(result, is_drawn*line_seg(grid_cell_pos, offset_dir, offset_dir + head_length*rot2d(3.*M_PI/4.)*normalize(dir)));
            //result = max(result, is_drawn*line_seg(grid_cell_pos, offset_dir, offset_dir + head_length*rot2d(-3.*M_PI/4.)*normalize(dir)));
            //caps
            result = max(result, is_drawn*circle(grid_cell_pos, grid_cell_pos_offset, line_width / 2.));
            result = max(result, is_drawn*circle(grid_cell_pos, offset_dir, line_width / 2.));
        }
    }
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
    //color = float2color(scalar_field(pos/grid_cell_width));
    color = max(color, draw_discrete_streamlines(grid_cell_coord, grid_cell_pos));
    
    // draw grid
    color = max(color, draw_grid(grid_cell_pos));
    
	gl_FragColor = vec4(color, 1.0);
}

