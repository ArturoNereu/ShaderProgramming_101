Shader "Hidden/VacuumShaders/Curved World/Outline" 
{
	Properties 
	{
		_V_CW_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_V_CW_OutlineWidth ("Outline width", Float) = .005
	}

	SubShader     
	{		  		  
		Tags{ "RenderType" = "Opaque" }

		//PassName "OUTLINE" 
		Pass  
		{ 
			Name "OUTLINE"
			Tags{ "LightMode" = "Always" }

			Cull Front 
			ZWrite On 
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag  

/*DO NOT DELETE - CURVED WORLD OUTLINE FIXED SIZE*/ 
						 			   
			#pragma shader_feature V_CW_FOG_OFF V_CW_FOG	
			#ifdef V_CW_FOG
				#pragma multi_compile_fog
			#endif   

			#include "../cginc/CurvedWorld_Outline.cginc"
						      
			ENDCG  
		} //Pass
	} //SubShader

	Fallback Off
}
