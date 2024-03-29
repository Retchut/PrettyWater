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
            float _AmbientAttenuation;
            float3 _AmbientColor;
            float _DiffuseCoeff;
            float _SpecularCoeff;
            float _SpecularConcentration;
			
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
                o.vertex = mul(unity_ObjectToWorld, v.vertex); // transform to world position
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
                // Tangent vector is (1, d/dx, 0); Binormal vector is (0, d/dz, 1); the cross product can be simplified to (d/dx, -1, d/dz), but we want the normal in the inverse direction
                float3 normalizedNormal = normalize(UnityObjectToWorldNormal(normalize(-float3(derivatives.x, -1.0f, derivatives.z))));
                o.normal = normalizedNormal;
                o.vertex.y += heightOffset;
                o.vertex = UnityObjectToClipPos(o.vertex);
                
                return o;
            }

float4 frag (v2f i) : SV_Target
{
    float3 normalizedNormal = normalize(i.normal);
    float3 lightDir = -normalize(_SunDirection); // sun direction points from sun to vertex
    float3 cameraDir = normalize(_WorldSpaceCameraPos - i.vertex); // vector from vertex to camera pos
    float3 halfwayLightCameraDir = normalize(lightDir + cameraDir);

    float normalDotLight = max(0.0, dot(lightDir, normalizedNormal));
    float normalDotView = max(0.0, dot(lightDir, cameraDir));
    
    float3 ambient = _AmbientColor * _AmbientAttenuation;

    // lambertian diffuse
    float3 diffuseReflectance = _DiffuseCoeff / PI;
    float3 diffuse = _WaterColor * _LightColor0.rgb * normalDotLight * diffuseReflectance;

    // specular reflection
    float specularIntensity = pow(max(0.0, dot(normalizedNormal, halfwayLightCameraDir)), _SpecularConcentration); // also multiplied by normalDotLight to simulate how specular highlights are more pronounced when the light hits the surface directly
    float3 specular = _LightColor0.rgb * _SpecularCoeff * specularIntensity;
    

    float3 finalColor = ambient + diffuse + specular;
    return float4(finalColor, 1.0f);
}
            ENDCG
        }
    }
}
