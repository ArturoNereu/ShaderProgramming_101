// VacuumShaders 2017
// https://www.facebook.com/VacuumShaders

Shader "Hidden/VacuumShaders/Curved World/Unlit/Transparent (2 Pass)/Detail"
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
		Tags { "Queue"="Transparent+1" 
		       "IgnoreProjector"="True" 
			   "RenderType"="Transparent" 
		       "CurvedWorldTag"="Unlit/Transparent (2 Pass)/Detail" 
			   "CurvedWorldNoneRemoveableKeywords"="" 
			   "CurvedWorldAvailableOptions"="V_CW_REFLECTIVE;V_CW_VERTEX_COLOR;V_CW_IBL;_EMISSION;V_CW_RIM;V_CW_FOG;_NORMALMAP;" 
			 }
		LOD 150

		//ColorMask0 
		UsePass "Hidden/VacuumShaders/Curved World/ColorMask0/BASE"
		
		//Base
		UsePass "Hidden/VacuumShaders/Curved World/Unlit/Transparent/Detail/BASE"

	} //SubShader
	 

	CustomEditor "CurvedWorld_Material_Editor"
} //Shader
