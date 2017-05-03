using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;
using StixGames.GrassShader;
using Object = UnityEngine.Object;

public class GrassEditor : MaterialEditor
{
	private static readonly string[] grassTypeLabels =
	{
	"Simple", "Simple with density", "1 Texture", "2 Textures",
	"3 Textures", "4 Textures"
};

	private static readonly string[] grassTypeString =
	{
	"SIMPLE_GRASS", "SIMPLE_GRASS_DENSITY", "ONE_GRASS_TYPE", "TWO_GRASS_TYPES", "THREE_GRASS_TYPES",
	"FOUR_GRASS_TYPES"
};

	private const int defaultGrassType = 0;

	private static readonly string[] lightingModeLabels = { "Unlit", "Unshaded", "Inverted Specular PBR", "Default PBR" };
	private static readonly string[] lightingModes = { "GRASS_UNLIT_LIGHTING", "GRASS_UNSHADED_LIGHTING", "", "GRASS_PBR_LIGHTING" };
	private const int defaultLightingMode = 2;

	private static readonly string[] densityModeLabels = { "Value Based Density", "Vertex Density", "Texture Density" };

	private static readonly string[] defaultKeywords = { "SIMPLE_GRASS", "GRASS_HEIGHT_SMOOTHING" };

	public override void OnInspectorGUI()
	{
		if (!isVisible)
		{
			return;
		}

		bool forceUpdate = false;
		Material targetMat = target as Material;
		string[] originalKeywords = targetMat.shaderKeywords;

		//Set default values when the material is newly created
		if (originalKeywords.Length == 0)
		{
			originalKeywords = defaultKeywords;

			targetMat.shaderKeywords = defaultKeywords;
			EditorUtility.SetDirty(targetMat);
		}

		//Grass type
		int grassType = -1;
		for (int i = 0; i < grassTypeLabels.Length; i++)
		{
			if (originalKeywords.Contains(grassTypeString[i]))
			{
				grassType = i;
				break;
			}
		}
		if (grassType < 0)
		{
			grassType = defaultGrassType;
			forceUpdate = true;
		}

		//Lighting mode
		int lightingMode = -1;
		for (int i = 0; i < lightingModeLabels.Length; i++)
		{
			if (originalKeywords.Contains(lightingModes[i]))
			{
				lightingMode = i;
				break;
			}
		}
		if (lightingMode < 0)
		{
			lightingMode = defaultLightingMode;
			forceUpdate = true;
		}

		//Density mode
		var densityMode = GrassEditorUtility.GetDensityMode(targetMat);

		bool ignoreGISpecular = originalKeywords.Contains("GRASS_IGNORE_GI_SPECULAR");
		bool widthSmoothing = originalKeywords.Contains("GRASS_WIDTH_SMOOTHING");
		bool heightSmoothing = originalKeywords.Contains("GRASS_HEIGHT_SMOOTHING");
		bool objectMode = originalKeywords.Contains("GRASS_OBJECT_MODE");
		bool topViewCompensation = originalKeywords.Contains("GRASS_TOP_VIEW_COMPENSATION");
		bool surfaceNormal = originalKeywords.Contains("GRASS_FOLLOW_SURFACE_NORMAL");
		bool useTextureAtlas = originalKeywords.Contains("GRASS_USE_TEXTURE_ATLAS");

		//Grass painter
		if (Selection.activeObject == null || AssetDatabase.Contains(Selection.activeObject))
		{
			EditorGUILayout.LabelField("To open the grass painter, select a scene object with a grass material.");
			EditorGUILayout.LabelField("For Unity Terrain you can open it from Window > Stix Games > GrassPainter");
		}
		else
		{
			if (GUILayout.Button("Open Grass Painter"))
			{
				GrassPainterWindow.OpenWindow();
			}
		}
		EditorGUILayout.Space();

		EditorGUI.BeginChangeCheck();

		EditorGUILayout.LabelField("Shader Variants", EditorStyles.boldLabel);
		EditorGUILayout.LabelField("Grass Modes", EditorStyles.boldLabel);
		grassType = EditorGUILayout.Popup("Grass type:", grassType, grassTypeLabels);
		densityMode = (DensityMode)EditorGUILayout.Popup("Density mode:", (int)densityMode, densityModeLabels);
		EditorGUILayout.Separator();

		EditorGUILayout.LabelField("Grass Lighting", EditorStyles.boldLabel);
		lightingMode = EditorGUILayout.Popup("Lighting mode:", lightingMode, lightingModeLabels);
		ignoreGISpecular = GUILayout.Toggle(ignoreGISpecular, 
			new GUIContent("Ignore global specular lighting", "If checked, the specular lighting from the " +
															  "global illumination engine will be ignored. " +
															  "Skyboxes will no longer reflect on the grass."));
		EditorGUILayout.Separator();

		EditorGUILayout.LabelField("Level of Detail Interpolation", EditorStyles.boldLabel);
		widthSmoothing = GUILayout.Toggle(widthSmoothing, "Smooth grass width");
		heightSmoothing = GUILayout.Toggle(heightSmoothing, "Smooth grass height");
		EditorGUILayout.Separator();

		EditorGUILayout.LabelField("Object / World Space Modes", EditorStyles.boldLabel);
		objectMode = GUILayout.Toggle(objectMode, "Object space mode");
		surfaceNormal = GUILayout.Toggle(surfaceNormal, "Follow surface normals");
		EditorGUILayout.Separator();

		EditorGUILayout.LabelField("Other Shader Variants", EditorStyles.boldLabel);
		topViewCompensation = GUILayout.Toggle(topViewCompensation, "Improve viewing grass from above");
		EditorGUILayout.Separator();

		useTextureAtlas = grassType >= 2 && GUILayout.Toggle(useTextureAtlas, "Use texture atlas");
		EditorGUILayout.Separator();

		if (EditorGUI.EndChangeCheck() || forceUpdate)
		{
			Undo.RecordObject(targetMat, "Changed grass shader keywords");

			var keywords = new List<string>();

			keywords.Add(grassTypeString[grassType]);
			keywords.Add(lightingModes[lightingMode]);
			keywords.Add(GrassEditorUtility.DensityModes[(int)densityMode]);

			if (ignoreGISpecular)
			{
				keywords.Add("GRASS_IGNORE_GI_SPECULAR");
			}

			if (widthSmoothing)
			{
				keywords.Add("GRASS_WIDTH_SMOOTHING");
			}

			if (heightSmoothing)
			{
				keywords.Add("GRASS_HEIGHT_SMOOTHING");
			}

			if (objectMode)
			{
				keywords.Add("GRASS_OBJECT_MODE");
			}

			if (topViewCompensation)
			{
				keywords.Add("GRASS_TOP_VIEW_COMPENSATION");
			}

			if (surfaceNormal)
			{
				keywords.Add("GRASS_FOLLOW_SURFACE_NORMAL");
			}

			if (useTextureAtlas)
			{
				keywords.Add("GRASS_USE_TEXTURE_ATLAS");
			}

			targetMat.shaderKeywords = keywords.ToArray();
			EditorUtility.SetDirty(targetMat);
		}

		EditorGUILayout.LabelField("Shader Settings", EditorStyles.boldLabel);
		serializedObject.Update();
		var theShader = serializedObject.FindProperty("m_Shader");
		if (isVisible && !theShader.hasMultipleDifferentValues && theShader.objectReferenceValue != null)
		{
			EditorGUIUtility.fieldWidth = 64;
			EditorGUI.BeginChangeCheck();

			int grassLabel = 1;
			var properties = GetMaterialProperties(new Object[] { targetMat });
			foreach (var property in properties)
			{
				//Ignore unused grass types
				if ((grassType < 3 && property.name.Contains("01")) ||
					(grassType < 4 && property.name.Contains("02")) ||
					(grassType < 5 && property.name.Contains("03")))
				{
					break;
				}

				// =========== Labels ==================
				if (property.name == "_EdgeLength")
				{
					EditorGUILayout.LabelField("Performance Settings", EditorStyles.boldLabel);
				}
				if (property.name == "_GrassFadeStart")
				{
					EditorGUILayout.Space();
					EditorGUILayout.LabelField("Visual Settings", EditorStyles.boldLabel);
				}
				if (property.name == "_ColorMap")
				{
					EditorGUILayout.Space();
					EditorGUILayout.LabelField("Base Textures", EditorStyles.boldLabel);
				}
				if (property.name == "_WindParams")
				{
					EditorGUILayout.Space();
					EditorGUILayout.LabelField("Wind Settings", EditorStyles.boldLabel);
				}

				//Grass type label
				if (property.name.Contains("_GrassTex"))
				{
					EditorGUILayout.Space();
					EditorGUILayout.LabelField("Grass Type Nr. " + grassLabel, EditorStyles.boldLabel);
					grassLabel++;
				}

				// ============ Non standard settings =============
				//Max tessellation can only be a int between 1 and 6
				if (property.name == "_MaxTessellation")
				{
					property.floatValue = EditorGUILayout.IntSlider(property.displayName, (int)property.floatValue,
						1, 6);
					continue;
				}

				//Hide texture atlas settings if not active
				if (property.name.Contains("_TextureAtlas"))
				{
					if (useTextureAtlas)
					{
						property.floatValue = Math.Max(EditorGUILayout.IntField(property.displayName, (int)property.floatValue), 1);
					}
					continue;
				}

				// ============ Standard settings =============
				//Density
				if (property.name.Contains("_Density"))
				{
					//Vertex density
					if (densityMode == DensityMode.Vertex || grassType == 0)
					{
						continue;
					}

					//Texture density
					if (densityMode == DensityMode.Texture && property.name == "_DensityValues")
					{
						continue;
					}

					//Density value
					if (densityMode == DensityMode.Value && property.name == "_Density")
					{
						continue;
					}
				}

				//In simple grass, ignore grass texture
				if ((grassType == 0 || grassType == 1) && property.name.Contains("_GrassTex"))
				{
					continue;
				}

				DrawProperty(property);
			}

			if (EditorGUI.EndChangeCheck())
			{
				PropertiesChanged();
			}
		}
	}

	private void DrawProperty(MaterialProperty property)
	{
		switch (property.type)
		{
			case MaterialProperty.PropType.Range: // float ranges
				RangeProperty(property, property.displayName);
				break;

			case MaterialProperty.PropType.Float: // floats
				FloatProperty(property, property.displayName);
				break;

			case MaterialProperty.PropType.Color: // colors
				ColorProperty(property, property.displayName);
				break;

			case MaterialProperty.PropType.Texture: // textures
				TextureProperty(property, property.displayName);

				GUILayout.Space(6);
				break;

			case MaterialProperty.PropType.Vector: // vectors
				VectorProperty(property, property.displayName);
				break;

			default:
				GUILayout.Label("ARGH" + property.displayName + " : " + property.type);
				break;
		}
	}
}

