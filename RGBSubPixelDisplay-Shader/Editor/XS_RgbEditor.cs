using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using System;

public class XS_RgbEditor : ShaderGUI
{
    private static class Styles
    {
		//public static GUIContent  = new GUIContent("", "");
        public static GUIContent version = new GUIContent("v1.0.0", "The currently installed version.");
		public static GUIContent mainTex = new GUIContent("Main Texture", "The main texture, used to drive the emission.");
		public static GUIContent RGBMatrixTex = new GUIContent("RGB Matrix Texture", "The RGB pixel layout pattern. This controls how your subpixels look.");
    }

    //MaterialProperty albedoMap;
	MaterialProperty _MainTex;
	MaterialProperty _RGBSubPixelTex;
    MaterialProperty _shiftColor;
    MaterialProperty _EmissionIntensity; 
    MaterialProperty _Glossiness; 
    MaterialProperty _LightmapEmissionScale; 
    MaterialProperty _ApplyGamma;
    MaterialProperty _Saturation;
    MaterialProperty _Contrast;
    MaterialProperty _RedScale;
    MaterialProperty _GreenScale;
    MaterialProperty _BlueScale;

    public override void OnGUI(MaterialEditor m_MaterialEditor, MaterialProperty[] props)
    {
        Material material = m_MaterialEditor.target as Material;
        {
            //Find all the properties within the shader
				// = ShaderGUI.FindProperty("", props);
			_MainTex = ShaderGUI.FindProperty("_MainTex", props);
			_RGBSubPixelTex = ShaderGUI.FindProperty("_RGBSubPixelTex", props);
			_shiftColor	= ShaderGUI.FindProperty("_shiftColor", props);
			_EmissionIntensity	= ShaderGUI.FindProperty("_EmissionIntensity", props);
			_Glossiness	= ShaderGUI.FindProperty("_Glossiness", props);
			_ApplyGamma	= ShaderGUI.FindProperty("_ApplyGamma", props);
			_LightmapEmissionScale = ShaderGUI.FindProperty("_LightmapEmissionScale", props);
            _Saturation = ShaderGUI.FindProperty("_Saturation", props);
            _Contrast = ShaderGUI.FindProperty("_Contrast", props);
            _RedScale = ShaderGUI.FindProperty("_RedScale", props);
            _GreenScale = ShaderGUI.FindProperty("_GreenScale", props);
            _BlueScale = ShaderGUI.FindProperty("_BlueScale", props);
        }

        EditorGUI.BeginChangeCheck();
        {
		//display all the settings
        	m_MaterialEditor.TexturePropertySingleLine(Styles.mainTex, _MainTex);
            m_MaterialEditor.ShaderProperty(_shiftColor, "Shift Color", 2);
			m_MaterialEditor.ShaderProperty(_Glossiness, "Smoothness", 2);
            m_MaterialEditor.ShaderProperty(_EmissionIntensity, "Emission Scale", 2);
			m_MaterialEditor.ShaderProperty(_LightmapEmissionScale, "Lightmap Emission Scale", 2);
		// change the GI flag and fix it up with emissive as black if necessary
			m_MaterialEditor.LightmapEmissionFlagsProperty(MaterialEditor.kMiniTextureFieldLabelIndentLevel, true);
     	EditorGUILayout.Space();
        EditorGUILayout.Space();             
            m_MaterialEditor.TexturePropertySingleLine(Styles.RGBMatrixTex, _RGBSubPixelTex);
			m_MaterialEditor.TextureScaleOffsetProperty(_RGBSubPixelTex);
    	EditorGUILayout.Space();
        EditorGUILayout.Space();          
            m_MaterialEditor.ShaderProperty(_Saturation, "Saturation");
            m_MaterialEditor.ShaderProperty(_Contrast, "Contrast");
            m_MaterialEditor.ShaderProperty(_RedScale, "Red Scale");
            m_MaterialEditor.ShaderProperty(_GreenScale, "Green Scale");
            m_MaterialEditor.ShaderProperty(_BlueScale, "Blue Scale");
            m_MaterialEditor.ShaderProperty(_ApplyGamma, "Apply Gamma Fix");
		EditorGUILayout.Space();
		EditorGUILayout.Space();
			
        }
        DoFooter();
    }
    void DoFooter()
    {
        GUILayout.Label(Styles.version, new GUIStyle(EditorStyles.centeredGreyMiniLabel)
        {
            alignment = TextAnchor.MiddleCenter,
            wordWrap = true,
            fontSize = 12
        });
    }

    static void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
        {
            m.EnableKeyword(keyword);
        }
        else
        {
            m.DisableKeyword(keyword);
        }
    }
}
