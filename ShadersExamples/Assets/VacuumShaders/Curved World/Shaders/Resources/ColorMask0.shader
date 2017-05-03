Shader "Hidden/VacuumShaders/Curved World/ColorMask0"
{
	SubShader 
	{
	   
		//PassName "BASE" 
		Pass  
		{
			Name "BASE"

			ZWrite On
			ColorMask 0


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag  

			 

			#include "../cginc/CurvedWorld_ColorMask0.cginc"   

			ENDCG   
		} //Pass

	} //SubShader

} //Shader
