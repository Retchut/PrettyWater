Shader "Unlit/PrettyWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Amplitude ("Amplitude", float) = 1.0
        _Frequency ("Frequency", float) = 1.0
        _Phase ("Phase", float) = 1.0
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

            struct VertexData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            struct Wave {
                float2 direction;
                float speed;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Amplitude;
            float _Frequency;
            float _Phase;

            v2f vert (VertexData v)
            {
                Wave test;
                test.direction = float2(1,1);
                test.speed = 30.0;

                v2f o;
                o.vertex = mul(unity_ObjectToWorld, v.vertex); // get vertex world position
                float xzDisplacement = o.vertex.x * test.direction.x + o.vertex.z * test.direction.y;
                float heightOffset = _Amplitude * sin(xzDisplacement * _Frequency + _Phase * _Time * test.speed);
                o.vertex.y += heightOffset;
                o.vertex = UnityObjectToClipPos(o.vertex); // clip to world position
                o.uv = v.uv;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
