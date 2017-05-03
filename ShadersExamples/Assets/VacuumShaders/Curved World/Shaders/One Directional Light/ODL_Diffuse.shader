// VacuumShaders 2017
// https://www.facebook.com/VacuumShaders

Shader "VacuumShaders/Curved World/One Directional Light"
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
		_MainTex ("  Map (RGB) RefStr & Gloss (A)", 2D) = "white" {}
		[CurvedWorldUVScroll] _V_CW_MainTex_Scroll("    ", vector) = (0, 0, 0, 0)

		  

		//Curved World
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Unity Advanced Rendering Options", float) = 0

		[HideInInspector] _V_CW_Rim_Color("", color) = (1, 1, 1, 1)
		[HideInInspector] _V_CW_Rim_Bias("", Range(-1, 1)) = 0.2
		[HideInInspector] _V_CW_Rim_Power("", Range(0.5, 8.0)) = 3
		
		[HideInInspector] _EmissionMap("", 2D) = "white"{}
		[HideInInspector] _EmissionColor("", color) = (1, 1, 1, 1)	

		[HideInInspector] _V_CW_IBL_Intensity("", float) = 1
		[HideInInspector] _V_CW_IBL_Contrast("", float) = 1 
		[HideInInspector] _V_CW_IBL_Cube("", cube ) = ""{}  

		[HideInInspector] _V_CW_ReflectColor("", color) = (1, 1, 1, 1)
		[HideInInspector] _V_CW_ReflectStrengthAlphaOffset("", Range(-1, 1)) = 0
		[HideInInspector] _V_CW_Cube("", Cube) = "_Skybox"{}	
		[HideInInspector] _V_CW_Fresnel_Bias("", Range(-1, 1)) = 0

		[HideInInspector] _V_CW_Specular_Intensity("", Range(0, 5)) = 1		
		[HideInInspector] _V_CW_SpecularOffset("", Range(-0.25, 0.25)) = 0
		[HideInInspector] _V_CW_Specular_Lookup("", 2D) = "black"{}
		
		[HideInInspector] _V_CW_NormalMapStrength("", float) = 1
		[HideInInspector] _V_CW_NormalMap("", 2D) = "bump" {}
		[HideInInspector] _V_CW_NormalMap_UV_Scale ("", float) = 1

		[HideInInspector] _V_CW_SecondaryNormalMap("", 2D) = ""{}
		[HideInInspector] _V_CW_SecondaryNormalMap_UV_Scale("", float) = 1

		[HideInInspector] _V_CW_LightRampTex("", 2D) = "grey"{}
	}


	SubShader 
	{
		Tags { "RenderType"="CurvedWorld_Opaque" 
		       "CurvedWorldTag"="One Directional Light/Opaque/Texture" 
			   "CurvedWorldNoneRemoveableKeywords"="" 
			   "CurvedWorldAvailableOptions"="V_CW_USE_LIGHT_RAMP_TEXTURE;V_CW_REFLECTIVE;V_CW_VERTEX_COLOR;_EMISSION;V_CW_RIM;V_CW_FOG;_NORMALMAP;V_CW_SPECULAR_LOOKUP;" 
			 } 
		LOD 200		
		      

		//PassName "FORWARD" 
		Pass
	    {
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" } 

			CGPROGRAM       
			#pragma vertex vert  
	    	#pragma fragment frag  
			#define UNITY_PASS_FORWARDBASE   		  
			#pragma multi_compile_fwdbase nodirlightmap nodynlightmap
						       

/*DO NOT DELETE - CURVED WORLD ODL LIGHT TYPE*/ 
/*DO NOT DELETE - CURVED WORLD ODL INCLUDE POINT LIGHTS*/ 
/*DO NOT DELETE - CURVED WORLD ODL INCLUDE SPHERICAL HARMONICS AND UNITY AMBIENT*/ 
			#pragma shader_feature V_CW_REFLECTIVE_OFF V_CW_REFLECTIVE V_CW_REFLECTIVE_FRESNEL
			#pragma shader_feature V_CW_VERTEX_COLOR_OFF V_CW_VERTEX_COLOR 
			#pragma shader_feature _EMISSION_OFF _EMISSION
			#pragma shader_feature V_CW_RIM_OFF V_CW_RIM
				
			#pragma shader_feature _NORMALMAP_OFF _NORMALMAP
			#pragma shader_feature V_CW_SPECULAR_OFF V_CW_SPECULAR

			#pragma shader_feature V_CW_USE_LIGHT_RAMP_TEXTURE_OFF V_CW_USE_LIGHT_RAMP_TEXTURE

			#pragma shader_feature V_CW_FOG_OFF V_CW_FOG
			#ifdef V_CW_FOG
				#pragma multi_compile_fog
			#endif   

			#ifdef _NORMALMAP
				#ifndef V_CW_CALCULATE_LIGHT_PER_PIXEL
				#define V_CW_CALCULATE_LIGHT_PER_PIXEL
				#endif
			#endif
			 
			#include "../cginc/CurvedWorld_ForwardBase.cginc" 

			
			ENDCG    
			 
		} //Pass   	
			
	} //SubShader


	Fallback "Hidden/VacuumShaders/Curved World/VertexLit/Diffuse" 
	CustomEditor "CurvedWorld_Material_Editor"
} //Shader
