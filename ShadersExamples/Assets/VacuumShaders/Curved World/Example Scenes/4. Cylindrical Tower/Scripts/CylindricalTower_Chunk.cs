//VacuumShaders 2014
// https://www.facebook.com/VacuumShaders

using UnityEngine;
using System.Collections;


namespace VacuumShaders
{
    namespace CurvedWorld
    {
        [AddComponentMenu("VacuumShaders/Curved World/Example/Cylindrical Tower/Move Element")]
        public class CylindricalTower_Chunk : MonoBehaviour
        {
            //////////////////////////////////////////////////////////////////////////////
            //                                                                          // 
            //Unity Functions                                                           //                
            //                                                                          //               
            //////////////////////////////////////////////////////////////////////////////

            void Update()
            {
                transform.Translate(CylindricalTower_SceneManager.moveVector * CylindricalTower_SceneManager.get.speed * Time.deltaTime);
            }

            void FixedUpdate()
            {
                if (transform.position.x < -160)
                    CylindricalTower_SceneManager.get.DestroyChunk(this);
            }
        }
    }
}