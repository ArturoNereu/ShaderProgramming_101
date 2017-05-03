using UnityEngine;
using System.Collections;

namespace StixGames
{
    [RequireComponent(typeof (Camera))]
    [ExecuteInEditMode]
    [AddComponentMenu("StixGames/Render Texture Displacement")]
    public class RenderTextureDisplacement : MonoBehaviour
    {
        public float borderSmoothingArea = 2;

        private Camera cam;

        // Use this for initialization
        private void OnEnable()
        {
            cam = GetComponent<Camera>();

            if (!cam.orthographic)
            {
                Debug.LogError(
                    "Your displacment camera should be in orthographic mode, or grass displacement will look strange.");
            }

            if (cam.targetTexture == null)
            {
                Debug.LogError("Your displacment camera needs a render texture, or grass displacement will not work.");
            }

            cam.backgroundColor = new Color(0, 0, 1, 1);
            cam.clearFlags = CameraClearFlags.SolidColor;

            Shader.EnableKeyword("GRASS_RENDERTEXTURE_DISPLACEMENT");

            Shader.SetGlobalTexture("_GrassRenderTextureDisplacement", cam.targetTexture);
        }

        private void OnDisable()
        {
            Shader.DisableKeyword("GRASS_RENDERTEXTURE_DISPLACEMENT");
        }

        // Update is called once per frame
        private IEnumerator OnPreCull()
        {
            Shader.SetGlobalFloat("_GrassDisplacementBorderArea", borderSmoothingArea);

            //Save original position and set camera to be pixel perfect
            Vector3 realPosition = transform.position;

            float pixelWidth = (2*cam.orthographicSize)/cam.pixelWidth;
            float pixelHeight = (2*cam.orthographicSize)/cam.pixelHeight;

            Vector3 pos = realPosition;
            pos.x -= pos.x%pixelWidth;
            pos.z -= pos.z%pixelHeight;
            transform.position = pos;

            //Update camera rotation
            transform.rotation = Quaternion.Euler(90, 0, 0);

            Vector3 bottomLeft = cam.ScreenToWorldPoint(Vector3.zero);
            float width = (2*cam.orthographicSize)*cam.aspect;
            float height = (2*cam.orthographicSize)/cam.aspect;

            Vector4 renderArea = new Vector4(bottomLeft.x, bottomLeft.z, width, height);

            Shader.SetGlobalVector("_GrassRenderTextureArea", renderArea);

            //Wait for end of frame to reset the actual position
            yield return new WaitForEndOfFrame();
            transform.position = realPosition;
        }
    }
}