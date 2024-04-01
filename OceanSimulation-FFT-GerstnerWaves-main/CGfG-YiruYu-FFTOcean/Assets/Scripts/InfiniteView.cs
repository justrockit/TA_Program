using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class InfiniteView : MonoBehaviour
{
    public OceanView OceanView;
    public Material material;
    public Transform OceanPlane;
    public FFTOcean fftOcean;
  //  public ReflectionProbe reflectionProbe;

    Camera camera;
    Camera oceanCamera;
    CommandBuffer cmd;
    

    private void Awake()
    {
        camera = this.GetComponent<Camera>();
        oceanCamera = OceanView.gameObject.GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.Depth | DepthTextureMode.MotionVectors | DepthTextureMode.DepthNormals;
        cmd = new CommandBuffer();
        cmd.name = "InfiniteView";
        camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, cmd);
    }
    
    /*
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        
        if(material != null)
        {
  
            if (cmd is null)
            {

                camera.RemoveAllCommandBuffers();
                cmd = new CommandBuffer();
                camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, cmd);
            }
            setCameraCmd2();
         
        }
        Graphics.Blit(source, destination);

    }
    */
    
    private void OnPreRender()
    {
        if (cmd is null)
        {
            
            camera.RemoveAllCommandBuffers();
            cmd = new CommandBuffer();
            camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, cmd);
        }

        // setCameraCmd();
        setCameraCmd2();
    }


    void setCameraCmd2()
    {
        cmd.Clear();
        cmd.BeginSample("InfiniteView");

        var screenImg = Shader.PropertyToID("_ScreenImage");
        cmd.GetTemporaryRT(screenImg, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
        cmd.SetRenderTarget(screenImg);
        cmd.Blit(BuiltinRenderTextureType.CameraTarget, screenImg);

        var oceanImg = Shader.PropertyToID("_OceanImage");
        cmd.GetTemporaryRT(oceanImg, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
        cmd.SetRenderTarget(oceanImg);
        cmd.Blit(OceanView.OceanRT, oceanImg);

        var oceanDepthImg = Shader.PropertyToID("_OceanDepthTex");
        cmd.GetTemporaryRT(oceanDepthImg, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
        cmd.SetRenderTarget(oceanDepthImg);
        cmd.Blit(OceanView.OceanDepthRT, oceanDepthImg);

        cmd.SetGlobalFloat("_OceanHeight", OceanPlane.position.y + fftOcean.HeightScale);
        cmd.SetGlobalFloat("_NearOceanHeight", OceanPlane.position.y + fftOcean.HeightScale);
        Matrix4x4 viewProjectionInverseMatrix = (camera.projectionMatrix * camera.worldToCameraMatrix).inverse * Matrix4x4.Scale(new Vector3(1, -1, 1));
        cmd.SetGlobalMatrix("_ViewProjectionInverseMatrix", viewProjectionInverseMatrix);
        cmd.SetGlobalVector("_CameraPos", OceanView.transform.position);
        cmd.SetGlobalVector("_CameraClipPlane", new Vector3(oceanCamera.nearClipPlane, oceanCamera.farClipPlane, oceanCamera.farClipPlane - oceanCamera.nearClipPlane));

        material.SetTexture("_Displace", fftOcean.FFT_DisplaceRT);
       // material.SetTexture("_Normal", fftOcean.FFT_NormalRT);
       // material.SetTexture("_Bubble", fftOcean.FFT_BubblesRT);

        cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        cmd.Blit(screenImg, BuiltinRenderTextureType.CameraTarget, material);

        cmd.ReleaseTemporaryRT(screenImg);
        cmd.EndSample("InfiniteView");
    }

    void setCameraCmd()
    {
        cmd.Clear();
        cmd.BeginSample("InfiniteView");
        
        var screenImg = Shader.PropertyToID("_ScreenImage");
        cmd.GetTemporaryRT(screenImg, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
        cmd.SetRenderTarget(screenImg);
        cmd.Blit(BuiltinRenderTextureType.CameraTarget, screenImg);
        cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        
        cmd.SetGlobalFloat("_OceanHeight", OceanPlane.position.y);
        Matrix4x4 viewProjectionInverseMatrix = (camera.projectionMatrix * camera.worldToCameraMatrix).inverse * Matrix4x4.Scale(new Vector3(1, -1, 1));
        cmd.SetGlobalMatrix("_ViewProjectionInverseMatrix", viewProjectionInverseMatrix);
        cmd.SetGlobalVector("_CameraPos", transform.position);
        cmd.SetGlobalVector("_CameraClipPlane", new Vector3(camera.nearClipPlane, camera.farClipPlane, camera.farClipPlane - camera.nearClipPlane));

      //  reflectionProbe.RenderProbe();
     //   material.SetTexture("_Reflection", reflectionProbe.realtimeTexture);
        material.SetTexture("_Displace", fftOcean.FFT_DisplaceRT);
        material.SetTexture("_Normal", fftOcean.FFT_NormalRT);
        material.SetTexture("_Bubble", fftOcean.FFT_BubblesRT);
        /*
        cmd.SetGlobalTexture("_Displace", DisplaceRT);
        cmd.SetGlobalTexture("_Normal", NormalRT);
        cmd.SetGlobalTexture("_Bubble", BubblesRT);
        */
        cmd.Blit(screenImg, BuiltinRenderTextureType.CameraTarget, material);
        
        
        cmd.ReleaseTemporaryRT(screenImg);
        cmd.EndSample("InfiniteView");
    }

}
