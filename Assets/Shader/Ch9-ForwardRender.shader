// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Custom/Ch9-ForwardRender"
{
	Properties{
		_Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
		_Specular("Specular Color", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
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

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput{
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1; 
			};


			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);
				output.worldNormal = UnityObjectToWorldNormal(input.vertex);
				output.worldPos = mul(unity_ObjectToWorld, input.vertex);

				return output;
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				float3 worldNormal = normalize(input.worldNormal);
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(input.worldPos));

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed3 halfDir = normalize(worldViewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

				fixed  atten = 1.0;

				fixed3 color = ambient + (diffuse + specular) * atten;

				return fixed4(color, 1.0); 
			}

			ENDCG
		}


		Pass{

			Tags{
				"LightMode" = "ForwardAdd"
			}

			Blend One One

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput{
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1; 
			};


			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);
				output.worldNormal = UnityObjectToWorldNormal(input.vertex);
				output.worldPos = mul(unity_ObjectToWorld, input.vertex);

				return output;
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				float3 worldNormal = normalize(input.worldNormal);
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(input.worldPos));

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - input.worldPos);
				#endif

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed3 halfDir = normalize(worldViewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(input.worldPos, 1)).xyz;
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				        float4 lightCoord = mul(unity_WorldToLight, float4(input.worldPos, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
				#endif

				fixed3 color = (diffuse + specular) * atten;

				return fixed4(color, 1.0); 
			}

			ENDCG
		}

	}

	FallBack "Specular"
}
