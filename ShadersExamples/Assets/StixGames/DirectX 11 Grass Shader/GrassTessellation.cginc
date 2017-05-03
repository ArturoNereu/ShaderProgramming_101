#ifndef GRASS_TESSELLATION
#define GRASS_TESSELLATION

// ==================================== Tessellation Amount Functions ===================================
float CalcTessFactor (float3 wpos0, float3 wpos1)
{
	// distance to edge center
	fixed dist = distance (0.5 * (wpos0+wpos1), _WorldSpaceCameraPos);
	// length of the edge
	fixed len = distance(wpos0, wpos1);
	// edgeLen is approximate desired size in pixels
	return min(max(len * _ScreenParams.y / (_EdgeLength * dist), 1.0), pow(2,_MaxTessellation));
}

fixed EdgeLengthBasedTessCull (float4 v0, float4 v1, float4 v2)
{
	fixed4 tess;

	if (UnityWorldViewFrustumCull(v0, v1, v2, _MaxHeight00))
	{
		tess = 0.0f;
	}
	else
	{
		tess.x = CalcTessFactor(v1, v2);
		tess.y = CalcTessFactor(v2, v0);
		tess.z = CalcTessFactor(v0, v1);
		tess.w = (tess.x + tess.y + tess.z)*0.33333f;
	}
	return tess.w;
}

// ==================================== The actual tessellation happens here ====================================
HS_CONSTANT_OUTPUT HSConstant(InputPatch<appdata, 3> ip, uint pid : SV_PrimitiveID )
{
	HS_CONSTANT_OUTPUT o;
	fixed rTess = EdgeLengthBasedTessCull(ip[0].vertex, ip[1].vertex, ip[2].vertex);
	fixed tess = nextPow2(rTess);
	o.edges[0] = tess; 
	o.edges[1] = tess; 
	o.edges[2] = tess; 
	o.inside  = tess;
	o.realTess = rTess;
	return o;
}

[UNITY_domain("tri")]
[UNITY_partitioning("integer")]
[UNITY_outputtopology("point")]
[UNITY_patchconstantfunc("HSConstant")]
[UNITY_outputcontrolpoints(3)]
tess_appdata hullShader(InputPatch<appdata, 3> ip, uint cpid : SV_OutputControlPointID, uint pid : SV_PrimitiveID)
{
	tess_appdata o;
	appdata i = ip[cpid];
	o.vertex = i.vertex;
#ifdef VERTEX_DENSITY
	o.color = i.color;
#endif

#ifdef GRASS_FOLLOW_SURFACE_NORMAL
	o.normal = i.normal;
#endif

	o.uv = i.uv;
	o.lod = i.lod;
	o.cameraPos = i.cameraPos;
	o.lightDir = i.lightDir;

#ifdef GRASS_OBJECT_MODE
	o.objectSpacePos = i.objectSpacePos;
#endif

	return o;
}

bool IsTessFromNextPow2(float nearVal1, float farVal, float tess)
{
	float farTess = farVal * (3 * (tess*0.5f));
	float nearTess = nearVal1 * (3 * (tess));

	return abs(nearTess - round(nearTess)) > 0.1f || abs(farTess - round(farTess)) > 0.1f;
}

//From http://www.blackpawn.com/texts/pointinpoly/
bool PointInTriangle(float3 p, float3 a, float3 b, float3 c)
{
	float3 v0 = c - a;
	float3 v1 = b - a;
	float3 v2 = p - a;

	// Compute dot products
	float dot00 = dot(v0, v0);
	float dot01 = dot(v0, v1);
	float dot02 = dot(v0, v2);
	float dot11 = dot(v1, v1);
	float dot12 = dot(v1, v2);

	// Compute barycentric coordinates
	float invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
	float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
	float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

	// Check if point is in triangle, while not completely correct, this includes points that are almost part of the triangle, which leads to better results
	return (u >= -0.01f) && (v >= -0.01f) && (u + v < 1.01);
}

fixed SmoothingInterpolation(float3 pos, fixed prevTess, fixed realTess)
{
	//The smoothing is just a linear interpolation between the tesselation levels
	fixed smoothing = (realTess - prevTess) / prevTess;

	//For height smoothing the smoothing will be randomized to look less regular
	//With width smoothing this isn't necessary, so a bit of performance will be saved
#ifdef GRASS_HEIGHT_SMOOTHING
	fixed r = rand(float2(pos.x + 97869, pos.z + 152));

	//remap the random value so its always between 0.25 and 0.75
	r = r * 0.5f + 0.25f;

	return pow(smoothing, r);
#else
	return smoothing;
#endif
}

[UNITY_domain("tri")]
GS_INPUT domainShader(HS_CONSTANT_OUTPUT input, float3 tLoc : SV_DomainLocation, const OutputPatch<tess_appdata, 3> patch)
{
	GS_INPUT output;

	fixed prevTess = input.inside*0.5;
	fixed realTess = input.realTess;

	float3 vx = patch[0].vertex.xyz;
	float3 vy = patch[1].vertex.xyz;
	float3 vz = patch[2].vertex.xyz;

	// Determine the position of the new vertex, to use as seed for the random offset
	float3 vertexPosition = tLoc.x * vx + 
							tLoc.y * vy + 
							tLoc.z * vz;

	//In object mode all random calculations are done in object space
#ifdef GRASS_OBJECT_MODE
	float3 randCalcPos = tLoc.x * patch[0].objectSpacePos.xyz +
						 tLoc.y * patch[1].objectSpacePos.xyz +
						 tLoc.z * patch[2].objectSpacePos.xyz;

	output.objectSpacePos = randCalcPos;
#else
	float3 randCalcPos = vertexPosition;
#endif

#if defined(GRASS_HEIGHT_SMOOTHING) || defined(GRASS_WIDTH_SMOOTHING)
	float3 mid = (vx + vy + vz) / 3.0f;

	//Check if the blade of grass should be faded in or not
	if (PointInTriangle(vertexPosition, mid, vy, vz))
	{
		//Get the percentage to the next power of two
		output.smoothing = IsTessFromNextPow2(tLoc.y, tLoc.x, prevTess) ? SmoothingInterpolation(randCalcPos, prevTess, realTess) : 1;
	}
	else if (PointInTriangle(vertexPosition, mid, vx, vz))
	{
		//Get the percentage to the next power of two
		output.smoothing = IsTessFromNextPow2(tLoc.x, tLoc.y, prevTess) ? SmoothingInterpolation(randCalcPos, prevTess, realTess) : 1;
	}
	else if (PointInTriangle(vertexPosition, mid, vx, vy))
	{
		//Get the percentage to the next power of two
		output.smoothing = IsTessFromNextPow2(tLoc.x, tLoc.z, prevTess) ? SmoothingInterpolation(randCalcPos, prevTess, realTess) : 1;
	}
#else
	output.smoothing = 1;
#endif

	//Select a random point in the triangle
	float r1 = sqrt(rand(randCalcPos.xz + float2(8888,-5300)));
	float r2 = rand(randCalcPos.xz + float2(4400,2000));
	tLoc = float3((1-r1), (r1*(1-r2)), (r2*r1));

	//Set the real position
	float3 realVertexPos =	tLoc.x * vx + 
							tLoc.y * vy + 
							tLoc.z * vz;

	output.position = float4(realVertexPos, 1);

#ifdef VERTEX_DENSITY
	//Interpolate vertex color
	output.color =	tLoc.x * patch[0].color + 
					tLoc.y * patch[1].color + 
					tLoc.z * patch[2].color;
#endif

	//Set the uv coordinates
	output.uv = tLoc.x * patch[0].uv + 
				tLoc.y * patch[1].uv + 
				tLoc.z * patch[2].uv;

	//Push through variables
	output.lod = max(max(patch[0].lod, patch[1].lod), patch[2].lod);
	output.lightDir = patch[0].lightDir;
	output.cameraPos = patch[0].cameraPos;

#ifdef GRASS_FOLLOW_SURFACE_NORMAL
	output.normal = tLoc.x * patch[0].normal +
					tLoc.y * patch[1].normal +
					tLoc.z * patch[2].normal;
#endif

	return output;  
}
#endif