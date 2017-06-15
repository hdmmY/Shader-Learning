Shader "Custom/Ch6-HalfLambert" {
	
	Properties{
		_DiffuseColor("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader {

		Pass {
			Tags{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _DiffuseColor;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 vertex : SV_POSITION;
				fixed3 color : COLOR;
			};

			vertexOutput vert (vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);

				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 worldNormal = normalize(mul(input.normal, (float3x3)unity_WorldToObject));

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuseColor = _LightColor0.rgb * _DiffuseColor.rgb * (0.5 * dot(worldNormal, worldLightDir + 0.5));

				output.color = ambientColor + diffuseColor;

				return output;
			}

			fixed4 frag(vertexOutput input) : SV_Target
			{
				return float4(input.color, 1.0);
			}

			ENDCG
		}
	}


	FallBack "Diffuse"
}
