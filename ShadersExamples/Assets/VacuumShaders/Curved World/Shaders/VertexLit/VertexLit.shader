Shader "Hidden/VacuumShaders/Curved World/VertexLit/Diffuse" 
{
	Properties 
	{ 
		[CurvedWorldGearMenu] V_CW_Label_Tag("", float) = 0
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Default Visual Options", float) = 0
		  
		   
		//Albedo
		[CurvedWorldLargeLabel] V_CW_Label_Albedo("Albedo", float) = 0	
		_Color("  Color", color) = (1, 1, 1, 1)
		_MainTex ("  Map", 2D) = "white" {}
		[CurvedWorldUVScroll] _V_CW_MainTex_Scroll("    ", vector) = (0, 0, 0, 0)
		 
		 
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Unity Advanced Rendering Options", float) = 0

		[HideInInspector] _V_CW_Rim_Color("", color) = (1, 1, 1, 1)
		[HideInInspector] _V_CW_Rim_Bias("", Range(-1, 1)) = 0.2
		[HideInInspector] _V_CW_Rim_Power("", Range(0.5, 8.0)) = 3
	} 

	Category      
	{
		Tags { "RenderType"="CurvedWorld_Opaque"
			   "CurvedWorldTag"="VertexLit/Diffuse" 
			   "CurvedWorldNoneRemoveableKeywords"=""  
			   "CurvedWorldAvailableOptions"="V_CW_VERTEX_COLOR;V_CW_RIM;V_CW_FOG;" 
			 } 
		LOD 150
	
		SubShader  
		{			 
		
			// Vertex Lit, emulated in shaders (4 lights max, no specular)
			Pass  
			{
				Tags { "LightMode" = "Vertex" }
				Lighting On 

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag



				#pragma shader_feature V_CW_VERTEX_COLOR_OFF V_CW_VERTEX_COLOR
				#pragma shader_feature V_CW_RIM_OFF V_CW_RIM

				#pragma shader_feature V_CW_FOG_OFF V_CW_FOG
				#ifdef V_CW_FOG
					#pragma multi_compile_fog
				#endif

				#include "../cginc/CurvedWorld_VertexLit.cginc"

				
				ENDCG
			}
		 
			// Lightmapped
			Pass 
			{
				Tags { "LightMode" = "VertexLM" }

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag



				#pragma shader_feature V_CW_VERTEX_COLOR_OFF V_CW_VERTEX_COLOR
				#pragma shader_feature V_CW_RIM_OFF V_CW_RIM

				#pragma shader_feature V_CW_FOG_OFF V_CW_FOG
				#ifdef V_CW_FOG
					#pragma multi_compile_fog
				#endif

				#define V_CW_VERTEX_LIGHTMAP

				#include "../cginc/CurvedWorld_VertexLit.cginc"


				ENDCG 
			} 
		   
			// Lightmapped, encoded as RGBM
			Pass 
			{
				Tags { "LightMode" = "VertexLMRGBM" }

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag



				#pragma shader_feature V_CW_VERTEX_COLOR_OFF V_CW_VERTEX_COLOR
				#pragma shader_feature V_CW_RIM_OFF V_CW_RIM

				#pragma shader_feature V_CW_FOG_OFF V_CW_FOG
				#ifdef V_CW_FOG
					#pragma multi_compile_fog
				#endif

				#define V_CW_VERTEX_LIGHTMAP

				#include "../cginc/CurvedWorld_VertexLit.cginc"
				 
				ENDCG
			}
			 
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

			}
		}
	}

	FallBack Off
	CustomEditor "CurvedWorld_Material_Editor"
}
