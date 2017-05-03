#ifndef VACUUM_CURVEDWORLD_FORWARDBASE_CGINC
#define VACUUM_CURVEDWORLD_FORWARDBASE_CGINC

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "../cginc/CurvedWorld_Base.cginc"
#include "../cginc/CurvedWorld_Functions.cginc"

//Defines/////////////////////////////////////////////////////////////
#ifdef _NORMALMAP
	#define V_CW_LIGHTDIR i.lightDir
#else
	#define V_CW_LIGHTDIR _WorldSpaceLightPos0.xyz
#endif

#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL) || (defined(V_CW_SPECULAR) && !defined(_NORMALMAP))
	#define V_CW_V_NEED_VIEWDIR_WS
#endif
#if defined(V_CW_REFLECTIVE_FRESNEL) || defined(V_CW_RIM) || (defined(V_CW_SPECULAR) && defined(_NORMALMAP))
	#define V_CW_V_NEED_VIEWDIR_OS
#endif


//FUCK YOU -> d3d11_9x
#ifdef SHADER_API_D3D11_9X
	#ifndef LIGHTMAP_ON
			
		#if (defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)) && defined(V_CW_FOG) && (defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL))
			#ifdef V_CW_SPECULAR
			#undef V_CW_SPECULAR
			#endif
		#endif
		#if (defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)) && defined(_NORMALMAP) && (defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL))
			#ifdef V_CW_SPECULAR
			#undef V_CW_SPECULAR
			#endif
		#endif

	#endif
#endif

//Variables/////////////////////////////////////////////////////////////
fixed4 _Color;
sampler2D _MainTex;
float4 _MainTex_ST;
fixed2 _V_CW_MainTex_Scroll;

#ifdef V_CW_USE_LIGHT_RAMP_TEXTURE
	sampler2D _V_CW_LightRampTex;
#endif

#ifdef _NORMALMAP
	sampler2D _V_CW_NormalMap;
	half _V_CW_NormalMap_UV_Scale;
	half _V_CW_NormalMapStrength;
#endif

#ifdef V_CW_SPECULAR
	fixed _V_CW_Specular_Intensity;
	fixed _V_CW_SpecularOffset;
	sampler2D _V_CW_Specular_Lookup;
#endif

#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
	samplerCUBE _V_CW_Cube;
	fixed4 _V_CW_ReflectColor;
	fixed _V_CW_ReflectStrengthAlphaOffset;

	#ifdef V_CW_REFLECTIVE_FRESNEL
		half _V_CW_Fresnel_Bias;
	#endif
#endif


#if defined(V_CW_DECAL) || defined(V_CW_DETAIL) || defined(V_CW_BLEND_BY_VERTEX)
	sampler2D _V_CW_SecondaryTex;
	half4 _V_CW_SecondaryTex_ST;
	fixed2 _V_CW_SecondaryTex_Scroll;

	#ifdef V_CW_BLEND_BY_VERTEX
		fixed _V_CW_SecondaryTex_Blend;
	#endif

	#ifdef _NORMALMAP
		sampler2D _V_CW_SecondaryNormalMap;
		half _V_CW_SecondaryNormalMap_UV_Scale;
	#endif
#endif


#ifdef V_CW_CUTOUT
	half _Cutoff;
#endif

#ifdef _EMISSION
	sampler2D _EmissionMap;
	half4 _EmissionColor;
#endif

#ifdef V_CW_RIM
	fixed4 _V_CW_Rim_Color;
	fixed  _V_CW_Rim_Bias;
#endif


//Structs///////////////////////////////////////////////////////////////
struct vInput
{
	float4 vertex : POSITION;   

	float4 texcoord : TEXCOORD0;

	#ifndef LIGHTMAP_OFF
		float4 texcoord1 : TEXCOORD1;
	#endif

	float3 normal : NORMAL;

	float4 tangent : TANGENT;

	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)
		fixed4 color : COLOR0;
	#endif
};

struct vOutput
{
	float4 pos : SV_POSITION;
	half4 texcoord : TEXCOORD0;

	half4 normal : TEXCOORD1; //xyz - normal, w - rim

	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
		half4 refl : TEXCOORD2;	//xyz - refl, w - fresnel
	#endif


	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)
		float4 color : COLOR0;
	#endif

	
	#ifdef V_CW_FOG
		UNITY_FOG_COORDS(3)
	#endif


	#ifndef LIGHTMAP_OFF
		half2 lm : TEXCOORD4;
	#else
		half4 vLight : TEXCOORD4;

		#ifdef V_CW_SPECULAR
			half4 viewDir : TEXCOORD5;	//xyz - viewdir, w - specular(nh)
		#endif

		#ifdef _NORMALMAP
			half3 lightDir : TEXCOORD6;
		#endif	

		SHADOW_COORDS(7)
	#endif
};

//Vertex////////////////////////////////////////////////////////////////
vOutput vert(vInput v)
{ 
	vOutput o;
	UNITY_INITIALIZE_OUTPUT(vOutput,o); 

		
	#ifndef LIGHTMAP_OFF
		#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
			V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);	
		#else
			V_CW_TransformPoint(v.vertex);	
		#endif
	#else
		V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);	
	#endif
	o.pos = UnityObjectToClipPos(v.vertex);


	o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
	o.texcoord.xy += _V_CW_MainTex_Scroll.xy * _Time.x;


	#if defined(V_CW_DECAL) || defined(V_CW_DETAIL) || defined(V_CW_BLEND_BY_VERTEX)
		o.texcoord.zw = v.texcoord.xy * _V_CW_SecondaryTex_ST.xy + _V_CW_SecondaryTex_ST.zw;
		o.texcoord.zw += _V_CW_SecondaryTex_Scroll.xy * _Time.x;
	#endif
	


	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)
		o.color = v.color;
	#endif
	

	float3 normal_WS = UnityObjectToWorldNormal(v.normal);
	
	#ifdef V_CW_V_NEED_VIEWDIR_WS
		float3 viewDir_WS = WorldSpaceViewDir(v.vertex);
	#endif
	#ifdef V_CW_V_NEED_VIEWDIR_OS
		float3 viewDir_OS = normalize(ObjSpaceViewDir(v.vertex));
	#endif

	
	#ifndef LIGHTMAP_OFF
		o.lm = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	#else
		
		#ifdef UNITY_SHOULD_SAMPLE_SH
			#ifdef V_CW_INCLUDE_SPH_AND_AMBIENT
				o.vLight.rgb = ShadeSH9 (half4(normal_WS, 1.0));
			#else
				o.vLight = half4(0, 0, 0, 0);
			#endif
		
			#if defined(VERTEXLIGHT_ON) && defined(V_CW_INCLUDE_PER_VERTEX_POINT_LIGHTS)	
				float3 pos_WS = mul(unity_ObjectToWorld, v.vertex).xyz;
			
				o.vLight.rgb += Shade4PointLights ( unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
					 							   unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
												   unity_4LightAtten0, pos_WS, normal_WS );
			#endif
		#endif


		#ifdef V_CW_CALCULATE_LIGHT_PER_PIXEL
			#ifdef _NORMALMAP
				TANGENT_SPACE_ROTATION;

				o.lightDir = normalize(mul (rotation, ObjSpaceLightDir(v.vertex)));

				#ifdef V_CW_SPECULAR
					o.viewDir.xyz = mul (rotation, viewDir_OS);
				#endif
			#else
				#ifdef V_CW_SPECULAR
					o.viewDir.xyz = viewDir_WS;
				#endif
			#endif
		#else
			o.vLight.a = max(0, dot (normal_WS, _WorldSpaceLightPos0.xyz));	
			 
			#ifdef V_CW_SPECULAR
				o.viewDir.w = max (0, dot(normal_WS, normalize(_WorldSpaceLightPos0.xyz + normalize(viewDir_WS))));
				o.viewDir.w = clamp(o.viewDir.w + _V_CW_SpecularOffset, 0, 1);
			#endif
		#endif
	#endif
		

	o.normal.xyz = normal_WS;


	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)		
		o.refl.xyz = normalize(reflect(-viewDir_WS, normal_WS));

		#ifdef V_CW_REFLECTIVE_FRESNEL
			half fresnel = 1 - saturate(dot (v.normal, viewDir_OS) + _V_CW_Fresnel_Bias);
			o.refl.w = fresnel * fresnel;
		#endif
	#endif

	#ifdef V_CW_RIM
		half rim = saturate(dot (normalize(v.normal), viewDir_OS) + _V_CW_Rim_Bias);
		o.normal.w = rim * rim;
	#endif	
	
	#ifdef LIGHTMAP_OFF
		TRANSFER_SHADOW(o);
	#endif
	#ifdef V_CW_FOG
		UNITY_TRANSFER_FOG(o,o.pos); 
	#endif

	return o;
} 
 

//Fragment//////////////////////////////////////////////////////////////
fixed4 frag (vOutput i) : SV_Target
{
	half4 mainTex = tex2D(_MainTex, i.texcoord.xy);

	#ifdef V_CW_DECAL
		fixed4 decal = tex2D(_V_CW_SecondaryTex, i.texcoord.zw);
		fixed4 retColor = fixed4(lerp(mainTex.rgb, decal.rgb, decal.a), mainTex.a);
	#elif defined(V_CW_DETAIL)
		fixed4 retColor = mainTex;
		retColor.rgb *= tex2D(_V_CW_SecondaryTex, i.texcoord.zw).rgb * 2;
	#elif defined(V_CW_BLEND_BY_VERTEX)
		fixed vBlend = clamp(_V_CW_SecondaryTex_Blend + i.color.a, 0, 1);
		fixed4 retColor = lerp(mainTex, tex2D(_V_CW_SecondaryTex, i.texcoord.zw), vBlend);
	#else
		fixed4 retColor = mainTex;
	#endif

	retColor *= _Color;

	#ifdef V_CW_VERTEX_COLOR
		retColor *= i.color;
	#endif 
	 

	#if defined(V_CW_CUTOUT)
		clip(retColor.a - _Cutoff);	
	#elif defined(V_CW_COUTOUT_SOFTEDGE)
		clip(-(retColor.a - _Cutoff));		
	#endif

	
	#ifdef _NORMALMAP
		fixed4 normalMap = tex2D(_V_CW_NormalMap, i.texcoord.xy * _V_CW_NormalMap_UV_Scale);				

		#ifdef V_CW_DECAL
			fixed4 secondN =  tex2D(_V_CW_SecondaryNormalMap, i.texcoord.zw *_V_CW_SecondaryNormalMap_UV_Scale);
			normalMap = lerp(normalMap, secondN, decal.a);		
		#elif defined(V_CW_DETAIL)
			fixed4 secondN =  tex2D(_V_CW_SecondaryNormalMap, i.texcoord.zw *_V_CW_SecondaryNormalMap_UV_Scale);
			normalMap = (normalMap + secondN) * 0.5;	
		#elif defined(V_CW_BLEND_BY_VERTEX)
			fixed4 secondN =  tex2D(_V_CW_SecondaryNormalMap, i.texcoord.zw *_V_CW_SecondaryNormalMap_UV_Scale);
			normalMap = lerp(normalMap, secondN, vBlend);		
		#endif

		fixed3 bumpNormal = UnpackNormal(normalMap);
		bumpNormal =  normalize(fixed3(bumpNormal.x * _V_CW_NormalMapStrength, bumpNormal.y * _V_CW_NormalMapStrength, bumpNormal.z));
	#endif
	

	
	#ifndef LIGHTMAP_OFF
		fixed3 diff = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lm));
	#else
		fixed atten = LIGHT_ATTENUATION(i);

		#ifdef V_CW_CALCULATE_LIGHT_PER_PIXEL			
			#ifdef _NORMALMAP
				half3 normal = bumpNormal;				
			#else
				half3 normal = normalize(i.normal.xyz);
			#endif
		
			fixed3 diff = _LightColor0.rgb * atten;

			#ifdef V_CW_USE_LIGHT_RAMP_TEXTURE
				fixed2 rampUV = fixed2(max(0, dot(normal, V_CW_LIGHTDIR)), 0.5);
				diff *= tex2D(_V_CW_LightRampTex, rampUV);
			#else
				diff *= max(0, dot(normal, V_CW_LIGHTDIR));
			#endif
				
			#ifndef V_CW_INCLUDE_SPH_AND_AMBIENT
				diff += UNITY_LIGHTMODEL_AMBIENT.xyz;
			#endif
						
			#ifdef V_CW_SPECULAR  
				half nh = max (0, dot (normal, normalize (V_CW_LIGHTDIR + normalize(i.viewDir.xyz))));
				fixed3 specular = tex2D(_V_CW_Specular_Lookup, half2(clamp(nh + _V_CW_SpecularOffset, 0, 1), 0.5)).rgb * retColor.a * _LightColor0.rgb * atten * _V_CW_Specular_Intensity;
			#endif

		#else
			fixed3 diff = _LightColor0.rgb * atten;

			#ifdef V_CW_USE_LIGHT_RAMP_TEXTURE
				fixed2 rampUV = fixed2(i.vLight.a, 0.5);
				diff *= tex2D(_V_CW_LightRampTex, rampUV);
			#else
				diff *=  i.vLight.a;
			#endif

			#ifndef V_CW_INCLUDE_SPH_AND_AMBIENT
				diff += UNITY_LIGHTMODEL_AMBIENT.xyz;
			#endif

			#ifdef V_CW_SPECULAR
				fixed3 specular = tex2D(_V_CW_Specular_Lookup, half2(i.viewDir.w, 0.5)).rgb * retColor.a * _LightColor0.rgb * atten * _V_CW_Specular_Intensity;
			#endif								
		#endif	
		
		#if defined(V_CW_INCLUDE_SPH_AND_AMBIENT) || defined(V_CW_INCLUDE_PER_VERTEX_POINT_LIGHTS)
			diff += i.vLight.rgb;
		#endif	
	#endif
		
				
	retColor.rgb = diff * retColor.rgb;		


	#ifndef LIGHTMAP_OFF
	#else
		#if defined(V_CW_SPECULAR)
			retColor.rgb += specular;
		#endif
	#endif

	
	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
		#ifdef _NORMALMAP
			fixed4 reflTex = texCUBE( _V_CW_Cube, i.refl.xyz + bumpNormal) * _V_CW_ReflectColor;
		#else
			fixed4 reflTex = texCUBE( _V_CW_Cube, i.refl.xyz ) * _V_CW_ReflectColor;
		#endif

		#ifdef V_CW_REFLECTIVE_FRESNEL
			retColor.rgb += reflTex.rgb * i.refl.w * clamp(retColor.a + _V_CW_ReflectStrengthAlphaOffset, 0, 1);
		#else
			retColor.rgb += reflTex.rgb * clamp(retColor.a + _V_CW_ReflectStrengthAlphaOffset, 0, 1);
		#endif
	#endif
	
	#ifdef _EMISSION
		retColor.rgb += tex2D(_EmissionMap, i.texcoord.xy).rgb * _EmissionColor.rgb;
	#endif

	#ifdef V_CW_RIM
		retColor.rgb = lerp(_V_CW_Rim_Color.rgb, retColor.rgb, i.normal.w);
	#endif
	


	#ifdef V_CW_FOG
		UNITY_APPLY_FOG(i.fogCoord, retColor); 
	#endif


	#if defined(V_CW_TRANSPARENT) || defined(V_CW_CUTOUT)
		//Empty
	#else
		UNITY_OPAQUE_ALPHA(retColor.a);
	#endif

	return retColor;
}


#endif