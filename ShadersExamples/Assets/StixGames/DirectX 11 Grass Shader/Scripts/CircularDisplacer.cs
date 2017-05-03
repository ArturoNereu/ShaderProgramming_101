using UnityEngine;
using System.Collections;

namespace StixGames
{
    [AddComponentMenu("StixGames/Circular Displacer")]
	public class CircularDisplacer : MonoBehaviour
	{
		public float pressureThreshold = 0.05f;
		public float maxAngle = 180;
		public float radius = 0.5f;

        public bool directionalDisplacement;

        public float displacementStrength = 1;
		public float displacementFalloff = 1;
		public float pressureStrength = 1;
		public float pressureFalloff = 1;

		public Vector3 offset = Vector3.up;
		public Vector3 rayDirection = Vector3.down;
		public float maxDistance = 1.2f;

        public bool blendChanges;
        public float blendSpeed = 5;

	    public LayerMask grassLayer;

        private Vector3 lastPosition;

		private void Update()
		{
			RoundDisplacement();

		    if (directionalDisplacement)
		    {
		        lastPosition = transform.position;
		    }
		}

		private void RoundDisplacement()
		{
			Vector2 texCoord, texForward, texRight, inverseTexForward, inverseTexRight;

			Vector3 rayOrigin = transform.TransformPoint(offset);

			Transform target = GrassManipulationUtility.GetWorldToTextureSpaceMatrix(rayOrigin, rayDirection, maxDistance, 0.1f, grassLayer,
				out texCoord, out texForward, out texRight);

			if (target == null)
			{
				return;
			}

			//Get texture of grass object
			var tex = GrassManipulationUtility.GetGrassTexture(target, false);

			//Invert the 2x2 world to texture space matrix.
			GrassManipulationUtility.Invert2x2Matrix(texForward, texRight, out inverseTexForward, out inverseTexRight);

			inverseTexForward.Normalize();
			inverseTexRight.Normalize();

			//Convert the world space radius to a pixel radius in texture space. This requires square textures.
			int pixelRadius = (int) (radius * texForward.magnitude * tex.width);

			//Calculate the pixel coordinates of the point where the raycast hit the texture.
			Vector2 mid = new Vector2(texCoord.x * tex.width, texCoord.y * tex.height);

			//Calculate the pixel area where the texture will be changed
			int targetX = (int) (mid.x - pixelRadius);
			int targetY = (int) (mid.y - pixelRadius);
			int rectX = Mathf.Clamp(targetX, 0, tex.width);
			int rectY = Mathf.Clamp(targetY, 0, tex.height);
			int width = Mathf.Min(targetX + pixelRadius * 2, tex.width) - targetX;
			int height = Mathf.Min(targetY + pixelRadius * 2, tex.height) - targetY;

		    mid -= new Vector2(rectX, rectY);
            
			//Get pixels
			Color[] pixels = tex.GetPixels(rectX, rectY, width, height);

			Vector3 forward = transform.forward;

			//Iterate trough all pixels
			for (int y = 0; y < height; y++)
			{
				for (int x = 0; x < width; x++)
				{
					var pixel = pixels[x + y * width];

					Vector2 dir = (new Vector2(x, y) - mid) / pixelRadius;

					//Texture space to world space
					dir = dir.x * inverseTexRight + dir.y * inverseTexForward;

					float pressure = 1 - pressureStrength * CalcFalloff(dir.magnitude, pressureFalloff);

					//Check angle and pressure threshold
					Vector2 characterForward = new Vector2(forward.x, forward.z);
					if (pixel.b > pressureThreshold && Vector2.Angle(dir, characterForward) < maxAngle)
					{
					    Vector2 displacementDir;

					    if (directionalDisplacement)
					    {
					        var temp = transform.position - lastPosition;
                            displacementDir = new Vector2(temp.x, temp.z);
					    }
					    else
					    {
                            displacementDir = dir;
                        }

                        float falloff = CalcFalloff(dir.magnitude, displacementFalloff);

                        //Falloff and strength
                        dir = displacementDir.normalized * falloff * displacementStrength;

						//To color space
						dir = GrassManipulationUtility.VectorToColorSpace(dir);

					    Color newColor = new Color(dir.x, dir.y, pressure, 1);

                        //Adds the new color to the pixel array
                        pixels[x + y * width] = blendChanges ? Color.Lerp(pixels[x+y*width], newColor, Time.deltaTime * blendSpeed) : newColor;
					}
				}
			}

			//Save pixels and apply them to the texture
			tex.SetPixels(rectX, rectY, width, height, pixels);

			//Search for texture updater, which prevents multiply applys per frame (for multiple displacers)
		    TextureUpdater updater = target.GetComponent<TextureUpdater>();

		    if (updater == null)
		    {
		        updater = target.gameObject.AddComponent<TextureUpdater>();
		        updater.targetTexture = tex;
		    }

            updater.RequestTextureUpdate();
		}

		/// <summary>
		/// Calculates the falloff of a round displacement.
		/// </summary>
		/// <param name="distance">The distance to the center of the displacement. Should be 0 at the middle and 1 at the edge.</param>
		/// <param name="falloff"></param>
		/// <returns></returns>
		private static float CalcFalloff(float distance, float falloff)
		{
			return Mathf.Pow(Mathf.Max(1.0f - distance, 0.0f), falloff);
		}
	}
}
