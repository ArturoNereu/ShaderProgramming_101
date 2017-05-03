#ifndef VACUUM_CURVEDWORLD_PROJECTOR_CGINC
#define VACUUM_CURVEDWORLD_PROJECTOR_CGINC

#include "UnityCG.cginc"
#include "../cginc/CurvedWorld_Base.cginc"


//Variables/////////////////////////////////////////////////////////////
fixed4 _Color;

float4x4 unity_Projector;
float4x4 unity_ProjectorClip;			
sampler2D _ShadowTex;
sampler2D _FalloffTex;

//Structs///////////////////////////////////////////////////////////////
struct v2f 
{
	float4 pos : SV_POSITION;
	float4 uvShadow : TEXCOORD0;
	float4 uvFalloff : TEXCOORD1;

	UNITY_FOG_COORDS(2)
};

//Vertex////////////////////////////////////////////////////////////////
v2f vert(float4 vertex : POSITION)
{
	v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f,o); 
				
	V_CW_TransformPoint(vertex);	
	o.pos = UnityObjectToClipPos(vertex);


	o.uvShadow = mul (unity_Projector, vertex);
	o.uvFalloff = mul (unity_ProjectorClip, vertex);

	UNITY_TRANSFER_FOG(o,o.pos);

	return o;
}
//Vertex////////////////////////////////////////////////////////////////
fixed4 frag(v2f i) : SV_Target
{
	fixed4 texS = tex2Dproj (_ShadowTex, UNITY_PROJ_COORD(i.uvShadow));
	fixed4 texF = tex2Dproj (_FalloffTex, UNITY_PROJ_COORD(i.uvFalloff));

	fixed4 res = 0;
	#ifdef V_CW_PROJECTOR_LIGHT
		texS.rgb *= _Color.rgb;
		texS.a = 1.0 - texS.a;	 
	
		res = texS * texF.a;

		UNITY_APPLY_FOG_COLOR(i.fogCoord, res, fixed4(0,0,0,0));
	#endif

	#ifdef V_CW_PROJECTOR_MULTIPLY
		texS.a = 1.0-texS.a;

		res = lerp(fixed4(1,1,1,0), texS, texF.a);

		UNITY_APPLY_FOG_COLOR(i.fogCoord, res, fixed4(1,1,1,1));
	#endif
	

	return res;
}

#endif