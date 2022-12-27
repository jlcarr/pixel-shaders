# pixel-shaders
A collection of GLSL shaders for art. Presented with WebGL.

See the project in action [here](https://jcarr.ca/pixel-shaders).

## Details
Inspiration comes from The Book of Shader in style and presentation of these shaders.

Shaders are exceptionally fun and interesting because they are essentially just math equations that construct these beautiful, complex and information rich images.

### Shadwers Demoed
- **grid.glsl**: A simple demo showing my basic discrete grid setup. Grid coordinates for the x and y shown are [-3,-2,-1,1,2,3], and the black square runs x first before increasing y, and flips signs on x then y as well. Each cell also has coordinates for x an y [-1,1], shown in absolute value with red and blue respectively.
- **vector_field.glsl**: A demon of a vector field on a discrete grid. This one made from the gradient of a scalar field. Positive is red, and negative is blue.
- **vector_field_extended.glsl**: Similar to above, but showing arrows that can extend into neighboring cells.

## References
- https://thebookofshaders.com/
- https://www.khronos.org/files/webgl/webgl-reference-card-1_0.pdf
- https://viscircle.de/how-to-play-around-with-fragment-shaders-in-webgl/?lang=en
### Math
- https://en.wikipedia.org/wiki/Vector_field
- https://en.wikipedia.org/wiki/Conservative_vector_field
- https://en.wikipedia.org/wiki/Streamlines,_streaklines,_and_pathlines
