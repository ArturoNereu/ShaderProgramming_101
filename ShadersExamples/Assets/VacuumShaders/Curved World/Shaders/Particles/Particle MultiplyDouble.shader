Shader "VacuumShaders/Curved World/Particles/Multiply (Double)" 
{
	Properties 
	{
		[CurvedWorldGearMenu] V_CW_Label_Tag("", float) = 0
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Default Visual Options", float) = 0


		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
	}

	Category 
	{
		Tags { "Queue"="Transparent" 
			   "IgnoreProjector"="True" 
			   "RenderType"="Transparent" 
		       "CurvedWorldTag"="Particles/Multiply (Double)" 
			   "CurvedWorldNoneRemoveableKeywords"="" 
			   "CurvedWorldAvailableOptions"="" 
			 } 
		Blend DstColor SrcColor
		ColorMask RGB
		Cull Off Lighting Off ZWrite Off
	
		SubShader 
		{
			Pass 
			{
		
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_particles
				#pragma multi_compile_fog

				#include "UnityCG.cginc"

				#include "../cginc/CurvedWorld_Base.cginc"


				sampler2D _MainTex;
				fixed4 _TintColor;
			
				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					#ifdef SOFTPARTICLES_ON
						float4 projPos : TEXCOORD2;
					#endif
				};
			
				float4 _MainTex_ST;

				v2f vert (appdata_t v)
				{
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f,o); 


					V_CW_TransformPoint(v.vertex);
							

					o.vertex = UnityObjectToClipPos(v.vertex);	
					#ifdef SOFTPARTICLES_ON
						o.projPos = ComputeScreenPos (o.vertex);
						COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
										
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				sampler2D_float _CameraDepthTexture;
				float _InvFade;
			
				fixed4 frag (v2f i) : SV_Target
				{
					#ifdef SOFTPARTICLES_ON
						float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
						float partZ = i.projPos.z;
						float fade = saturate (_InvFade * (sceneZ-partZ));
						i.color.a *= fade;
					#endif
				
					fixed4 col;
					fixed4 tex = tex2D(_MainTex, i.texcoord);
					col.rgb = tex.rgb * i.color.rgb * 2;
					col.a = i.color.a * tex.a;
					col = lerp(fixed4(0.5f,0.5f,0.5f,0.5f), col, col.a);
					UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0.5,0.5,0.5,0.5)); // fog towards gray due to our blend mode
					return col;
				}
				ENDCG 
			}
		}
	}

	CustomEditor "CurvedWorld_Material_Editor"
}
