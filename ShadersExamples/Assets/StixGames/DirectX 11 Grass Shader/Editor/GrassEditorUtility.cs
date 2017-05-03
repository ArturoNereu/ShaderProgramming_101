using System;
using System.Collections;
using UnityEngine;
using UnityEditor;
using System.Linq;

namespace StixGames.GrassShader
{
	public static class GrassEditorUtility
	{
		public static readonly string[] DensityModes = { "UNIFORM_DENSITY", "VERTEX_DENSITY", "" };

		public static DensityMode GetDensityMode(Material mat)
		{ 
			if (mat.IsKeywordEnabled(DensityModes[0]))
			{
				return DensityMode.Value;
			}

			if (mat.IsKeywordEnabled(DensityModes[1]))
			{
				return DensityMode.Vertex;
			}

			return DensityMode.Texture;
		}

		public static void SetDensityMode(Material mat, DensityMode target)
		{
			var density = GetDensityMode(mat);

			switch (density)
			{
				case DensityMode.Value:
					mat.DisableKeyword(DensityModes[0]);
					break;
				case DensityMode.Vertex:
					mat.DisableKeyword(DensityModes[1]);
					break;
			}

			mat.EnableKeyword(DensityModes[(int)target]);
		}
	}

	public enum DensityMode
	{
		Value,
		Vertex,
		Texture
	}
}
