using System;
using StixGames;
using UnityEngine;

public class GrassPainter
{
	private const float EPSILON = 0.01f;

	public int Channel = 0;
	public int BrushMode = 0;
	public float Strength = 1;
	public float Size = 1;
	public float Softness = 0.5f;
	public float Spacing = 0.5f;
	public float Rotation = 0;

	/// <summary>
	/// The grass collider the brush will be applied to. Only set this when using ApplyBrush directly.
	/// </summary>
	public Collider GrassCollider;

	/// <summary>
	/// The density texture the brush will be applied to. Only set this when using ApplyBrush directly.
	/// </summary>
	public Texture2D Texture;

	public bool Draw(Ray ray)
	{
		RaycastHit hit;
		if (Physics.Raycast(ray, out hit))
		{
			GrassCollider = hit.collider;
			Texture = (Texture2D) hit.collider.GetComponent<Renderer>().material.mainTexture;

			ApplyBrush(hit.point);
			return true;
		}

		return false;
	}

	public void ApplyBrush(Vector3 hitPoint)
	{
		RaycastHit hit;
		Vector2 texForward, texRight;
		if (!GrassManipulationUtility.GetWorldToTextureSpaceMatrix(new Ray(hitPoint + Vector3.up * 1000, Vector3.down),
			EPSILON, GrassCollider, out hit, out texForward, out texRight))
		{
			return;
		}

		Vector2 texCoord = hit.textureCoord;

		//Convert the world space radius to a pixel radius in texture space. This requires square textures.
		int pixelRadius = (int)(Size * texForward.magnitude * Texture.width);

		//Calculate the pixel coordinates of the point where the raycast hit the texture.
		Vector2 mid = new Vector2(texCoord.x * Texture.width, texCoord.y * Texture.height);

		//Calculate the pixel area where the texture will be changed
		int targetStartX = (int)(mid.x - pixelRadius);
		int targetStartY = (int)(mid.y - pixelRadius);
		int startX = Mathf.Clamp(targetStartX, 0, Texture.width);
		int startY = Mathf.Clamp(targetStartY, 0, Texture.height);
		int width = Mathf.Min(targetStartX + pixelRadius * 2, Texture.width) - targetStartX;
		int height = Mathf.Min(targetStartY + pixelRadius * 2, Texture.height) - targetStartY;

		mid -= new Vector2(startX, startY);

		//Get pixels
		Color[] pixels = Texture.GetPixels(startX, startY, width, height);

		//Iterate trough all pixels
		for (int y = 0; y < height; y++)
		{
			for (int x = 0; x < width; x++)
			{
				int index = y * width + x;
				Vector2 uv = ((new Vector2(x, y) - mid) / pixelRadius) * 0.5f + new Vector2(0.5f, 0.5f);
				pixels[index] = ApplyBrushToPixel(pixels[index], uv);
			}
		}

		//Save pixels and apply them to the texture
		Texture.SetPixels(startX, startY, width, height, pixels);
		Texture.Apply();
	}

	private Color ApplyBrushToPixel(Color c, Vector2 v)
	{
		v -= new Vector2(0.5f, 0.5f);
		v *= 2;
		float distance = v.magnitude;

		//Calculate brush smoothness
		float value = SmoothStep(1, Mathf.Min(1 - Softness, 0.999f), distance);

		switch (BrushMode)
		{
			case 0:
				c = ChangeChannel(c, x => x + value * Strength);
				break;

			case 1:
				c = ChangeChannel(c, x => x - value * Strength);
				break;

			case 2:
				c = ChangeChannel(c, x => x * (1 - value) + Strength * value);
				break;
		}

		return c;
	}

	private Color ChangeChannel(Color c, Func<float, float> densityChange)
	{
		switch (Channel)
		{
			case 0:
				c.r = Mathf.Clamp01(densityChange(c.r));
				break;
			case 1:
				c.g = Mathf.Clamp01(densityChange(c.g));
				break;
			case 2:
				c.b = Mathf.Clamp01(densityChange(c.b));
				break;
			case 3:
				c.a = Mathf.Clamp01(densityChange(c.a));
				break;
			default:
				throw new InvalidOperationException("Channel number invalid");
		}
		return c;
	}

	private float SmoothStep(float edge0, float edge1, float x)
	{
		// Scale, bias and saturate x to 0..1 range
		x = Mathf.Clamp((x - edge0) / (edge1 - edge0), 0.0f, 1.0f);
		// Evaluate polynomial
		return x * x * (3 - 2 * x);
	}
}