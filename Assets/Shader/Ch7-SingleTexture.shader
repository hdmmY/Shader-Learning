// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Ch7-SingleTexture" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_Specular ("Specular Color", Color) = (1, 1, 1, 1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_Gloss ("Gloss", Range(8.0, 200)) = 20.0
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
			#include "UnityCG.cginc"

			fixed4 _Color;
			fixed4 _Specular;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Gloss;

			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0; 
			};

			struct vertexOutput{
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPosition : TEXCOORD1;
				float2 uv : TEXCOORD2; 
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);
				output.worldNormal = UnityObjectToWorldNormal(input.normal);
				output.worldPosition = mul(unity_ObjectToWorld, input.vertex).xyz;
				output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);

				return output;
			}

			fixed4 frag(vertexOutput input) : SV_Target
			{
				fixed3 worldNormal = normalize(input.worldNormal);
				fixed3 worldPosition = normalize(input.worldPosition);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(input.worldPosition));

				fixed3 albedo = tex2D(_MainTex, input.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rbg * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(dot(worldNormal, worldLightDir), 0);

				fixed3 viewDir = UnityWorldSpaceViewDir(worldPosition);
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldLightDir, halfDir)), _Gloss);

				fixed3 color = specular + ambient + diffuse;

				return fixed4(color, 1.0);
			}


			ENDCG

		}
	}
	FallBack "Specular"
}
