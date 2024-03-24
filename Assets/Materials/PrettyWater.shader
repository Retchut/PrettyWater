Shader "Unlit/PrettyWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
			#define PI 3.14159265358979323846

            struct VertexData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            struct Wave {
                float2 direction;
                float speed;
                float amplitude;
                float frequency;
                float phase;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _WaveNumber;
            float3 _SunDirection;
            float3 _WaterColor;
            float3 _AmbientColor;
            float _DiffuseCoeff;
			
			StructuredBuffer<Wave> _Waves;


            float3 getPartialDerivatives(Wave wave, float3 vPos){
                // sin(x)' = x'cos(x)
                float xzDisplacement = vPos.x * wave.direction.x + vPos.z * wave.direction.y;
                float xDerivative = wave.frequency * wave.direction.x * wave.amplitude * cos(xzDisplacement * wave.frequency + wave.phase * _Time * wave.speed);
                float zDerivative = wave.frequency * wave.direction.y * wave.amplitude * cos(xzDisplacement * wave.frequency + wave.phase * _Time * wave.speed);
                return float3(xDerivative, 0.0f, zDerivative);
            }

            v2f vert (VertexData v)
            {
                v2f o;
                o.vertex = mul(unity_ObjectToWorld, v.vertex); // get vertex world position
                float heightOffset = 0.0;
                float3 derivatives = float3(0.0, 0.0, 0.0);
                for (int i = 0; i < _WaveNumber; i++) {
                    Wave wave = _Waves[i];
                    wave.direction = normalize(wave.direction);
                    // displacement depends on the X and Z position
                    float xzDisplacement = o.vertex.x * wave.direction.x + o.vertex.z * wave.direction.y;
                    heightOffset += wave.amplitude * sin(xzDisplacement * wave.frequency + wave.phase * _Time * wave.speed);
                    derivatives += getPartialDerivatives(wave, o.vertex);
                }
                // Tangent vector is (1, d/dx, 0); Binormal vector is (0, d/dz, 1); the cross product can be simplified to (d/dx, -1, d/dz)
                float3 normalizedNormal = normalize(UnityObjectToWorldNormal(normalize(float3(derivatives.x, 1.0f, derivatives.z))));
                o.normal = normalizedNormal;
                o.vertex.y += heightOffset;
                o.vertex = UnityObjectToClipPos(o.vertex); // clip to world position
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 lightDir = -normalize(_SunDirection);

                float ndotl = max(0.0, dot(lightDir, i.normal));
                
                float3 ambient = _WaterColor * _AmbientColor;
                float3 diffuseReflectance = _DiffuseCoeff / PI;
                float3 diffuse = _WaterColor * _LightColor0.rgb * ndotl * diffuseReflectance;

                float3 finalColor = ambient + diffuse;
                return float4(finalColor, 1.0f);
            }
            ENDCG
        }
    }
}
