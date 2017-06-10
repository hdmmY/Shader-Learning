Shader "Custom/Ch6-DiffusePixel" {
	Properties {
		_Diffuse ("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader {
		
		Pass{

			Tags{
				"LightingMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput{
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0; 
			};


			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);

				output.worldNormal = mul(input.normal, (float3x3)unity_WorldToObject);

				return output;
			}

			fixed4 frag(vertexOutput input) : SV_Target
			{
				fixed4 ambient = UNITY_LIGHTMODEL_AMBIENT;
				fixed3 worldNormal = normalize(input.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuseColor = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));	 
				fixed3 color = diffuseColor + ambient;

				return float4(color, 1.0);
			}


			ENDCG

		}
	}
	FallBack "Diffuse"
}
