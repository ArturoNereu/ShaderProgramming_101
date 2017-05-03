using UnityEngine;

public class TextureUpdater : MonoBehaviour
{
    public Texture2D targetTexture;
    private bool apply;

    void LateUpdate()
    {
        if (apply)
        {
            targetTexture.Apply(false);
            apply = false;
        }
    }

    public void RequestTextureUpdate()
    {
        apply = true;
    }
}
