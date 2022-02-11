void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    
    // define two "centers"
    vec2 c1 = vec2(0.6 - uv.x, 0.6 - uv.y);
    vec2 c2 = vec2(0.4 - uv.x, 0.4 - uv.y);
        
    float dtoc1 = sqrt(pow(c1.x, 2.0) + pow(c1.y, 2.0));
    float dtoc2 = sqrt(pow(c2.x, 2.0) + pow(c2.y, 2.0));
    
    // peak & abyss
    float d = pow(dtoc1, dtoc2);
    
    vec3 col = vec3(d);

    fragColor = vec4(col, 1.0);
}