using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class OceanView : MonoBehaviour
{
    public Material OceanViewDepth;
         
    public RenderTexture OceanRT { get { return _oceanRT; } }
    private RenderTexture _oceanRT;
    public RenderTexture OceanDepthRT { get { return _oceanDepthRT; } }
    private RenderTexture _oceanDepthRT;

    Camera camera;
    CommandBuffer cmd;

    
    void Start()
    {
        camera = this.GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        
        if (_oceanRT == null)
        {       
            _oceanRT = RenderTexture.GetTemporary(source.width, source.height);
           
        }
        if(_oceanDepthRT == null)
        {
            _oceanDepthRT = RenderTexture.GetTemporary(source.width, source.height);
        }
        Graphics.Blit(source, _oceanRT);
        Graphics.Blit(source, _oceanDepthRT, OceanViewDepth);

        Graphics.Blit(source, destination);
    }


    private void OnDestroy()
    {
        RenderTexture.ReleaseTemporary(_oceanRT);
        RenderTexture.ReleaseTemporary(_oceanDepthRT);
    }
}
