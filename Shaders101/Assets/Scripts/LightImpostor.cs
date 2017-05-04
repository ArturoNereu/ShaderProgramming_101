using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightImpostor : MonoBehaviour
{
	//We will be updating this global vector on the update. All shaders can get this value
	void Update ()
    {
        Shader.SetGlobalVector("_lightDir", transform.forward);	
	}
}
