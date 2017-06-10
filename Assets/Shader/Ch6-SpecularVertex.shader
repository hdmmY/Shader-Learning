﻿Shader "Custom/Ch6-SpecularVertex" {
	
	Properties{
		_Diffuse ("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Specular("Specular", Color) = (1 , 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 200)) = 20 
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

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

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

				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(mul(input.normal, (float3x3)unity_WorldToObject));

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuseColor = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, input.vertex).xyz);

				fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss); 

				output.color = ambientColor + diffuseColor + specularColor;

				return output;
			}

			fixed4 frag(vertexOutput input) : SV_Target
			{
				return fixed4(input.color, 1.0);
			}

			ENDCG
		}
	}


	FallBack "Diffuse"
}
