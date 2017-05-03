Shader "Stix Games/Grass" 
 {
    Properties 
	{
		_EdgeLength ("Density Falloff", Range(0.5,50)) = 8

		_MaxTessellation("Max Density", Range(1, 6)) = 6

		_LODStart("LOD Start", float) = 20
		_LODEnd("LOD End", float) = 100
		_LODMax("Max LOD", Range(1,5)) = 5

		_GrassFadeStart("Grass Fade Start", float) = 50
		_GrassFadeEnd("Grass Fade End", float) = 100

		_Disorder("Disorder", float) = 0.3

		_GrassBottomColor("Grass Bottom Color", Color) = (0.35, 0.35, 0.35, 1)
		_BurnColor("Burn Color", Color) = (1,1,1,1)

		_TextureCutoff("Texture Cutoff", Range(0, 1)) = 0.1

		_ColorMap("Color Texture (RGB), Height(A)", 2D) = "white" {}
		_Displacement("Displacement Texture (RG)", 2D) = "bump" {}
		_Density("Grass Density 1(R) 2(G) 3(B) 4(A)", 2D) = "red" {}
		_DensityValues("Grass Density Values", Vector) = (1, 1, 1, 1)

		_WindParams("Wind WaveStrength(X), WaveSpeed(Y), RippleStrength(Z), RippleSpeed(W)", Vector) = (0.3, 1.2, 0.15, 1.3)
		_WindRotation("Wind Rotation", Range(0, 6.28318530718)) = 0

		_GrassTex00	 ("Grass Texture", 2D)		= "white" {}
		_Color00	 ("Color", Color)			= (0.5, 0.7, 0.3, 1)
		_SecColor00	 ("Secondary Color", Color) = (0.2, 0.5, 0.15, 1)
		_SpecColor00 ("Specular Color", Color)	= (0.2, 0.2, 0.2, 1)
		_Smoothness00("Smoothness", Range(0,1)) = 0.5
		_Softness00	 ("Softness", Range(0,1))	= 0.5
		_Width00	 ("Width", float)			= 0.1
		_MinHeight00 ("Min Height", float)		= 0.2
		_MaxHeight00("Max Height", float)		= 1.5
		_TextureAtlasWidth00 ("Texture Atlas Width", int) = 1
		_TextureAtlasHeight00("Texture Atlas Height", int) = 1

		_GrassTex01	 ("Grass Texture", 2D)		= "white" {}
		_Color01	 ("Color", Color)			= (0.5, 0.7, 0.3, 1)
		_SecColor01	 ("Secondary Color", Color) = (0.2, 0.5, 0.15, 1)
		_SpecColor01 ("Specular Color", Color)	= (0.2, 0.2, 0.2, 1)
		_Smoothness01("Smoothness", Range(0,1)) = 0.5
		_Softness01	 ("Softness", Range(0,1))	= 0.5
		_Width01	 ("Width", float)			= 0.1
		_MinHeight01 ("Min Height", float)		= 0.2
		_MaxHeight01 ("Max Height", float)		= 1.5
		_TextureAtlasWidth01("Texture Atlas Width", int) = 1
		_TextureAtlasHeight01("Texture Atlas Height", int) = 1

		_GrassTex02	 ("Grass Texture", 2D)		= "white" {}
		_Color02	 ("Color", Color)			= (0.5, 0.7, 0.3, 1)
		_SecColor02	 ("Secondary Color", Color) = (0.2, 0.5, 0.15, 1)
		_SpecColor02 ("Specular Color", Color)	= (0.2, 0.2, 0.2, 1)
		_Smoothness02("Smoothness", Range(0,1)) = 0.5
		_Softness02	 ("Softness", Range(0,1))	= 0.5
		_Width02	 ("Width", float)			= 0.1
		_MinHeight02 ("Min Height", float)		= 0.2
		_MaxHeight02 ("Max Height", float)		= 1.5
		_TextureAtlasWidth02("Texture Atlas Width", int) = 1
		_TextureAtlasHeight02("Texture Atlas Height", int) = 1

		_GrassTex03	 ("Grass Texture", 2D)		= "white" {}
		_Color03	 ("Color", Color)			= (0.5, 0.7, 0.3, 1)
		_SecColor03	 ("Secondary Color", Color) = (0.2, 0.5, 0.15, 1)
		_SpecColor03 ("Specular Color", Color)	= (0.2, 0.2, 0.2, 1)
		_Smoothness03("Smoothness", Range(0,1)) = 0.5
		_Softness03	 ("Softness", Range(0,1))	= 0.5
		_Width03	 ("Width", float)			= 0.1
		_MinHeight03 ("Min Height", float)		= 0.2
		_MaxHeight03 ("Max Height", float)		= 1.5
		_TextureAtlasWidth03("Texture Atlas Width", int) = 1
		_TextureAtlasHeight03("Texture Atlas Height", int) = 1
    }

	SubShader
	{
		Tags{ "Queue" = "AlphaTest" "RenderType" = "StixGamesGrass" }
		LOD 1000

		Pass 
		{
			Name "FORWARD"
			Tags {"LightMode" = "ForwardBase"}
			ColorMask RGB
			Cull Off

			CGPROGRAM
			#define UNITY_PASS_FORWARDBASE
			
			#pragma vertex vert
			#pragma hull hullShader
			#pragma domain domainShader
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase

			// ================= Shader_feature block start =================
			#pragma shader_feature SIMPLE_GRASS SIMPLE_GRASS_DENSITY ONE_GRASS_TYPE TWO_GRASS_TYPES THREE_GRASS_TYPES FOUR_GRASS_TYPES
			#pragma shader_feature __ GRASS_UNLIT_LIGHTING GRASS_UNSHADED_LIGHTING GRASS_PBR_LIGHTING
			#pragma shader_feature __ UNIFORM_DENSITY VERTEX_DENSITY
			#pragma shader_feature __ GRASS_HEIGHT_SMOOTHING
			#pragma shader_feature __ GRASS_WIDTH_SMOOTHING
			#pragma shader_feature __ GRASS_OBJECT_MODE
			#pragma shader_feature __ GRASS_TOP_VIEW_COMPENSATION
			#pragma shader_feature __ GRASS_FOLLOW_SURFACE_NORMAL
			#pragma shader_feature __ GRASS_USE_TEXTURE_ATLAS
			#pragma shader_feature __ GRASS_IGNORE_GI_SPECULAR
			#pragma multi_compile  __ GRASS_RENDERTEXTURE_DISPLACEMENT
			// ================= Shader_feature block end  =================
			
			#include "UnityCG.cginc"
			#include "Tessellation.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"

			#include "GrassConfig.cginc"
			#include "GrassDefinitionsAndFunctions.cginc"

			#include "GrassVertex.cginc"
			#include "GrassTessellation.cginc"
			#include "GrassGeom.cginc"
			#include "GrassSurface.cginc"
			#include "GrassLighting.cginc"
			#include "GrassFrag.cginc"

			ENDCG
		}

		Pass 
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardAdd" }
			ZWrite Off Blend One One
			ColorMask RGB
			Cull Off

			CGPROGRAM
			#define UNITY_PASS_FORWARDADD

			#pragma vertex vert
			#pragma hull hullShader
			#pragma domain domainShader
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma multi_compile_fwdadd_fullshadows

			// ================= Shader_feature block start =================
			#pragma shader_feature SIMPLE_GRASS SIMPLE_GRASS_DENSITY ONE_GRASS_TYPE TWO_GRASS_TYPES THREE_GRASS_TYPES FOUR_GRASS_TYPES
			#pragma shader_feature __ GRASS_UNLIT_LIGHTING GRASS_UNSHADED_LIGHTING GRASS_PBR_LIGHTING
			#pragma shader_feature __ UNIFORM_DENSITY VERTEX_DENSITY
			#pragma shader_feature __ GRASS_HEIGHT_SMOOTHING
			#pragma shader_feature __ GRASS_WIDTH_SMOOTHING
			#pragma shader_feature __ GRASS_OBJECT_MODE
			#pragma shader_feature __ GRASS_TOP_VIEW_COMPENSATION
			#pragma shader_feature __ GRASS_FOLLOW_SURFACE_NORMAL
			#pragma shader_feature __ GRASS_USE_TEXTURE_ATLAS
			#pragma shader_feature __ GRASS_IGNORE_GI_SPECULAR
			#pragma multi_compile  __ GRASS_RENDERTEXTURE_DISPLACEMENT
			// ================= Shader_feature block end  =================

			#include "UnityCG.cginc"
			#include "Tessellation.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"

			#include "GrassConfig.cginc"
			#include "GrassDefinitionsAndFunctions.cginc"

			#include "GrassVertex.cginc"
			#include "GrassTessellation.cginc"
			#include "GrassGeom.cginc"
			#include "GrassSurface.cginc"
			#include "GrassLighting.cginc"
			#include "GrassFrag.cginc"

			ENDCG
		}

		Pass 
		{
			Name "ShadowCaster"
			Tags {"LightMode" = "ShadowCaster" }
			ZWrite On ZTest LEqual
			Cull Off
			Offset 1, 0

			CGPROGRAM
			#define UNITY_PASS_SHADOWCASTER

			#pragma vertex vert
			#pragma hull hullShader
			#pragma domain domainShader
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_shadowcaster

			// ================= Shader_feature block start =================
			#pragma shader_feature SIMPLE_GRASS SIMPLE_GRASS_DENSITY ONE_GRASS_TYPE TWO_GRASS_TYPES THREE_GRASS_TYPES FOUR_GRASS_TYPES
			#pragma shader_feature __ GRASS_UNLIT_LIGHTING GRASS_UNSHADED_LIGHTING GRASS_PBR_LIGHTING
			#pragma shader_feature __ UNIFORM_DENSITY VERTEX_DENSITY
			#pragma shader_feature __ GRASS_HEIGHT_SMOOTHING
			#pragma shader_feature __ GRASS_WIDTH_SMOOTHING
			#pragma shader_feature __ GRASS_OBJECT_MODE
			#pragma shader_feature __ GRASS_TOP_VIEW_COMPENSATION
			#pragma shader_feature __ GRASS_FOLLOW_SURFACE_NORMAL
			#pragma shader_feature __ GRASS_USE_TEXTURE_ATLAS
			#pragma shader_feature __ GRASS_IGNORE_GI_SPECULAR
			#pragma multi_compile  __ GRASS_RENDERTEXTURE_DISPLACEMENT
			// ================= Shader_feature block end  =================

			#include "UnityCG.cginc"
			#include "Tessellation.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"

			#include "GrassConfig.cginc"
			#include "GrassDefinitionsAndFunctions.cginc"

			#include "GrassVertex.cginc"
			#include "GrassTessellation.cginc"
			#include "GrassGeom.cginc"
			#include "GrassSurface.cginc"
			#include "GrassLighting.cginc"
			#include "GrassFrag.cginc"

			ENDCG
		}
	}

	CustomEditor "GrassEditor"
}