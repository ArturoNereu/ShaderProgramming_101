#ifndef VACUUM_CURVEDWORLD_SURFACE_CGINC
#define VACUUM_CURVEDWORLD_SURFACE_CGINC


#include "UnityCG.cginc"
#include "../cginc/CurvedWorld_Base.cginc"

////////////////////////////////////////////////////////////////////////////
//																		  //
//Variables 															  //
//																		  //
////////////////////////////////////////////////////////////////////////////
sampler2D _MainTex;
fixed4 _Color;
fixed2 _V_CW_MainTex_Scroll;

#ifdef V_CW_STANDARD
	half _Glossiness;     
	half _Metallic; 
#endif

#ifdef V_CW_SPECULAR
	half _Shininess;
#endif

#ifdef _NORMALMAP
	sampler2D _V_CW_NormalMap;
	half _V_CW_NormalMap_UV_Scale;
	half _V_CW_NormalMapStrength;
#endif

#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
	samplerCUBE _V_CW_Cube;
	fixed4 _V_CW_ReflectColor;
	fixed _V_CW_ReflectStrengthAlphaOffset;

	#ifdef V_CW_REFLECTIVE_FRESNEL
		half _V_CW_Fresnel_Power;
	#endif
#endif


#ifdef V_CW_RIM
	fixed4 _V_CW_Rim_Color;
	half _V_CW_Rim_Bias;
	half _V_CW_Rim_Power;
#endif

#ifdef _EMISSION
	sampler2D _EmissionMap;
	half4 _EmissionColor;
#endif


#if defined(V_CW_DECAL) || defined(V_CW_DETAIL) || defined(V_CW_BLEND_BY_VERTEX)
	sampler2D _V_CW_SecondaryTex;
	fixed2    _V_CW_SecondaryTex_Scroll;

	#ifdef V_CW_BLEND_BY_VERTEX
		fixed _V_CW_SecondaryTex_Blend;
	#endif

	#ifdef _NORMALMAP
		sampler2D _V_CW_SecondaryNormalMap;
		half _V_CW_SecondaryNormalMap_UV_Scale;
	#endif
#endif




#ifdef V_CW_TESSELATION		
	float _V_CW_Displace_Amount;
	sampler _V_CW_DisplaceTex;
	float _V_CW_DisplaceTex_UVScale;

	#ifdef V_CW_TESSELATION_DISTANCE
		float _V_CW_Tesselation;
		float _V_CW_Tesselation_Start;
		float _V_CW_Tesselation_End;
	#endif

	#ifdef V_CW_TESSELATION_EDGE_LENGTH
		float _V_CW_Tesselation_EdgeLength;
	#endif
#endif

struct appdata 
{
	float4 vertex : POSITION;
	float4 tangent : TANGENT; 
	float3 normal : NORMAL;
	float2 texcoord : TEXCOORD0;
	float2 texcoord1 : TEXCOORD1;
	float2 texcoord2 : TEXCOORD2;
};

struct Input 
{
	float2 uv_MainTex;

	#if defined(V_CW_DECAL) || defined(V_CW_DETAIL) || defined(V_CW_BLEND_BY_VERTEX)
		float2 uv_V_CW_SecondaryTex;
	#endif

	
	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX)
		float4 color : COLOR0;
	#endif

	#if defined(V_CW_RIM) || defined(V_CW_REFLECTIVE_FRESNEL)
		float3 viewDir;
	#endif

	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
		float3 worldRefl;
	#endif

	#if defined(_NORMALMAP) && (defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL))
		INTERNAL_DATA
	#endif
};

////////////////////////////////////////////////////////////////////////////
//																		  //
//Vertex    															  //
//																		  //
////////////////////////////////////////////////////////////z////////////////
void vert (inout appdata_full v, out Input o) 
{
	UNITY_INITIALIZE_OUTPUT(Input,o); 

	V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
}

#ifdef V_CW_TESSELATION	
void vertTess (inout appdata v) 
{	
	float d = tex2Dlod(_V_CW_DisplaceTex, float4(v.texcoord.xy * _V_CW_DisplaceTex_UVScale, 0, 0)).r * _V_CW_Displace_Amount;
	v.vertex.xyz += v.normal * d;

	V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
}

float4 tessFunc (appdata v0, appdata v1, appdata v2) 
{			
	#if defined(V_CW_TESSELATION_DISTANCE)
		return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, _V_CW_Tesselation_Start, _V_CW_Tesselation_End, _V_CW_Tesselation);
	#elif defined(V_CW_TESSELATION_EDGE_LENGTH)
		return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _V_CW_Tesselation_EdgeLength);
	#endif
}
#endif

////////////////////////////////////////////////////////////////////////////
//																		  //
//Surface    															  //
//																		  //
////////////////////////////////////////////////////////////////////////////
#ifdef V_CW_STANDARD
void surf (Input IN, inout SurfaceOutputStandard o)  
#else
void surf (Input IN, inout SurfaceOutput o) 
#endif
{
	fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex + _V_CW_MainTex_Scroll * _Time.x);
	
	#ifdef V_CW_DECAL
		fixed4 decal = tex2D(_V_CW_SecondaryTex, IN.uv_V_CW_SecondaryTex + _V_CW_SecondaryTex_Scroll.xy * _Time.x);
		mainTex = fixed4(lerp(mainTex.rgb, decal.rgb, decal.a), mainTex.a);
	#elif defined(V_CW_DETAIL)
		mainTex.rgb *= tex2D(_V_CW_SecondaryTex, IN.uv_V_CW_SecondaryTex + _V_CW_SecondaryTex_Scroll.xy * _Time.x).rgb * 2;
	#elif defined(V_CW_BLEND_BY_VERTEX)
		fixed vBlend = clamp(_V_CW_SecondaryTex_Blend + IN.color.a, 0, 1);
		mainTex = lerp(mainTex, tex2D(_V_CW_SecondaryTex, IN.uv_V_CW_SecondaryTex + _V_CW_SecondaryTex_Scroll.xy * _Time.x), vBlend);
	#endif

	
	o.Albedo = mainTex.rgb * _Color.rgb;
	#ifdef V_CW_VERTEX_COLOR
		o.Albedo *= IN.color.rgb;
	#endif

	o.Alpha = mainTex.a * _Color.a;


	#ifdef V_CW_STANDARD
		o.Metallic = _Metallic;
		o.Smoothness = _Glossiness * mainTex.a;
	#endif

	#ifdef V_CW_SPECULAR
		o.Gloss = mainTex.a;
		o.Specular = _Shininess;
	#endif

	#ifdef _NORMALMAP
		fixed4 normalMap = tex2D(_V_CW_NormalMap, IN.uv_MainTex * _V_CW_NormalMap_UV_Scale + _V_CW_MainTex_Scroll * _Time.x);

		#ifdef V_CW_DECAL
			fixed4 secondN =  tex2D(_V_CW_SecondaryNormalMap, IN.uv_V_CW_SecondaryTex * _V_CW_SecondaryNormalMap_UV_Scale + _V_CW_SecondaryTex_Scroll.xy * _Time.x);
			normalMap = lerp(normalMap, secondN, decal.a);		
		#elif defined(V_CW_DETAIL)
			fixed4 secondN =  tex2D(_V_CW_SecondaryNormalMap, IN.uv_V_CW_SecondaryTex * _V_CW_SecondaryNormalMap_UV_Scale + _V_CW_SecondaryTex_Scroll.xy * _Time.x);
			normalMap = (normalMap + secondN) * 0.5;	
		#elif defined(V_CW_BLEND_BY_VERTEX)
			fixed4 secondN =  tex2D(_V_CW_SecondaryNormalMap, IN.uv_V_CW_SecondaryTex * _V_CW_SecondaryNormalMap_UV_Scale + _V_CW_SecondaryTex_Scroll.xy * _Time.x);
			normalMap = lerp(normalMap, secondN, vBlend);		
		#endif

		o.Normal = UnpackNormal(normalMap);
		o.Normal = normalize(half3(o.Normal.x * _V_CW_NormalMapStrength, o.Normal.y * _V_CW_NormalMapStrength, o.Normal.z));
	#endif


	#if defined(V_CW_RIM) || defined(V_CW_REFLECTIVE_FRESNEL)
		half dotVN = max(0, dot (Unity_SafeNormalize(IN.viewDir), o.Normal));
	#endif


	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)

		#ifdef _NORMALMAP
			IN.worldRefl = WorldReflectionVector (IN, o.Normal);
		#endif

		fixed4 reflcol = texCUBE (_V_CW_Cube, IN.worldRefl);
		o.Emission = reflcol.rgb * _V_CW_ReflectColor.rgb * clamp(o.Alpha + _V_CW_ReflectStrengthAlphaOffset, 0, 1);;

		#ifdef V_CW_REFLECTIVE_FRESNEL
			o.Emission *= pow(1 - dotVN, _V_CW_Fresnel_Power);
		#endif
	#endif

	#ifdef _EMISSION
		o.Emission += tex2D(_EmissionMap, IN.uv_MainTex).rgb * _EmissionColor.rgb;
	#endif

	#ifdef V_CW_RIM
		half rim = pow(1 - dotVN, _V_CW_Rim_Power);		
		o.Emission = lerp(o.Emission, _V_CW_Rim_Color.rgb, rim);

		o.Albedo = lerp(o.Albedo, _V_CW_Rim_Color.rgb, rim);
	#endif
}

#endif 
