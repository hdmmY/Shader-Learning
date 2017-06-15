Shader "Custom/Ch7-RampTexture"
{
	Properties{
		_Color ("Tint", Color) = (1, 1, 1, 1)
		_RampTex("Ramp Texture", 2D) = "white" {}
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8, 256)) = 20
	}

	SubShader {

		Pass{
			Tags{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

			sampler2D _RampTex;
			float4 _RampTex_ST;

			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float3 tangent: TANGENT;
				float4 tex : TEXCOORD0; 
			};

			struct vertexOutput{
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2; 
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);
				output.worldPos = mul(unity_WorldToObject, input.vertex);
				output.worldNormal = UnityObjectToWorldNormal(input.vertex);
				output.uv = input.tex.xy * _RampTex_ST.xy + _RampTex_ST.zw;

				return output;
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				float3 worldNormal = normalize(input.worldNormal);
				float3 worldPos = normalize(input.worldPos);
				float3 worldLightDir = UnityWorldSpaceLightDir(worldPos);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed halfLambert = 0.5 * dot(worldLightDir, worldNormal) + 0.5;

				fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;

				fixed3 diffuse = _LightColor0.rgb * diffuseColor;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

				fixed3 color = ambient + specular + diffuse;

				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Specular"
}