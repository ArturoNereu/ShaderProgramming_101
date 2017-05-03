using UnityEngine;
using System.Collections;

namespace StixGames
{
    /// <summary>
    /// A simple helper script that adds editable textures to a grass material
    /// You could also use a custom texture for this, just make sure to set it to editable by script in the importer settings.
    /// </summary>
    [AddComponentMenu("StixGames/Grass Texture Adder")]
    public class GrassTextureAdder : MonoBehaviour
	{
		public int size = 1024;

		public bool addColorHeight, addDisplacement;

		// Use this for initialization
		private void Start()
		{
			if (addColorHeight)
			{
				var tex = new Texture2D(size, size, TextureFormat.ARGB32, false, true);

				var pixels = new Color[size * size];
				for (int i = 0; i < pixels.Length; i++)
				{
					pixels[i] = new Color(1, 1, 1, 1);
				}

				tex.SetPixels(pixels);
				tex.Apply();

				GetComponent<Renderer>().material.SetTexture("_Displacement", tex);
			}

			if (addDisplacement)
			{
				var tex = new Texture2D(size, size, TextureFormat.ARGB32, false, true);

				var pixels = new Color[size * size];
				for (int i = 0; i < pixels.Length; i++)
				{
					pixels[i] = new Color(0.5f, 0.5f, 1, 1);
				}

				tex.SetPixels(pixels);
				tex.Apply();

				GetComponent<Renderer>().material.SetTexture("_Displacement", tex);
			}
		}
	}
}
