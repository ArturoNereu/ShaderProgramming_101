using UnityEngine;
using System.Collections;

using VacuumShaders.CurvedWorld;

namespace VacuumShaders.CurvedWorld.Demo
{
    [AddComponentMenu("VacuumShaders/Curved World/Example/Follow")]
    [ExecuteInEditMode]
    public class Follow : MonoBehaviour
    {
        //////////////////////////////////////////////////////////////////////////////
        //                                                                          // 
        //Variables                                                                 //                
        //                                                                          //               
        //////////////////////////////////////////////////////////////////////////////
        public BEND_TYPE bendType;

        public Transform parent;

        public bool followX;
        public bool followY;
        public bool followZ;

        //////////////////////////////////////////////////////////////////////////////
        //                                                                          // 
        //Unity Functions                                                           //                
        //                                                                          //               
        //////////////////////////////////////////////////////////////////////////////
        void Start()
        {
            if (parent == null)
            {
                parent = transform.parent;
           }
        }
        
        void Update()
        {
            UpdatePosition();
        }

        void LateUpdate()
        {
            UpdatePosition();
        }
         
        //////////////////////////////////////////////////////////////////////////////
        //                                                                          // 
        //Custom Functions                                                          //                
        //                                                                          //               
        //////////////////////////////////////////////////////////////////////////////
        void UpdatePosition()
        {
            if (parent != null && CurvedWorld_Controller.get != null)
            {
                Vector3 newPos = CurvedWorld_Controller.get.TransformPoint(parent.position, bendType);

                if (followX == false)
                    newPos.x = transform.position.x;
                if (followY == false)
                    newPos.y = transform.position.y;
                if (followZ == false)
                    newPos.z = transform.position.z;

                transform.position = newPos;
            }
        }
    }
}
