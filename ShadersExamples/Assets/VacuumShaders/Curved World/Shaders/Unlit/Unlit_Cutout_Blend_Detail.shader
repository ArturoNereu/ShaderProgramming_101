// VacuumShaders 2017
// https://www.facebook.com/VacuumShaders

Shader "Hidden/VacuumShaders/Curved World/Unlit/Cutout/Detail"
{
	Properties 
	{
		[CurvedWorldGearMenu] V_CW_Label_Tag("", float) = 0
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Default Visual Options", float) = 0


		//Modes
		[CurvedWorldLargeLabel] V_CW_Label_Modes("Modes", float) = 0	
		[CurvedWorldRenderingMode] V_CW_Rendering_Mode("  Rendering", float) = 0	
		[CurvedWorldTextureMixMode] V_CW_Texture_Mix_Mode("  Texture Mix", float) = 0	

		//Albedo
		[CurvedWorldLargeLabel] V_CW_Label_Albedo("Albedo", float) = 0	
		_Color("  Color", color) = (1, 1, 1, 1)
		_MainTex ("  Map (RGB) RefStr & Trans (A)", 2D) = "white" {}
		[CurvedWorldUVScroll] _V_CW_MainTex_Scroll("    ", vector) = (0, 0, 0, 0)
		_V_CW_SecondaryTex ("  Detail", 2D) = "gray" {}
		[CurvedWorldUVScroll] _V_CW_SecondaryTex_Scroll("    ", vector) = (0, 0, 0, 0)

		//Cutoff
		[CurvedWorldLargeLabel] V_CW_Label_Cutoff("Cutout", float) = 0	
		_Cutoff ("  Alpha cutoff", Range(0,1)) = 0.5	



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

		[HideInInspector] _V_CW_IBL_Matcap ("", 2D) = "Gray" {}	

		[HideInInspector] _V_CW_ReflectColor("", color) = (1, 1, 1, 1)
		[HideInInspector] _V_CW_ReflectStrengthAlphaOffset("", Range(-1, 1)) = 0
		[HideInInspector] _V_CW_Cube("", Cube) = "_Skybox"{}	
		[HideInInspector] _V_CW_Fresnel_Bias("", Range(-1, 1)) = 0

		[HideInInspector] _V_CW_NormalMapStrength("", float) = 1
		[HideInInspector] _V_CW_NormalMap("", 2D) = "bump" {}
		[HideInInspector] _V_CW_NormalMap_UV_Scale ("", float) = 1

		[HideInInspector] _V_CW_SecondaryNormalMap("", 2D) = ""{}
		[HideInInspector] _V_CW_SecondaryNormalMap_UV_Scale("", float) = 1
	}


	SubShader 
	{
		Tags { "Queue"="AlphaTest" 
		       "IgnoreProjector"="True" 
			   "RenderType"="CurvedWorld_TransparentCutout"  
		       "CurvedWorldTag"="Unlit/Cutout/Detail" 
			   "CurvedWorldNoneRemoveableKeywords"="" 
			   "CurvedWorldAvailableOptions"="V_CW_REFLECTIVE;V_CW_VERTEX_COLOR;V_CW_IBL;_EMISSION;V_CW_RIM;V_CW_FOG;_NORMALMAP;" 
			 }
		LOD 150
		

		//PassName "BASE"
		Pass  
	    {
			Name "BASE"

			CGPROGRAM
			#pragma vertex vert
	    	#pragma fragment frag  			         
			    			                          
			           

			#pragma shader_feature V_CW_REFLECTIVE_OFF V_CW_REFLECTIVE V_CW_REFLECTIVE_FRESNEL
			#pragma shader_feature _NORMALMAP_OFF _NORMALMAP
			#pragma shader_feature V_CW_VERTEX_COLOR_OFF V_CW_VERTEX_COLOR 
			#pragma shader_feature V_CW_IBL_OFF V_CW_IBL_CUBE V_CW_IBL_MATCAP
			#pragma shader_feature V_CW_MATCAP_BLEND_MULTIPLY V_CW_MATCAP_BLEND_ADD
			#pragma shader_feature _EMISSION_OFF _EMISSION
			#pragma shader_feature V_CW_RIM_OFF V_CW_RIM

			#pragma shader_feature V_CW_FOG_OFF V_CW_FOG
			#ifdef V_CW_FOG
				#pragma multi_compile_fog
			#endif
			
			#define V_CW_DETAIL
			#define V_CW_CUTOUT 

			#include "../cginc/CurvedWorld_Unlit.cginc" 


			ENDCG

		} //Pass

	} //SubShader
	 

	CustomEditor "CurvedWorld_Material_Editor"
} //Shader
