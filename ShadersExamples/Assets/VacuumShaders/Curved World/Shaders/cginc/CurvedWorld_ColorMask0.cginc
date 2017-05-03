#ifndef VACUUM_CURVEDWORLD_COLORMASK0_CGINC
#define VACUUM_CURVEDWORLD_COLORMASK0_CGINC


#include "../cginc/CurvedWorld_Base.cginc"
 

struct v2f   
{  
	float4 pos : SV_POSITION;	
};
	 
v2f vert(float4 v : POSITION)   
{
	v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f,o); 
	
	V_CW_TransformPoint(v);
	o.pos = UnityObjectToClipPos(v);	

	return o;
}

fixed4 frag () : SV_Target 
{
	return 0;
}

	
#endif