Shader "Xiexe/RGBSubPixelDisplay" {
  Properties {
    _MainTex("Emission (RGB)", 2D) = "white" {}
    _RGBSubPixelTex ("RGBSubPixelTex", 2D) = "white" {}
    _Glossiness ("Smoothness", Float) = 0.5

  //ALL OF THESE PROPERTIES ARE REQUIRED FOR THE CGINC TO WORK
    _shiftColor("Tiltshift Color", Color) = (0,0,0,1)
    _LightmapEmissionScale("Lightmap Emission Scale", Float) = 1
    _EmissionIntensity ("Screen Intensity", Float) = 1
    _EmissionIntensity2 ("Screen Intensity - 2", Float) = 1
    [Toggle(APPLY_GAMMA)] _ApplyGamma("Apply Gamma", Float) = 0
    [Toggle] _Backlight("Backlit Panel", Int) = 0
    //Color Correction
    [Header(  Color Balance)]
    _Saturation ("Saturation", Range(0,1)) = 1
    _Contrast ("Contrast", Range(0.01,2)) = 1
    _RedScale ("Red Scale", Range(-1,1)) = 1
    _GreenScale ("Green Scale", Range(-1,1)) = 1
    _BlueScale("Blue Scale", Range(-1,1)) = 1
  //END OF REQUIRED PROPERTIES FOR CGINC
    
    [HideInInspector] _texcoord2( "", 2D ) = "white" {}
    //needs to be here so the editor script stops throwing errors.
    //You can ignore it, just don't delete it. It doesn't actually do anything,
    //but without it, the editor script screams in pain. Hacky, I know.
    _EmissionColor ("Emission Color", Color) = (0,0,0,0)
  }
  SubShader {

      //DO ALL THE SCREEN STUFF
      Tags { "RenderType"="Opaque" }
      LOD 200

      CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
      #pragma surface surf Standard fullforwardshadows
        // Use shader model 3.0 target, to get nicer looking lighting
      #pragma target 3.0
      #pragma shader_feature _EMISSION
      #pragma multi_compile APPLY_GAMMA_OFF APPLY_GAMMA
      #pragma multi_compile HAS_ALPHA_OFF HAS_ALPHA

    //You will need to define your texture samplers yourself in other shaders
      sampler2D _MainTex;
      sampler2D _RGBSubPixelTex;
      

      float _Glossiness;
      float _EmissionIntensity2;
      
      struct Input {
        float2 uv_MainTex;
        float2 uv_texcoord2;
        float3 viewDir;
        float3 worldNormal;
      };
    //We need to include our CGINC file. This is important, otherwise you wont be able to call the function.
    //If you're in a fragment shader, just include this right before the pixel/fragment program.
      #include "RGBSubPixel.cginc"
      
      void surf (Input IN, inout SurfaceOutputStandard o) {
      
      //We need to sample the world normal and the ViewDir outside of our CGInc
      //So you'll need to do this part yourself in any shader you plug this into.
        float3 worldNormal = WorldNormalVector(IN, IN.worldNormal);
        float3 viewDir = IN.viewDir;

      //We need to call our function from the CGInc "RGBSubPixelConvert", 
      //and then feed in our MainTex, our SubPixel Tex, 
      //The UVs for both, the viewDir, and the WorldNormal.
        float4 finalCol = RGBSubPixelConvert(_MainTex, _RGBSubPixelTex, IN.uv_MainTex, IN.uv_texcoord2, viewDir, worldNormal);

        o.Albedo = float4(0,0,0,1);
        o.Alpha = 1;
        o.Emission = finalCol * _EmissionIntensity2;
        o.Metallic = 0;
        o.Smoothness = _Glossiness;
      }
    ENDCG
  }
  FallBack "Diffuse"
  CustomEditor "XS_RgbEditor"
}
