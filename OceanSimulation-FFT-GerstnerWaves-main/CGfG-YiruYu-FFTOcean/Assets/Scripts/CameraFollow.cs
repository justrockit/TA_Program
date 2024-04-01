using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CameraFollow : MonoBehaviour
{
    public Transform target;
    public float Height;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 pos = target.position;
        //pos.y = Height - (pos.y - Height);
        pos.y += Height;
        transform.position = pos;
    }
}
