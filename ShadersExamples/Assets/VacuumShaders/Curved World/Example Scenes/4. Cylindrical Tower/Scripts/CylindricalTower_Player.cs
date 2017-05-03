//VacuumShaders 2014
// https://www.facebook.com/VacuumShaders

using UnityEngine;
using System.Collections;


namespace VacuumShaders
{
    namespace CurvedWorld
    {
        [AddComponentMenu("VacuumShaders/Curved World/Example/Cylindrical Tower/Player")]
        public class CylindricalTower_Player : MonoBehaviour
        {
            public enum SIDE { Left, Right }
            //////////////////////////////////////////////////////////////////////////////
            //                                                                          // 
            //Variables                                                                 //                
            //                                                                          //               
            //////////////////////////////////////////////////////////////////////////////
            static public CylindricalTower_Player get;

            Vector3 newPos;
            SIDE side;

            Animation animationComp;
            public AnimationClip moveLeft;
            public AnimationClip moveRight;

            //////////////////////////////////////////////////////////////////////////////
            //                                                                          // 
            //Unity Functions                                                           //                
            //                                                                          //               
            //////////////////////////////////////////////////////////////////////////////
            void Awake()
            {
                get = this;
            }

            // Use this for initialization
            void Start()
            {
                side = SIDE.Left;
                transform.position = new Vector3(-3.5f, 0, 0); 

                newPos = transform.position;

                animationComp = GetComponent<Animation>();


                Physics.gravity = new Vector3(0, -50, 0);
            }

            void OnDisable()
            {
                //Restor gravity
                Physics.gravity = new Vector3(0, -9.8f, 0);
            }

            // Update is called once per frame
            void Update()
            {
                if (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.A))
                {
                    if (side == SIDE.Right)
                    {
                        newPos = new Vector3(-3.5f, 0, 0);
                        side = SIDE.Left;

                        animationComp.Play(moveLeft.name);
                    }
                }
                else if (Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.D))
                {
                    if (side == SIDE.Left)
                    {
                        newPos = new Vector3(3.5f, 0, 0);
                        side = SIDE.Right;

                        animationComp.Play(moveRight.name);
                    }
                }

                transform.position = Vector3.Lerp(transform.position, newPos, Time.deltaTime * 10);
            }

            void OnCollisionEnter(Collision collision)
            {
                Vector3 force = (Vector3.forward + Vector3.up + Random.insideUnitSphere).normalized * Random.Range(100, 150);
                collision.rigidbody.AddForce(force, ForceMode.Impulse);

                CylindricalTower_Car car = collision.gameObject.GetComponent<CylindricalTower_Car>();
                if (car != null)
                {
                    car.speed = 1;
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