using UnityEngine;
using System.Collections;
using StixGames;

public class GrassRegenerator : MonoBehaviour
{
    public float regenerationSpeed = 1;

    private Texture2D texture;
    private readonly Color originalColor = new Color(0.5f, 0.5f,1,1);

	void Update ()
	{
	    if (texture == null)
	    {
            texture = GrassManipulationUtility.GetGrassTexture(transform, false);
        }

	    Color[] pixels = texture.GetPixels();

	    for (int i = 0; i < pixels.Length; i++)
	    {
	        pixels[i] = Color.Lerp(pixels[i], originalColor, regenerationSpeed * Time.deltaTime);
	    }

        texture.SetPixels(pixels);

        //Search for texture updater, which prevents multiply applys per frame (for multiple displacers)
        TextureUpdater updater = GetComponent<TextureUpdater>();

        if (updater == null)
        {
            updater = gameObject.AddComponent<TextureUpdater>();
            updater.targetTexture = texture;
        }

        updater.RequestTextureUpdate();
    }
}
