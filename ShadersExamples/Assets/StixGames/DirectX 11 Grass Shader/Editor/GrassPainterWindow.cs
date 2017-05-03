using System;
using UnityEngine;
using System.IO;
using StixGames;
using StixGames.GrassShader;
using UnityEditor;

public class GrassPainterWindow : EditorWindow
{
	private static readonly string[] channelLabels = {
		"1",
		"2",
		"3",
		"4"
	};

	private static readonly string[] paintModeLabels = {
		"Add",
		"Remove",
		"Set",
	};

	private static bool useUndo = true;

	private static GrassPainterWindow window;

	private GameObject grassObject;
	private Material grassMaterial;
	private bool startedWithCollider;

	private int textureSize = 512;

	private bool mouseDown;
	private Vector3 lastPaintPos;
	private bool didDraw;
	private bool showCloseMessage;
	private bool showTargetSwitchMessage;
	private readonly GrassPainter grassPainter = new GrassPainter();

	public GrassPainter GrassPainter
	{
		get { return grassPainter; }
	}

	[MenuItem("Window/Stix Games/Grass Painter")]
	public static void OpenWindow()
	{
		window = GetWindow<GrassPainterWindow>();
		window.Show();
	}

	private void RecreateWindow()
	{
		window = Instantiate(this);
		window.Show();
	}

	private void OnGUI()
	{
		TextureSettings();

		BrushSettings();

		PainterSettings();
	}

	void OnFocus()
	{
		GrassPainter.Channel = EditorPrefs.GetInt("StixGames.Painter.Channel", GrassPainter.Channel);
		GrassPainter.BrushMode = EditorPrefs.GetInt("StixGames.Painter.BrushMode", GrassPainter.BrushMode);
		GrassPainter.Strength = EditorPrefs.GetFloat("StixGames.Painter.Strength", GrassPainter.Strength);
		GrassPainter.Size = EditorPrefs.GetFloat("StixGames.Painter.Size", GrassPainter.Size);
		GrassPainter.Softness = EditorPrefs.GetFloat("StixGames.Painter.Softness", GrassPainter.Softness);
		GrassPainter.Spacing = EditorPrefs.GetFloat("StixGames.Painter.Spacing", GrassPainter.Spacing);
		GrassPainter.Rotation = EditorPrefs.GetFloat("StixGames.Painter.Rotation", GrassPainter.Rotation);
		showCloseMessage = EditorPrefs.GetBool("StixGames.Painter.ShowCloseMessage", true);
		showTargetSwitchMessage = EditorPrefs.GetBool("StixGames.Painter.ShowTargetSwitchMessage", true);
		useUndo = EditorPrefs.GetBool("StixGames.Painter.UseUndo", true);

		SceneView.onSceneGUIDelegate -= OnSceneGUI;
		SceneView.onSceneGUIDelegate += OnSceneGUI;

		Undo.undoRedoPerformed -= SaveTexture;
		Undo.undoRedoPerformed += SaveTexture;
	}

	void OnDestroy()
	{
		SceneView.onSceneGUIDelegate -= OnSceneGUI;
		Undo.undoRedoPerformed -= SaveTexture;
		ResetRenderer(true);

		if (ShowUndoLossWarning(true))
		{
			Undo.ClearUndo(GrassPainter.Texture);
		}
		else
		{
			RecreateWindow();
		}
	}

	private bool ShowUndoLossWarning(bool isWindowClose)
	{
		if (isWindowClose && showCloseMessage || !isWindowClose && showTargetSwitchMessage)
		{
			string message = isWindowClose
				? "After closing the painter changes will be permanent, undo will no longer be possible."
				: "After switching grass object changes will be permanent, undo will no longer be possible.";

			int result = EditorUtility.DisplayDialogComplex("Make changes permanent?",
				message, isWindowClose ? "Close" : "Switch", "Cancel",
				isWindowClose ? "Close and don't show again" : "Switch and don't show again");

			if (result == 1)
			{
				return false;
			}

			if (result == 2)
			{
				if (showCloseMessage)
				{
					showCloseMessage = false;
					EditorPrefs.SetBool("StixGames.Painter.ShowCloseMessage", false);
				}
				else
				{
					showTargetSwitchMessage = false;
					EditorPrefs.SetBool("StixGames.Painter.ShowTargetSwitchMessage", false);
				}
			}
		}

		//Always accept if message is hidden
		return true;
	}

	private void TextureSettings()
	{
		if (grassObject == null)
		{
			EditorGUILayout.LabelField("No grass object selected. Select a grass object in the scene Hierarchy.");
			return;
		}

		EditorGUILayout.LabelField("Current object: " + grassObject.name);
		EditorGUILayout.Space();

		if (GrassEditorUtility.GetDensityMode(grassMaterial) != DensityMode.Texture)
		{
			EditorGUILayout.LabelField("The grass material is not in texture density mode.", EditorStyles.boldLabel);
			if (GUILayout.Button("Change material to texture density"))
			{
				GrassEditorUtility.SetDensityMode(grassMaterial, DensityMode.Texture);
			}

			EditorGUILayout.Space();
		}

		if (grassMaterial.GetTexture("_Density") == null)
		{
			EditorGUILayout.LabelField("Create new texture", EditorStyles.boldLabel);
			EditorGUILayout.Space();

			textureSize = EditorGUILayout.IntField("Texture Size", textureSize);

			if (GUILayout.Button("Create texture"))
			{
				//Select the path and return on cancel
				string path = EditorUtility.SaveFilePanelInProject("Create density texture", "newDensityTexture", "png",
					"Choose where to save the new density texture");

				if (path == null)
				{
					return;
				}

				//Create the new texture and save it at the selected path
				GrassPainter.Texture = new Texture2D(textureSize, textureSize, TextureFormat.ARGB32, false, true);

				Color[] colors = new Color[textureSize * textureSize];
				for (int i = 0; i < colors.Length; i++)
				{
					colors[i] = new Color(0, 0, 0, 0);
				}

				GrassPainter.Texture.SetPixels(colors);
				GrassPainter.Texture.Apply();

				File.WriteAllBytes(path, GrassPainter.Texture.EncodeToPNG());

				//Import and load the new texture
				AssetDatabase.ImportAsset(path);
				var importer = (TextureImporter)AssetImporter.GetAtPath(path);
				importer.wrapMode = TextureWrapMode.Clamp;
				importer.isReadable = true;
				importer.maxTextureSize = textureSize;
#if UNITY_5_5_OR_NEWER
				importer.sRGBTexture = false;
				importer.textureCompression = TextureImporterCompression.Uncompressed;
				importer.SetPlatformTextureSettings(new TextureImporterPlatformSettings
				{
					format = TextureImporterFormat.ARGB32,
					overridden = true,
				});
#else
				importer.linearTexture = true;
				importer.textureFormat = TextureImporterFormat.ARGB32;
#endif
				AssetDatabase.ImportAsset(path);

				GrassPainter.Texture = AssetDatabase.LoadAssetAtPath(path, typeof(Texture2D)) as Texture2D;

				//Set texture to material
				grassMaterial.SetTexture("_Density", GrassPainter.Texture);
			}

			EditorGUILayout.Space();
		}
	}

	private void BrushSettings()
	{
		EditorGUI.BeginChangeCheck();

		EditorGUILayout.LabelField("Brush settings", EditorStyles.boldLabel);

		EditorGUILayout.BeginHorizontal();
		EditorGUILayout.LabelField("Channel");
		grassPainter.Channel = GUILayout.SelectionGrid(grassPainter.Channel, channelLabels, 4);
		EditorGUILayout.EndHorizontal();

		EditorGUILayout.Space();

		EditorGUILayout.BeginHorizontal();
		EditorGUILayout.LabelField("Mode");
		grassPainter.BrushMode = GUILayout.SelectionGrid(grassPainter.BrushMode, paintModeLabels, 4);
		EditorGUILayout.EndHorizontal();

		//TODO: Make slider max value dynamically changeable by writing into field.
		//For now, just change the right value if you want more or less size
		grassPainter.Strength = EditorGUILayout.Slider("Strength", grassPainter.Strength, 0, 1);
		grassPainter.Size = EditorGUILayout.Slider("Size", grassPainter.Size, 0.01f, 50);
		grassPainter.Softness = EditorGUILayout.Slider("Softness", grassPainter.Softness, 0, 1);
		grassPainter.Spacing = EditorGUILayout.Slider("Spacing", grassPainter.Spacing, 0, 2);
		//rotation = EditorGUILayout.Slider("Rotation", rotation, 0, 360);

		if (EditorGUI.EndChangeCheck())
		{
			EditorPrefs.SetInt("StixGames.Painter.Channel", grassPainter.Channel);
			EditorPrefs.SetInt("StixGames.Painter.BrushMode", grassPainter.BrushMode);
			EditorPrefs.SetFloat("StixGames.Painter.Strength", grassPainter.Strength);
			EditorPrefs.SetFloat("StixGames.Painter.Size", grassPainter.Size);
			EditorPrefs.SetFloat("StixGames.Painter.Softness", grassPainter.Softness);
			EditorPrefs.SetFloat("StixGames.Painter.Spacing", grassPainter.Spacing);
			EditorPrefs.SetFloat("StixGames.Painter.Rotation", grassPainter.Rotation);
		}

		EditorGUILayout.Space();
	}

	private void PainterSettings()
	{
		EditorGUI.BeginChangeCheck();

		EditorGUILayout.LabelField("Painter settings", EditorStyles.boldLabel);

		useUndo = EditorGUILayout.ToggleLeft("Save Undo/Redo data (may cause lag)", useUndo);

		if (EditorGUI.EndChangeCheck())
		{
			EditorPrefs.SetBool("StixGames.Painter.UseUndo", useUndo);

			if (!useUndo && GrassPainter.Texture != null)
			{
				Undo.ClearUndo(GrassPainter.Texture);
			}
		}
	}

	void OnSceneGUI(SceneView sceneView)
	{
		BlockSceneSelection();

		UpdateInput();

		//Update grass renderer
		UpdateSelectedRenderer();

		if (grassObject == null)
		{
			return;
		}

		//Calculate ray from mouse cursor
		var ray = HandleUtility.GUIPointToWorldRay(Event.current.mousePosition);

		//Check if grass was hit
		RaycastHit hit;
		if (!GrassPainter.GrassCollider.Raycast(ray, out hit, Mathf.Infinity))
		{
			return;
		}

		Handles.color = new Color(1, 0, 0, 1);
		Handles.CircleCap(0, hit.point, Quaternion.LookRotation(Vector3.up), grassPainter.Size);

		//Paint
		if (mouseDown)
		{
			float newDist = Vector3.Distance(lastPaintPos, hit.point);

			//Check draw spacing
			if (!didDraw || newDist > grassPainter.Spacing * grassPainter.Size)
			{
				//Draw brush
				GrassPainter.ApplyBrush(hit.point);

				lastPaintPos = hit.point;
			}

			didDraw = true;
		}
	}

	private void BlockSceneSelection()
	{
		//Only block when a grass object is selected
		if (grassObject == null)
		{
			return;
		}

		//Disable selection in editor view, only painting will be accepted as input
		HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
	}

	private void UpdateInput()
	{
		if (GrassPainter.Texture != null && Event.current.type == EventType.MouseDown && Event.current.button == 0)
		{
			mouseDown = true;

			if (useUndo)
			{
				Undo.RegisterCompleteObjectUndo(GrassPainter.Texture, "Texture paint");
			}
		}
		if (Event.current.type == EventType.MouseUp && Event.current.button == 0)
		{
			mouseDown = false;

			if (didDraw)
			{
				SaveTexture();
				didDraw = false;
			}
		}
	}

	private void UpdateSelectedRenderer()
	{
		//Return if no new object was selected
		if (Selection.activeGameObject == null)
		{
			return;
		}

		//Return if the new object is not a grass object
		var newGrassObject = Selection.activeGameObject;
		Selection.activeGameObject = null;

		if (newGrassObject == grassObject)
		{
			return;
		}

		//Get the grass material, if non was found, return.
		var newGrassMaterial = GetGrassMaterial(newGrassObject);
		if (newGrassMaterial == null)
		{
			return;
		}

		//A new object was selected. If another object was selected before, tell the user that this will make changes permanent.
		if (grassObject != null && !ShowUndoLossWarning(false))
		{
			return;
		}

		//Clear undo history for current texture
		Undo.ClearUndo(GrassPainter.Texture);

		//Reset the previously selected grass object
		ResetRenderer(false);

		//Assign new grass object
		grassObject = newGrassObject;
		grassMaterial = newGrassMaterial;
		GrassPainter.Texture = grassMaterial.GetTexture("_Density") as Texture2D;

		GrassPainter.GrassCollider = grassObject.GetComponent<Collider>();
		startedWithCollider = GrassPainter.GrassCollider != null;

		//If the object had no collider, add one. It will be destroyed when deselected.
		if (!startedWithCollider)
		{
			AddTempCollider();
		}

		Repaint();
	}

	private Material GetGrassMaterial(GameObject newGrassObject)
	{
		var renderer = newGrassObject.GetComponent<Renderer>();
		if (renderer != null && renderer.sharedMaterial != null 
			&& renderer.sharedMaterial.shader != null 
			&& renderer.sharedMaterial.shader.name == "Stix Games/Grass")
		{
			return renderer.sharedMaterial;
		}

		var terrain = newGrassObject.GetComponent<Terrain>();
		if (terrain != null && terrain.materialTemplate != null
			&& terrain.materialTemplate.shader != null
			&& terrain.materialTemplate.shader.name == "Stix Games/Grass")
		{
			return terrain.materialTemplate;
		}

		return null;
	}

	private void AddTempCollider()
	{
		if (grassObject.GetComponent<Renderer>() != null)
		{
			GrassPainter.GrassCollider = grassObject.AddComponent<MeshCollider>();
			return;
		}

		if (grassObject.GetComponent<Terrain>() != null)
		{
			GrassPainter.GrassCollider = grassObject.AddComponent<TerrainCollider>();
			return;
		}
	}

	private void ResetRenderer(bool reselectPrevious)
	{
		if (reselectPrevious && grassObject != null)
		{
			Selection.activeGameObject = grassObject;
		}

		if (GrassPainter.GrassCollider != null && !startedWithCollider)
		{
			DestroyImmediate(GrassPainter.GrassCollider);
		}

		grassObject = null;
		grassMaterial = null;
		GrassPainter.GrassCollider = null;
	}

	private void SaveTexture()
	{
		string path = AssetDatabase.GetAssetPath(GrassPainter.Texture);
		File.WriteAllBytes(path, GrassPainter.Texture.EncodeToPNG());
	}

	//Taken from https://en.wikipedia.org/wiki/Smoothstep
}
