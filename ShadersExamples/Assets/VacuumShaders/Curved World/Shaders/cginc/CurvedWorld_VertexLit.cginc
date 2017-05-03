#ifndef VACUUM_CURVEDWORLD_VERTEXLIT_CGINC
#define VACUUM_CURVEDWORLD_VERTEXLIT_CGINC


#include "UnityCG.cginc"
#include "../cginc/CurvedWorld_Base.cginc"
////////////////////////////////////////////////////////////////////////////
//																		  //
//Variables 															  //
//																		  //
////////////////////////////////////////////////////////////////////////////
sampler2D _MainTex;
uniform float4 _MainTex_ST;
fixed2 _V_CW_MainTex_Scroll;
fixed4 _Color;

#ifdef V_CW_CUTOUT
	half _Cutoff;
#endif

#ifdef V_CW_RIM
	fixed4 _V_CW_Rim_Color;
	fixed  _V_CW_Rim_Bias;
#endif



////////////////////////////////////////////////////////////////////////////
//																		  //
//Struct    															  //
//																		  //
////////////////////////////////////////////////////////////z////////////////
struct v2f  
{  
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;	

	#ifdef V_CW_VERTEX_LIGHTMAP
		half2 lm : TEXCOORD1;
	#else
		fixed4 diff : TEXCOORD1;
	#endif		

	#ifdef V_CW_RIM
		half rim : TEXCOORD2; 
	#endif

	#ifdef V_CW_VERTEX_COLOR
		fixed4 color : COLOR;
	#endif	

	#ifdef V_CW_FOG
		UNITY_FOG_COORDS(3)  
	#endif					
};


////////////////////////////////////////////////////////////////////////////
//																		  //
//Vertex    															  //
//																		  //
////////////////////////////////////////////////////////////z////////////////
v2f vert (appdata_full v) 
{   
	v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f,o); 

	#ifdef V_CW_VERTEX_LIGHTMAP
		V_CW_TransformPoint(v.vertex);
	#else
		V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
	#endif

	o.pos = UnityObjectToClipPos(v.vertex); 
	o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
	o.uv += _V_CW_MainTex_Scroll.xy * _Time.x;
				

	#ifdef V_CW_VERTEX_LIGHTMAP
		o.lm = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	#else
		float4 lighting = float4(ShadeVertexLightsFull(v.vertex, v.normal, 4, true), 1);
		o.diff = lighting;
	#endif

	
	#ifdef V_CW_VERTEX_COLOR
		o.color = v.color;
	#endif

	#ifdef V_CW_RIM
		half rim = saturate(dot (normalize(v.normal), normalize(ObjSpaceViewDir(v.vertex))) + _V_CW_Rim_Bias);
		o.rim = rim * rim;
	#endif	
	
	#ifdef V_CW_FOG		
		UNITY_TRANSFER_FOG(o,o.pos); 
	#endif

	return o; 
}


////////////////////////////////////////////////////////////////////////////
//																		  //
//Fragment    															  //
//																		  //
////////////////////////////////////////////////////////////////////////////
fixed4 frag (v2f i) : SV_Target 
{
	fixed4 c = tex2D (_MainTex, i.uv) * _Color;	

	#if defined(V_CW_CUTOUT)
		clip(c.a - _Cutoff);	
	#endif

	#ifdef V_CW_VERTEX_LIGHTMAP
		fixed4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lm); 
		half3 lm = DecodeLightmap(bakedColorTex);

		c.rgb *= lm.rgb;
	#else
		c *= i.diff;
	#endif


	#ifdef V_CW_VERTEX_COLOR
		c.rgb *= i.color;
	#endif

	#ifdef V_CW_RIM
		c.rgb = lerp(_V_CW_Rim_Color.rgb, c.rgb, i.rim);
	#endif
				

	#ifdef V_CW_FOG
		#ifdef V_CW_VERTEX_LIGHTMAP
			UNITY_APPLY_FOG_COLOR(i.fogCoord, c, fixed4(0,0,0,0)); // fog towards black due to LM blend mode
		#else
			UNITY_APPLY_FOG(i.fogCoord, c); 
		#endif
	#endif
	
	#if defined(V_CW_TRANSPARENT) || defined(V_CW_CUTOUT)
		//Empty
	#else
		UNITY_OPAQUE_ALPHA(c.a);
	#endif

	return c;
} 

#endif 
