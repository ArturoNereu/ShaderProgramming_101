Shader "Hidden/VacuumShaders/Curved World/VertexLit/Transparent" 
{
	Properties 
	{ 
		[CurvedWorldGearMenu] V_CW_Label_Tag("", float) = 0
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Default Visual Options", float) = 0


		//Albedo
		[CurvedWorldLargeLabel] V_CW_Label_Albedo("Albedo", float) = 0	
		_Color("  Color", color) = (1, 1, 1, 1)
		_MainTex ("  Map (RGB) Trans (A)", 2D) = "white" {}
		[CurvedWorldUVScroll] _V_CW_MainTex_Scroll("    ", vector) = (0, 0, 0, 0)


		//CurvedWorld Options
		[CurvedWorldLabel] V_CW_CW_OPTIONS("Unity Advanced Rendering Options", float) = 0
		
		[HideInInspector] _V_CW_Rim_Color("", color) = (1, 1, 1, 1)
		[HideInInspector] _V_CW_Rim_Bias("", Range(-1, 1)) = 0.2
		[HideInInspector] _V_CW_Rim_Power("", Range(0.5, 8.0)) = 3
		
		[HideInInspector] _EmissionMap("", 2D) = "white"{}
		[HideInInspector] _EmissionColor("", color) = (1, 1, 1, 1)	

		[HideInInspector] _V_CW_IBL_Intensity("", float) = 1
		[HideInInspector] _V_CW_IBL_Contrast("", float) = 1 
		[HideInInspector] _V_CW_IBL_Cube("", cube ) = ""{}  
	} 

	Category    
	{
		Tags { "Queue"="Transparent+1" 
		       "IgnoreProjector"="True" 
			   "RenderType"="Transparent" 
			   "CurvedWorldTag"="VertexLit/Transparent" 
			   "CurvedWorldNoneRemoveableKeywords"=""  
			   "CurvedWorldAvailableOptions"="V_CW_VERTEX_COLOR;V_CW_RIM;V_CW_FOG;" 
			 }
		LOD 100
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha 
	
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

				#define V_CW_TRANSPARENT

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
				#define V_CW_TRANSPARENT

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
				#define V_CW_TRANSPARENT

				#include "../cginc/CurvedWorld_VertexLit.cginc"
				 
				ENDCG
			}
		}
	}

	FallBack Off
	CustomEditor "CurvedWorld_Material_Editor"
}
