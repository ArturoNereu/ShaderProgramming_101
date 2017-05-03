using UnityEngine;

namespace StixGames
{
	[RequireComponent(typeof(MeshFilter))]
	public class ReadjustBoundingBox : MonoBehaviour
	{
		public float maxGrassHeight = 2;

		void Start ()
		{
			var mesh = GetComponent<MeshFilter>().mesh;
			var bounds = mesh.bounds;
			bounds.Expand(maxGrassHeight * 2);
			mesh.bounds = bounds;
			Destroy(this);
		}
	}
}
