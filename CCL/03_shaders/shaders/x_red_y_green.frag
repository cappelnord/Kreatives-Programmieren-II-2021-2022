void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
    
    // map x to red and y to green
    vec3 col = vec3(uv.x, uv.y, 1.0);

    fragColor = vec4(col, 0.0);
}