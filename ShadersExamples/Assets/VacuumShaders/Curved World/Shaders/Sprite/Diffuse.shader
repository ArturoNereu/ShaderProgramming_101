Shader "VacuumShaders/Curved World/Sprites/Diffuse"
{
	Properties
	{
		[CurvedWorldGearMenu] V_CW_Label_Tag("", float) = 0
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Default Visual Options", float) = 0


		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0



		//Curved World
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Unity Advanced Rendering Options", float) = 0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
			"CurvedWorldTag"="Sprites/Diffuse" 
			"CurvedWorldNoneRemoveableKeywords"="" 
			"CurvedWorldAvailableOptions"=""
		} 

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		CGPROGRAM
		#pragma surface surf Lambert vertex:vert nofog keepalpha noshadow 
		#pragma multi_compile _ PIXELSNAP_ON


		#include "../cginc/CurvedWorld_Base.cginc" 


		sampler2D _MainTex;
		fixed4 _Color; 

		struct Input
		{
			float2 uv_MainTex;
			fixed4 color;
		};
		
		void vert (inout appdata_full v, out Input o)
		{

			V_CW_TransformPoint(v.vertex);  
			 

			#if defined(PIXELSNAP_ON)
				v.vertex = UnityPixelSnap (v.vertex);
			#endif
			
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.color = v.color * _Color;
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * IN.color;
			o.Albedo = c.rgb * c.a;
			o.Alpha = c.a;
		}
		ENDCG
	}

	Fallback "VacuumShaders/Curved World/Sprites/Default"
	CustomEditor "CurvedWorld_Material_Editor"
}
