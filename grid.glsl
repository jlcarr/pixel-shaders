#ifdef GL_ES
precision mediump float;
#endif

#define M_PI 3.1415926535897932384626433832795
#define EPSILON 0.01

// inputs
uniform vec2 u_resolution;
uniform float u_time;

// params
const int grid_num_cells = 6;
const float grid_line_width = 0.1;

// computed
const float grid_cell_width = 2.0/float(grid_num_cells);

// functions
float draw_grid(vec2 grid_cell_pos){
    vec2 bounds = step(1.-grid_line_width/2., abs(grid_cell_pos));
    return float(bool(bounds.x) || bool(bounds.y));
}

void main(void) {
	vec2 pos = gl_FragCoord.xy/u_resolution.xy;
	pos = pos * 2. - 1.; // convert to [-1,1]

    // get grid
    ivec2 grid_cell_coord = ivec2(pos/grid_cell_width + sign(pos));
    vec2 grid_cell_pos = mod(pos, grid_cell_width) / grid_cell_width;
    grid_cell_pos =  grid_cell_pos * 2. - 1.; // convert to [-1,1]
    
    //draw grid cell
    vec3 color = vec3(abs(grid_cell_pos.x), 0., abs(grid_cell_pos.y));
    
    // animate grid
    float t = 4.*u_time;
    float float_grid_num_cells = float(grid_num_cells/2);
    float quad_period = float_grid_num_cells * float_grid_num_cells;
    int xpos = 1+int(mod(t, float_grid_num_cells));
    xpos *= int(sign(1.-mod(t/quad_period, 2.)));
    int ypos = 1+int(mod(t/float_grid_num_cells, float_grid_num_cells));
    ypos *= int(sign(1.-mod(t/quad_period/2., 2.)));
    color = color * float(grid_cell_coord != ivec2(xpos,ypos));
    
    // draw grid
    color = max(color, draw_grid(grid_cell_pos));
    
	gl_FragColor = vec4(color, 1.0);
}


