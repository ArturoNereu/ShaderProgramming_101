using UnityEngine;
using System.Collections;

namespace StixGames
{
    [AddComponentMenu("StixGames/Camera Follow")]
    public class CameraFollow : MonoBehaviour
    {
        public Transform follow;
        public float followHeight = 20;

        private void Update()
        {
            if (follow == null)
            {
                follow = Camera.main.transform;
                return;
            }

            transform.position = follow.position + Vector3.up*followHeight;
        }
    }
}
