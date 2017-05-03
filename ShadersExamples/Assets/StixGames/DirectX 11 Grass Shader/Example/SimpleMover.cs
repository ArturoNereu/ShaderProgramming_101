using UnityEngine;
using System.Collections;

public class SimpleMover : MonoBehaviour
{
    public float speed = 5;

	// Update is called once per frame
	void Update ()
    {
	    transform.position += speed * Vector3.right * Input.GetAxis("Horizontal") * Time.deltaTime;
        transform.position += speed * Vector3.forward * Input.GetAxis("Vertical") * Time.deltaTime;
    }
}
