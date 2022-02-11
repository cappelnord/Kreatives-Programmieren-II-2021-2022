#define PI 3.14159265

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
    
    // modulate sine frequency with the sine of iTime
    float f = (sin(iTime) * 9.0) + 1.0;
    
    // sine function scaled to (0-1)
    float sine = (sin(uv.x * f * 2.0 * PI) * 0.5) + 0.5;
    
    // map sine to blue
    vec3 col = vec3(0.0, 0.0, sine);
    
    fragColor = vec4(col, 0.0);
}