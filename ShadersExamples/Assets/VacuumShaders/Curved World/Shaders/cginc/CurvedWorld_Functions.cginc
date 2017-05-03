#ifndef VACUUM_CURVEDWORLD_FUNCTIONS_CGINC
#define VACUUM_CURVEDWORLD_FUNCTIONS_CGINC


#include "UnityCG.cginc"

#define V_UNPACK_IBL(n) ((texCUBE(_V_CW_IBL_Cube, n).rgb - 0.5) * _V_CW_IBL_Contrast + 0.5) * _V_CW_IBL_Intensity

inline half V_DotClamped (half3 a, half3 b)
{
	#if (SHADER_TARGET < 30)
		return saturate(dot(a, b));
	#else
		return max(0.0f, dot(a, b));
	#endif
}

inline half3 V_DecodeDirectionalSpecularLightmap (half3 color, fixed4 dirTex, half3 normalWorld)
{	
	half3 dir = dirTex.xyz * 2 - 1;

	half directionality = length(dir);
	dir /= directionality;	

	
	half ndotl = V_DotClamped(normalWorld, dir);

	return color * (1 - directionality) * ndotl;
}

inline fixed3 V_DecodeLightmap (half2 lmUV, half3 normalWorld)
{
	fixed3 diffuse = 0;

	// Baked lightmaps
	fixed4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, lmUV); 
	half3 bakedColor = DecodeLightmap(bakedColorTex);
		
	#ifdef DIRLIGHTMAP_OFF
		diffuse = bakedColor;

	#elif DIRLIGHTMAP_COMBINED
		fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER (unity_LightmapInd, unity_Lightmap, lmUV);
		diffuse = DecodeDirectionalLightmap (bakedColor, bakedDirTex, normalWorld);

	#elif DIRLIGHTMAP_SEPARATE
		// Left halves of both intensity and direction lightmaps store direct light; right halves - indirect.

		// Direct
		fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, lmUV);
		diffuse += V_DecodeDirectionalSpecularLightmap (bakedColor, bakedDirTex, normalWorld);

		// Indirect
		half2 uvIndirect = lmUV + half2(0.5, 0);
		bakedColor = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uvIndirect));
		bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, uvIndirect);
		diffuse += V_DecodeDirectionalSpecularLightmap (bakedColor, bakedDirTex, normalWorld);
	#endif

	return diffuse;
}



#endif 
