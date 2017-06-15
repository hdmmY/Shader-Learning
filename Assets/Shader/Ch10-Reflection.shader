Shader "Custom/Ch10-Reflection" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_ReflectColor ("Reflect Color", Color) = (1, 1, 1, 1)
		_ReflectFactor("Reflect Factor", Range(0.0, 1.0)) = 1.0
		_CubeMap("Cube Map", Cube) = "_SkyBox" {}
	}
	SubShader {
		
		Pass{

			Tags{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "Lighting.cginc"


			fixed4 _Color;
			fixed4 _ReflectColor;
			fixed _ReflectFactor;
			samplerCUBE _CubeMap;


			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput{
				float4 vertex : SV_POSITION;
				float3 worldNormal : NORMAL;
				float3 worldView : TEXCOORD0;
				float3 worldRelf : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};


			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);
				output.worldNormal = UnityObjectToWorldNormal(input.normal);
				output.worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;
				output.worldView = WorldSpaceViewDir(float4(output.worldPos, 1));
				output.worldRelf = reflect(-output.worldView, output.worldNormal);

				return output;
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				fixed3 worldNormal = normalize(input.worldNormal);
				fixed3 worldViewDir = normalize(input.worldView);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(input.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed3 reflectColor = texCUBE(_CubeMap, input.worldRelf).rgb * _ReflectColor.rgb;

				fixed3 color = ambient + lerp(diffuse, reflectColor, _ReflectFactor);

				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
