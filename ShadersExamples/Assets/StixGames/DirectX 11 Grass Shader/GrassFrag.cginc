#ifndef GRASS_FRAG
#define GRASS_FRAG

#ifdef UNITY_PASS_FORWARDBASE
fixed4 frag(FS_INPUT i) : SV_Target
{
	float3 worldPos = i.worldPos;

	#ifdef UNITY_COMPILER_HLSL
		SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
	#else
		SurfaceOutputStandardSpecular o;
	#endif

	o.Albedo = 0.0;
	o.Normal = i.normal;
	o.Emission = 0.0;
	o.Specular = 0;
	o.Smoothness = 1;
	o.Occlusion = 1.0;
	o.Alpha = 0.0;

	surf(i, o);

	fixed4 c = 0;

	#if defined(GRASS_UNLIT_LIGHTING)
		c = half4(o.Albedo, 1);
	#else //Not unlit
		UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

		UnityGI gi;
		UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
		gi.indirect.diffuse = 0;
		gi.indirect.specular = 0;
		#if !defined(LIGHTMAP_ON)
			gi.light.color = _LightColor0.rgb;
			gi.light.dir = i.lightDir;
			gi.light.ndotl = LambertTerm (o.Normal, gi.light.dir);
		#endif
		// Call GI (lightmaps/SH/reflections) lighting function
		UnityGIInput giInput;
		UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
		giInput.light = gi.light;
		giInput.worldPos = worldPos;
		giInput.worldViewDir = i.viewDir;
		giInput.atten = atten;
		#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
			giInput.lightmapUV = i.lmap;
		#else
			giInput.lightmapUV = 0.0;
		#endif
		#if UNITY_SHOULD_SAMPLE_SH
			giInput.ambient = i.sh;
		#else
			giInput.ambient.rgb = 0.0;
		#endif
			giInput.probeHDR[0] = unity_SpecCube0_HDR;
			giInput.probeHDR[1] = unity_SpecCube1_HDR;
		#if UNITY_SPECCUBE_BLENDING || UNITY_SPECCUBE_BOX_PROJECTION
			giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
		#endif
		#if UNITY_SPECCUBE_BOX_PROJECTION
			giInput.boxMax[0] = unity_SpecCube0_BoxMax;
			giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
			giInput.boxMax[1] = unity_SpecCube1_BoxMax;
			giInput.boxMin[1] = unity_SpecCube1_BoxMin;
			giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
		#endif
		LightingStandardSpecular_GI(o, giInput, gi);
		
		gi.light.color *= atten;
		c = GrassLightingStandardSpecular(o, i.viewDir, gi);

		//#if defined(GRASS_PBR_LIGHTING)
		//	//Fix normals for reflection, the lighting won't work, because I am faking a lot of it...
		//	o.Normal = i.reflectionNormal;

		//	// realtime lighting: call lighting function
		//	c = LightingStandardSpecular(o, i.viewDir, gi);
		//#else //Use fake lighting
		//	//Taken from LightingStandardSpecular
		//	half oneMinusReflectivity;
		//	o.Albedo = EnergyConservationBetweenDiffuseAndSpecular(o.Albedo, o.Specular, /*out*/ oneMinusReflectivity);

		//	// shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
		//	// this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
		//	half outputAlpha;
		//	o.Albedo = PreMultiplyAlpha(o.Albedo, o.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

		//	c = FakeGrassLighting(o.Albedo, o.Specular, oneMinusReflectivity, o.Smoothness, o.Normal, i.viewDir, gi.light, gi.indirect);
		//	c.rgb += UNITY_BRDF_GI(o.Albedo, o.Specular, oneMinusReflectivity, o.Smoothness, o.Normal, i.viewDir, o.Occlusion, gi);
		//	c.a = outputAlpha;
		//#endif
	#endif //End not unlit block

	UNITY_APPLY_FOG(i.fogCoord, c); // apply fog
	UNITY_OPAQUE_ALPHA(c.a);
	return c;
}
#endif

#ifdef UNITY_PASS_FORWARDADD
fixed4 frag(FS_INPUT i) : SV_Target
{
	float3 worldPos = i.worldPos;

	#ifdef UNITY_COMPILER_HLSL
		SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
	#else
		SurfaceOutputStandardSpecular o;
	#endif

	o.Albedo = 0.0;
	o.Normal = i.normal;
	o.Emission = 0.0;
	o.Specular = 0;
	o.Smoothness = 0.5;
	o.Occlusion = 1.0;
	o.Alpha = 0.0;

	surf(i, o);

	fixed4 c = 0;

	#if !defined(GRASS_UNLIT_LIGHTING)
		UNITY_LIGHT_ATTENUATION(atten, i, worldPos)

		// Setup lighting environment
		UnityGI gi;
		UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
		gi.indirect.diffuse = 0;
		gi.indirect.specular = 0;
		#if !defined(LIGHTMAP_ON)
			gi.light.color = _LightColor0.rgb;
			gi.light.dir = i.lightDir;
			gi.light.ndotl = LambertTerm (o.Normal, gi.light.dir);
		#endif
		gi.light.color *= atten;

		c = GrassLightingStandardSpecular(o, i.viewDir, gi);

		//#if defined(GRASS_PBR_LIGHTING)
		//	//Fix normals for reflection, the lighting won't work, because I am faking a lot of it...
		//	o.Normal = i.reflectionNormal;

		//	// realtime lighting: call lighting function
		//	c = LightingStandardSpecular(o, i.viewDir, gi);
		//#else //Use fake lighting
		//	//Taken from LightingStandardSpecular
		//	half oneMinusReflectivity;
		//	o.Albedo = EnergyConservationBetweenDiffuseAndSpecular(o.Albedo, o.Specular, /*out*/ oneMinusReflectivity);

		//	c = FakeGrassLighting(o.Albedo, o.Specular, oneMinusReflectivity, o.Smoothness, o.Normal, i.viewDir, gi.light, gi.indirect);
		//	c.rgb += UNITY_BRDF_GI(o.Albedo, o.Specular, oneMinusReflectivity, o.Smoothness, o.Normal, i.viewDir, o.Occlusion, gi);
		//	c.a = 1;
		//#endif
	#endif

	c.a = 0.0;

	UNITY_APPLY_FOG(i.fogCoord, c); // apply fog
	UNITY_OPAQUE_ALPHA(c.a);
	return c;
}
#endif

#ifdef UNITY_PASS_SHADOWCASTER
fixed4 frag(FS_INPUT i) : SV_Target
{
	// prepare and unpack data
	#ifdef UNITY_COMPILER_HLSL
		SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
	#else
		SurfaceOutputStandardSpecular o;
	#endif
	fixed3 normalWorldVertex = fixed3(0, 0, 1);
	o.Albedo = 0.0;
	o.Normal = normalWorldVertex;
	o.Emission = 0.0;
	o.Specular = 0;
	o.Smoothness = 1;
	o.Occlusion = 1.0;
	o.Alpha = 0.0;

	// call surface function
	surf(i, o);

	SHADOW_CASTER_FRAGMENT(i)
}
#endif

#ifdef RENDER_NORMAL_DEPTH
fixed4 frag(FS_INPUT i) : SV_Target
{
	// prepare and unpack data
	#ifdef UNITY_COMPILER_HLSL
		SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
	#else
		SurfaceOutputStandardSpecular o;
	#endif
	fixed3 normalWorldVertex = fixed3(0, 0, 1);
	o.Albedo = 0.0;
	o.Normal = normalWorldVertex;
	o.Emission = 0.0;
	o.Specular = 0;
	o.Smoothness = 1;
	o.Occlusion = 1.0;
	o.Alpha = 0.0;

	// call surface function, here it handles the cutoff
	surf(i, o);

	float depth = -(mul(UNITY_MATRIX_V, float4(i.worldPos, 1)).z * _ProjectionParams.w);
	float3 normal = i.normal;
	normal.b = 0;
	return EncodeDepthNormal(depth, normal);
}
#endif

#endif