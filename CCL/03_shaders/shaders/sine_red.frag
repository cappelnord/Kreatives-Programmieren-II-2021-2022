void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    //mirror the sine's negative portion
    //float mod = abs(sin(iTime * 10.0));
    
    // scale sine to range (0-1)
    float mod = (sin(iTime * 10.0) * 0.5) + 0.5;
    
    vec3 col = vec3(mod, 0.0, 0.0);
    
    // mirror the sine's negative portion
    fragColor = vec4(col, 0.0);
}