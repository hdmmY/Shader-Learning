Shader "Custom/Ch8-AlphaTest" {
	Properties {
		_Color ("Tint", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_Cutoff("Alpha Cutoff", Range(0.0, 1)) = 0.5
	}
	SubShader {
		
		Pass{
			Tags{
				"Queue" = "AlphaTest"
				"IgnoreProjector" = "True"
				"RenderType" = "TransparentCutout"
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			fixed4 _Color;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _Cutoff;

			struct vertexInput{
				float4 vertex : POSITION;
				float4 tex : TEXCOORD0; 
			};

			struct vertexOutput{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0; 
				float3 worldNormal : NORMAL;
				float3 worldPos : TEXCOORD1;
			};


			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);
				output.uv = input.tex.xy * _MainTex_ST.xy + input.tex.zw;

				output.worldNormal = UnityObjectToWorldNormal(input.vertex);

				output.worldPos = mul(unity_ObjectToWorld, input.vertex);

				return output;
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				float3 worldPos = normalize(input.worldPos);
				float3 worldNormal = normalize(input.worldNormal);

				fixed4 texColor = tex2D(_MainTex, input.uv);

				clip(texColor.a - _Cutoff);

				fixed3 albedo = texColor.rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, UnityWorldSpaceLightDir(worldPos)));

				fixed3 color = ambient + diffuse;
				return fixed4(color, 1.0);
			}


			ENDCG
			
		}
	}
	FallBack "Diffuse"
}
