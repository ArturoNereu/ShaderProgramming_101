//VacuumShaders 2014
// https://www.facebook.com/VacuumShaders

using UnityEngine;
using System.Collections.Generic;
using System.Linq;


namespace VacuumShaders
{
    namespace CurvedWorld
    {
        [AddComponentMenu("VacuumShaders/Curved World/Example/Cylindrical Tower/Scene Manager")]
        public class CylindricalTower_SceneManager : MonoBehaviour
        {
            //////////////////////////////////////////////////////////////////////////////
            //                                                                          // 
            //Variables                                                                 //                
            //                                                                          //               
            //////////////////////////////////////////////////////////////////////////////
            static public CylindricalTower_SceneManager get;

            public float speed = 1;
            public GameObject[] chunks;

            public GameObject[] cars;

            static public float chunkSize = 60;
            static public Vector3 moveVector = new Vector3(-1, 0, 0);
            static public GameObject lastChunk;

            List<Material> listMaterials;
            //////////////////////////////////////////////////////////////////////////////
            //                                                                          // 
            //Unity Functions                                                           //                
            //                                                                          //               
            //////////////////////////////////////////////////////////////////////////////
            void Awake()
            { 
                get = this;

                
                //Instantiate chunks
                for (int i = 0; i < chunks.Length; i++)
                {
                    GameObject obj = (GameObject)Instantiate(chunks[i]);
                    //obj.transform.Rotate(Vector3.up, 90);

                    obj.transform.position = new Vector3(-(chunks.Length / 2) * chunkSize + i * chunkSize, 0, 0);

                    lastChunk = obj;
                }

                //Instantiate cars
                for (int i = 0; i < cars.Length; i++)
                {
                    Instantiate(cars[i]);
                }
            } 

            // Use this for initialization
            void Start()
            {
                Renderer[] renderers = FindObjectsOfType(typeof(Renderer)) as Renderer[];

                listMaterials = new List<Material>();
                foreach (Renderer _renderer in renderers)
                {
                    listMaterials.AddRange(_renderer.sharedMaterials);
                }

                listMaterials = listMaterials.Distinct().ToList();
            }

            //////////////////////////////////////////////////////////////////////////////
            //                                                                          // 
            //Custom Functions                                                          //
            //                                                                          //               
            //////////////////////////////////////////////////////////////////////////////

            public void DestroyChunk(CylindricalTower_Chunk moveElement)
            {
                Vector3 newPos = lastChunk.transform.position;
                newPos.x += chunkSize;


                lastChunk = moveElement.gameObject;
                lastChunk.transform.position = newPos;
            }

            public void DestroyCar(CylindricalTower_Car car)
            {
                GameObject.Destroy(car.gameObject);

                Instantiate(cars[Random.Range(0, cars.Length)]);
            }
        }
    }
}