#ifndef VACUUM_CURVEDWORLD_UNLIT_CGINC
#define VACUUM_CURVEDWORLD_UNLIT_CGINC

#include "UnityCG.cginc"
#include "../cginc/CurvedWorld_Base.cginc"
#include "../cginc/CurvedWorld_Functions.cginc"

//Defines///////////////////////////////////////////////////////////////
#if !defined(V_CW_REFLECTIVE) && !defined(V_CW_REFLECTIVE_FRESNEL) && !defined(V_CW_IBL_CUBE) && !defined(V_CW_IBL_MATCAP)
	#ifdef _NORMALMAP
	#undef _NORMALMAP
	#endif
#endif


//Variables/////////////////////////////////////////////////////////////
fixed4 _Color;
sampler2D _MainTex;
half4 _MainTex_ST;
fixed2 _V_CW_MainTex_Scroll;


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

#if defined(V_CW_IBL_CUBE)

	half _V_CW_IBL_Intensity;
	half _V_CW_IBL_Contrast;
	samplerCUBE _V_CW_IBL_Cube;	

#elif defined (V_CW_IBL_MATCAP)

	sampler2D _V_CW_IBL_Matcap;
	half _V_CW_IBL_Intensity;

#endif

//Structs///////////////////////////////////////////////////////////////
struct vInput
{
	float4 vertex : POSITION;
    
	float4 texcoord : TEXCOORD0;

	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL) || defined(V_CW_RIM) || defined(V_CW_IBL_CUBE) || defined(V_CW_IBL_MATCAP)
		float3 normal : NORMAL;
	#endif

	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL) || defined(V_CW_IBL_CUBE) || (defined(V_CW_IBL_MATCAP) && defined(_NORMALMAP))
		float4 tangent : TANGENT;
	#endif

	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)
		fixed4 color : COLOR;
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

	UNITY_FOG_COORDS(3)

	#ifdef V_CW_IBL_MATCAP
		#ifdef _NORMALMAP
			float3 matcapTan : TEXCOORD4; 
			float3 matcapBiN : TEXCOORD5; 
		#else
			float2 matcap : TEXCOORD4; 
		#endif
	#endif

	#if defined(V_CW_VERTEX_COLOR) || defined(V_CW_BLEND_BY_VERTEX) || defined(V_CW_TERRAINBLEND_VERTEXCOLOR)
		fixed4 color : COLOR;
	#endif

};

//Vertex////////////////////////////////////////////////////////////////
vOutput vert(vInput v)
{ 
	vOutput o;
	UNITY_INITIALIZE_OUTPUT(vOutput,o); 
		
	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL) || defined(V_CW_IBL_CUBE)
		V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);	
	#else
		V_CW_TransformPoint(v.vertex);	
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


	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
		float3 viewDir_WS = WorldSpaceViewDir(v.vertex);
	#endif
	#if defined(V_CW_REFLECTIVE_FRESNEL) || defined(V_CW_RIM)
		float3 viewDir_OS = normalize(ObjSpaceViewDir(v.vertex));
	#endif
	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL) || defined(V_CW_IBL_CUBE) || (defined(V_CW_IBL_MATCAP) && defined(_NORMALMAP))
		float3 normal_WS = UnityObjectToWorldNormal(v.normal);
	#endif
	

	#if defined(V_CW_IBL_CUBE) || (defined(V_CW_IBL_MATCAP) && defined(_NORMALMAP))
		o.normal.xyz = normal_WS;
	#endif

	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)		
		o.refl.xyz = normalize(reflect(-viewDir_WS, normal_WS));

		#ifdef V_CW_REFLECTIVE_FRESNEL
			half fresnel = 1 - saturate(dot (v.normal, viewDir_OS) + _V_CW_Fresnel_Bias);
			o.refl.w = fresnel * fresnel;
		#endif
	#endif

	#ifdef V_CW_IBL_MATCAP
		#ifdef _NORMALMAP

			fixed3 tangent_WS = UnityObjectToWorldDir(v.tangent.xyz);
			fixed3 binormal_WS = cross(normal_WS, tangent_WS) * v.tangent.w;
			
			o.matcapTan = tangent_WS;
			o.matcapBiN = binormal_WS;

		#else
			float3 normal_OS = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
			o.matcap.xy = mul((float3x3)UNITY_MATRIX_V, normal_OS) * 0.5 + 0.5;
		#endif
	#endif
	
	#ifdef V_CW_RIM
		half rim = saturate(dot (v.normal, viewDir_OS) + _V_CW_Rim_Bias);
		o.normal.w = rim * rim;
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
		
		#if defined(V_CW_REFLECTIVE_FRESNEL) && !defined(V_CW_IBL_MATCAP)
			bumpNormal = normalize(fixed3(bumpNormal.x * _V_CW_NormalMapStrength * i.refl.w, bumpNormal.y * _V_CW_NormalMapStrength * i.refl.w, bumpNormal.z));
		#else
			bumpNormal = normalize(fixed3(bumpNormal.x * _V_CW_NormalMapStrength, bumpNormal.y * _V_CW_NormalMapStrength, bumpNormal.z));
		#endif
	#endif

	#ifdef V_CW_IBL_CUBE

		#ifdef _NORMALMAP
			retColor.rgb = V_UNPACK_IBL(i.normal.xyz + bumpNormal) * retColor.rgb;	
		#else
			retColor.rgb = V_UNPACK_IBL(i.normal.xyz) * retColor.rgb;		
		#endif

	#elif defined(V_CW_IBL_MATCAP)

		#ifdef _NORMALMAP
			float3 matcapN = float3(dot(float3(i.matcapTan.x, i.matcapBiN.x, i.normal.x), bumpNormal), 
									dot(float3(i.matcapTan.y, i.matcapBiN.y, i.normal.y), bumpNormal), 
									dot(float3(i.matcapTan.z, i.matcapBiN.z, i.normal.z), bumpNormal));
			matcapN = mul((float3x3)UNITY_MATRIX_V, matcapN);
			
			fixed4 matColor = tex2D(_V_CW_IBL_Matcap, matcapN.xy * 0.5 + 0.5) * _V_CW_IBL_Intensity;
		#else
			fixed4 matColor = tex2D(_V_CW_IBL_Matcap, i.matcap) * _V_CW_IBL_Intensity;
		#endif


		#ifdef V_CW_MATCAP_BLEND_ADD					
			retColor.rgb += matColor.rgb;
		#else
			retColor.rgb *= matColor.rgb;
		#endif

	#endif


	#if defined(V_CW_REFLECTIVE) || defined(V_CW_REFLECTIVE_FRESNEL)
		#ifdef _NORMALMAP
			fixed4 reflTex = texCUBE( _V_CW_Cube, i.refl.xyz + bumpNormal) * _V_CW_ReflectColor;
		#else
			fixed4 reflTex = texCUBE( _V_CW_Cube, i.refl.xyz ) * _V_CW_ReflectColor;
		#endif

		#ifdef V_CW_REFLECTIVE_FRESNEL
			retColor.rgb += reflTex.rgb * i.refl.w * clamp(mainTex.a + _V_CW_ReflectStrengthAlphaOffset, 0, 1);
		#else
			retColor.rgb += reflTex.rgb * clamp(mainTex.a + _V_CW_ReflectStrengthAlphaOffset, 0, 1);
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