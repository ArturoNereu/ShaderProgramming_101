Shader "Hidden/VacuumShaders/Curved World/ShadowCaster Cutout" 
{
	Properties 
	{
		//Albedo
		[CurvedWorldLargeLabel] V_CW_Label_Albedo("Albedo", float) = 0	
		_Color("  Color", color) = (1, 1, 1, 1)
		_MainTex ("  Map (RGB) Trans (A)", 2D) = "white" {}
		[CurvedWorldUVScroll] _V_CW_MainTex_Scroll("    ", vector) = (0, 0, 0, 0)

		//Cutoff
		[CurvedWorldLargeLabel] V_CW_Label_Cutoff("Cutout", float) = 0	
		_Cutoff ("  Alpha cutoff", Range(0,1)) = 0.5	
	}

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
				 


			#define V_CW_CUTOUT

			#include "../cginc/CurvedWorld_Base.cginc"
				  


		    uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform fixed _Cutoff;
			uniform fixed4 _Color;

			struct v2f 
			{ 
				V2F_SHADOW_CASTER;
				float2  uv : TEXCOORD1;
			};

			v2f vert( appdata_base v )
			{
				v2f o;

				V_CW_TransformPoint(v.vertex);


				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			float4 frag( v2f i ) : SV_Target
			{
				fixed4 texcol = tex2D( _MainTex, i.uv );
				clip( texcol.a*_Color.a - _Cutoff );

				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG

		} //Pass
	} //SubShader
}
