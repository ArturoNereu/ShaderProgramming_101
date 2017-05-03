// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#ifndef GRASS_VERTEX
#define GRASS_VERTEX

appdata vert(appdata v)
{
	#ifdef GRASS_OBJECT_MODE
		v.objectSpacePos = v.vertex.xyz;
	#endif

	v.vertex = mul(unity_ObjectToWorld, v.vertex);
	v.uv = TRANSFORM_TEX(v.uv, _Density);

	//v.color doesn't have to be changed.

	#ifdef GRASS_FOLLOW_SURFACE_NORMAL
		v.normal = UnityObjectToWorldNormal(v.normal);
	#endif

	//Camera, or rather renderer pos
	v.cameraPos = getCameraPos();

	//LOD
	fixed dist = distance(v.vertex.xyz, v.cameraPos);
	fixed lod = max(smoothstep(_LODEnd, _LODStart, dist)*_LODMax, 1);
	
	v.lod = lod;

	#ifdef USING_DIRECTIONAL_LIGHT
		v.lightDir = normalize(_WorldSpaceLightPos0.xyz);
	#else
		v.lightDir = 0;
	#endif

	return v;
}
#endif