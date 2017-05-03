using UnityEngine;
using System.Collections;

namespace VacuumShaders
{
    namespace CurvedWorld
    {
        [AddComponentMenu("VacuumShaders/Curved World/Example/Cylindrical Tower/Car")]
        public class CylindricalTower_Car : MonoBehaviour
        {
            //////////////////////////////////////////////////////////////////////////////
            //                                                                          // 
            //Variables                                                                 //                
            //                                                                          //               
            //////////////////////////////////////////////////////////////////////////////

            Rigidbody rigidBody;
            public float speed = 1;

            //////////////////////////////////////////////////////////////////////////////
            //                                                                          // 
            //Unity Functions                                                           //                
            //                                                                          //               
            //////////////////////////////////////////////////////////////////////////////
            void Start()
            {
                rigidBody = GetComponent<Rigidbody>();

                transform.position = new Vector3(Random.Range(140, 240), 1, Random.Range(-3.5f, 3.5f));
                transform.Rotate(Vector3.up, 90);
               
                speed = Random.Range(1.5f, 2.5f);

            }

            void FixedUpdate()
            {
                rigidBody.MovePosition(transform.position + CylindricalTower_SceneManager.moveVector * CylindricalTower_SceneManager.get.speed * Time.deltaTime * speed);


                if (transform.position.y < -10)
                {
                    CylindricalTower_SceneManager.get.DestroyCar(this);
                }
            }

            //////////////////////////////////////////////////////////////////////////////
            //                                                                          // 
            //Custom Functions                                                          //
            //                                                                          //               
            //////////////////////////////////////////////////////////////////////////////
        }
    }
}