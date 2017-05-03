#ifndef GRASS_CONFIG
#define GRASS_CONFIG

// ===================== Shader Defines =====================
// To keep the number of multi_compiles low, I put less frequent shader variants here. 
// This section will probably grow with future patches.

// Commenting this out, will remove grass displacement.
// This should probably be moved to a multicompile, but I don't think the
// performance difference is THAT big, so I'll leave it like this.
#define GRASS_DISPLACEMENT

// Uncomment this if you want the shader to support the Curved World asset by VacuumShaders
//#define GRASS_CURVED_WORLD
//#include "Assets/VacuumShaders/Curved World/Shaders/cginc/CurvedWorld_Base.cginc"

// ===================== Shader Settings =====================
// Here are settings that can't be changed with variables.

// Changes the maximum vertex count per blade of grass.
#define MAX_VERTEX_COUNT 14

#endif