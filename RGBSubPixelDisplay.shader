Shader "Xiexe/RGBSubPixelDisplay" {
  Properties {
    _MainTex ("Emissive (RGB)", 2D) = "white" {}
    _shiftColor("Tiltshift Color", Color) = (0,0,0,1)
    _RGBSubPixelTex ("RGBSubPixelTex", 2D) = "white" {}
    _EmissionScale ("Emission Scale", Float) = 1
    _Glossiness ("Smoothness", Float) = 0.5
    _EmissionLM ("Emission (Lightmapper)", Float) = 1
    [Toggle] _DynamicEmissionLM ("Dynamic Emission (Lightmapper)", Int) = 0
    [Toggle(APPLY_GAMMA)] _ApplyGamma("Apply Gamma", Float) = 0
  }
  SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 200

      CGPROGRAM
      // Physically based Standard lighting model, and enable shadows on all light types
    #pragma surface surf Standard fullforwardshadows

      // Use shader model 3.0 target, to get nicer looking lighting
    #pragma target 3.0
    #pragma shader_feature _EMISSION
    #pragma multi_compile APPLY_GAMMA_OFF APPLY_GAMMA

    fixed _EmissionScale;
    fixed _EmissionLM;
    float _Glossiness;
    int _DynamicEmissionLM;
    sampler2D _MainTex;
    sampler2D _RGBSubPixelTex;
    float4 _shiftColor;

    struct Input {
      float2 uv_MainTex;
      float2 uv_RGBSubPixelTex;
      float3 viewDir;
      float3 worldNormal;
    };

    // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
    // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
    // #pragma instancing_options assumeuniformscaling
    UNITY_INSTANCING_CBUFFER_START(Props)
      // put more per-instance properties here
      UNITY_INSTANCING_CBUFFER_END

      void surf (Input IN, inout SurfaceOutputStandard o) {
        // emissive comes from texture

        fixed4 e = tex2D (_MainTex, IN.uv_MainTex) * _EmissionScale;

       //viewing angle for tilt shift
        float3 viewDir = IN.viewDir;
        float3 ase_worldNormal = WorldNormalVector( IN, IN.worldNormal );
        float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			  float4 worldNormals = mul(unity_ObjectToWorld,float4( ase_vertexNormal , 0.0 ));
        float vdn = dot(viewDir, worldNormals);

        o.Albedo = fixed4(0,0,0,0);
        o.Alpha = e.a;
      
      //Correct for gamma if being used for a VRC Stream script.
        #if APPLY_GAMMA
          e.rgb = pow(e.rgb,2.2);
        #endif
        
      //Do RGB pixels
        fixed4 rgbpixel = tex2D(_RGBSubPixelTex, IN.uv_RGBSubPixelTex);

        float pixelR = rgbpixel.r * e.r;
        float pixelG = rgbpixel.g * e.g;
        float pixelB = rgbpixel.b * e.b;

        float3 pixelValue = float3(pixelR, pixelG, pixelB);
      
      //Do the color shift at extreme viewing angles
        float3 screenCol = lerp(pixelValue, _shiftColor, saturate(1-vdn * 1.2));

      //Screens are emissive. Return it there.
        o.Emission = screenCol;
        o.Metallic = 0;
        o.Smoothness = _Glossiness;
      }
    ENDCG
  }
  FallBack "Diffuse"
}
