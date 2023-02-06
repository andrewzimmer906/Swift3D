//
//  SimpleNoise.hpp
//  
//
//  Created by Andrew Zimmer on 2/6/23.
//

#ifndef SimpleNoise
#define SimpleNoise

class SimplexNoise {
public:
    // 3D Perlin simplex noise
    static float noise(float3 in);

    // More complex 3D noise using multiple "octaves"
    static float fractal(size_t octaves, float3 in, float freq, float amp, float lac, float per);
};
#endif /* SimpleNoise */
