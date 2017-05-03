using System;
using UnityEngine;

namespace StixGames
{
	/// <summary>
	/// This class is a base point for displacing the grass. 
	/// It's really nothing else than a texture painter, with some vector transformations for the displacement.
	/// </summary>
	public static class GrassManipulationUtility
	{ 
		/// <summary>
		/// Returns the texture from the transform or throws a exception if it wasn't found.
		/// </summary>
		/// <param name="target"></param>
		/// <param name="getColorHeight">If true returns color/height texture instead of the displacement texture.</param>
		/// <returns></returns>
		public static Texture2D GetGrassTexture(Transform target, bool getColorHeight)
		{
			var material = target.GetComponent<Renderer>().material;
			var tex = material.GetTexture(getColorHeight ? "_ColorMap" :  "_Displacement") as Texture2D;

			if (tex == null)
			{
				throw new InvalidOperationException("You have to add a texture (or texture-adder component) if you want to use dynamic grass.");
			}

			return tex;
		}

		/// <summary>
		/// This uses the forward and right vectors as a matrix and returns its reverse.
		/// </summary>
		/// <param name="forward"></param>
		/// <param name="right"></param>
		/// <param name="inverseForward"></param>
		/// <param name="inverseRight"></param>
		public static void Invert2x2Matrix(Vector2 forward, Vector2 right, out Vector2 inverseForward, out Vector2 inverseRight)
		{
			float det = right.x * forward.y - right.y * forward.x;
			inverseRight = new Vector2(forward.y, -right.y) / det;
			inverseForward = new Vector2(-forward.x, right.x) / det;
		}

	    /// <summary>
	    /// Gets the 2x2 matrix that tranforms from world to texture space.
	    /// Uses raycasts, so don't overuse it.
	    /// </summary>
	    /// <param name="pos"></param>
	    /// <param name="rayDir"></param>
	    /// <param name="maxDistance"></param>
	    /// <param name="offset"></param>
	    /// <param name="layerMask"></param>
	    /// <param name="texCoord"></param>
	    /// <param name="forward"></param>
	    /// <param name="right"></param>
	    /// <returns>Returns the transform of the object that was hit. That doesn't really belong in this function, but at least is uses one raycast less.</returns>
	    public static Transform GetWorldToTextureSpaceMatrix(Vector3 pos, Vector3 rayDir, float maxDistance, float offset, LayerMask layerMask, out Vector2 texCoord, out Vector2 forward, out Vector2 right)
		{
			Ray ray = new Ray(pos, rayDir.normalized);
			RaycastHit hit;

            Debug.DrawRay(ray.origin, ray.direction * maxDistance, Color.red);

			if (Physics.Raycast(ray, out hit, maxDistance, layerMask))
			{
				texCoord = hit.textureCoord;

				forward = GetTexCoordDifference(hit.transform, pos, texCoord, Vector3.forward * offset, maxDistance, layerMask);
				right = GetTexCoordDifference(hit.transform, pos, texCoord, Vector3.right * offset, maxDistance, layerMask);
				return hit.transform;
			}

			texCoord = Vector2.zero;
			forward = Vector2.zero;
			right = Vector2.zero;
			return null;
		}

		public static bool GetWorldToTextureSpaceMatrix(Ray ray, float offset, Collider collider, out RaycastHit hit, out Vector2 forward, out Vector2 right)
		{
			if (collider.Raycast(ray, out hit, Mathf.Infinity))
			{
				forward = GetTexCoordDifference(ray.origin, hit.textureCoord, Vector3.forward * offset, collider);
				right = GetTexCoordDifference(ray.origin, hit.textureCoord, Vector3.right * offset, collider);
				return true;
			}

			hit = new RaycastHit();
			forward = Vector2.zero;
			right = Vector2.zero;
			return false;
		}

		private static Vector2 GetTexCoordDifference(Transform targetObject, Vector3 pos, Vector2 texCoords, Vector3 offset, float maxDistance, LayerMask layerMask)
		{
			Ray ray = new Ray(pos + offset, Vector3.down);
			RaycastHit hit;

			//Send ray in dir to check for 
			if (Physics.Raycast(ray, out hit, maxDistance, layerMask) && hit.transform == targetObject)
			{
				return (hit.textureCoord - texCoords) / offset.magnitude;
			}

			ray.direction = -ray.direction;
			if (Physics.Raycast(ray, out hit, maxDistance, layerMask) && hit.transform == targetObject)
			{
				return (texCoords - hit.textureCoord) / offset.magnitude;
			}

			return Vector2.zero;
		}

		private static Vector2 GetTexCoordDifference(Vector3 pos, Vector2 texCoords, Vector3 offset, Collider collider)
		{
			Ray ray = new Ray(pos + offset, Vector3.down);
			RaycastHit hit;

			//Send ray in dir to check for 
			if (collider.Raycast(ray, out hit, Mathf.Infinity))
			{
				return (hit.textureCoord - texCoords) / offset.magnitude;
			}

			ray.direction = -ray.direction;
			if (collider.Raycast(ray, out hit, Mathf.Infinity))
			{
				return (texCoords - hit.textureCoord) / offset.magnitude;
			}

			return Vector2.zero;
		}

		/// <summary>
		/// Converts a vector to a world space normal map color.
		/// </summary>
		/// <param name="vec"></param>
		/// <returns></returns>
		public static Vector2 VectorToColorSpace(Vector2 vec)
		{
			return (vec + Vector2.one) * 0.5f;
		}

		/// <summary>
		/// Converts a world space normal map color (vector) to a world space vector.
		/// </summary>
		/// <param name="vec"></param>
		/// <returns></returns>
		public static Vector2 ColorToVectorSpace(Vector2 vec)
		{
			return vec * 2 - Vector2.one;
		}
	}
}
