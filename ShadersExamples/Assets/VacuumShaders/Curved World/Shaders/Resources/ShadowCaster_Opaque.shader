Shader "Hidden/VacuumShaders/Curved World/ShadowCaster Opaque" 
{
	SubShader     
	{		  		  
		// Pass to render object as a shadow caster
		Pass 
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
		
			CGPROGRAM
			#pragma vertex vert   
			#pragma fragment frag
			#pragma multi_compile_shadowcaster 
			#include "UnityCG.cginc"
				 

			#include "../cginc/CurvedWorld_Base.cginc"
				  

			struct v2f 
			{ 
				V2F_SHADOW_CASTER;
			};

			v2f vert( appdata_base v )
			{
				v2f o;

				V_CW_TransformPoint(v.vertex);

				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag( v2f i ) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		} //Pass

	} //SubShader
}
