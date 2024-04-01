using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class FFTOcean : MonoBehaviour
{
   
    public ComputeShader FFTCalCS;
    public ComputeShader GerstnerCS;
    public int TextureSizePow = 9;
    public int MeshSize = 100;          //Mesh number
    public float MeshLength = 512;
    public float A = 73;                //Phillips parameter  wave height
    public bool useGerstnerWave;        
    [Header("set if create the Gerstner wave before the FFT or not")]
    public bool createGerstnerBefore;   //set if create the Gerstner wave before the FFT or not
    public float GerstnerR = -0.3f;     //Gerstner wave r
    public float GerstnerA = 1f;        //Gerstner wave A
    public float GerstnerB = 0.5f;        //Gerstner wave B
    public float LambdaX = -1;           //Displace strength X
    public float LambdaZ = -1;           //Displace strength Z
    public float HeightScale = 30;      //Height influence   for generating the final displace texture
    public float BubblesThreshold = 0.86f;
    public float BubbleScale = 1;
    public float WindScale = 30;        //for WindAndSeed
    public Vector4 WindAndSeed = new Vector4(-1f, -1f, 0, 0);    //x, y define the direction of winds,  z,w define the random seed    using for DonelanBannerDirectionExp and Phillips -> creating HeightSpectrum
    public float TimeScale = 1;         //Time influence 
   

    public Material OceanMaterial;
    public Material InfiniteMaterial;
    public Material DisplaceXMat;
    public Material DisplaceYMat;
    public Material DisplaceZMat;
    public Material DisplaceMat;
    public Material NormalMat;
    public Material BubblesMat;

    private int fftSize;
    private float time;

    private int[] meshTranIndices;
    private Vector3[] vertPositons;
    private Vector2[] uvPositions;
    private Mesh mesh;
    private MeshFilter filter;
    private MeshRenderer render;


    private int kernelGetGaussianRandom;
    private int kernelCreateHeightSpectrum;
    private int kernelCreateDisplaceSpectrum;
    private int kernelFFTHorizontal;
    private int kernelFFTHorizontalEnd;
    private int kernelFFTVertical;
    private int kernelFFTVerticalEnd;
    private int kernelDisplaceTextureGeneration;
    private int kernelCreateNormalAndBubble;

    private int kernelCreateGerstnerWaveBeforeFFT;
    private int kernelCreateGerstnerWaveAfterFFT;

    private RenderTexture GaussianRandomRT;
    private RenderTexture HeightSpectrumRT;
    private RenderTexture DisplaceXSpectrumRT;
    private RenderTexture DisplaceZSpectrumRT;  
    private RenderTexture OutputRT;

    public RenderTexture FFT_DisplaceRT { get { return DisplaceRT; } }
    private RenderTexture DisplaceRT;
    public RenderTexture FFT_NormalRT { get { return NormalRT; } }
    private RenderTexture NormalRT;
    public RenderTexture FFT_BubblesRT { get { return BubblesRT; } }
    private RenderTexture BubblesRT;

    private Vector4[] oceanObjectsPos;

    private bool isRender = false;
    private bool isAnimate = true;
    private float animationTime = 0;


    private void Awake()
    {
        filter = gameObject.GetComponent<MeshFilter>();
        if (!filter)
        {
            filter = gameObject.AddComponent<MeshFilter>();
        }

        render = gameObject.GetComponent<MeshRenderer>();
        if (!render)
        {
            render = gameObject.AddComponent<MeshRenderer>();
        }
        mesh = new Mesh();
        filter.mesh = mesh;
        render.material = OceanMaterial;

        oceanObjectsPos = new Vector4[transform.childCount];
        for(int i = 0; i < transform.childCount; i++)
        {
            Vector3 tempPos = transform.GetChild(i).position;
            tempPos.y += HeightScale;
            oceanObjectsPos[i] = tempPos;
            
        }
    }

    void Start()
    {
        CreateMesh();
        InitalCSValue();
    }


    public void startRenderOcean(bool animate, float time)
    {
        isRender = true;
        isAnimate = animate;
        animationTime = time;
    }

    public void stopRenderOcean()
    {
        isRender = false;
    }
    
    void Update()
    {
        if (isRender)
        {
            if (isAnimate)
            {
                if(time >= animationTime * TimeScale)
                {
                    time = 0;
                }
            }
            time += Time.deltaTime * TimeScale;
            ComputeOceanValue();
        }
        
    }

    void ComputeOceanValue()
    {
        WindAndSeed.z = Random.Range(1f, 10f);
        WindAndSeed.w = Random.Range(1f, 10f);
        Vector2 wind = new Vector2(WindAndSeed.x, WindAndSeed.y);
        wind = wind.normalized;
        //wind.Normalize();
        wind *= WindScale; 
        FFTCalCS.SetVector("WindAndSeed", new Vector4(wind.x, wind.y, WindAndSeed.z, WindAndSeed.w));
        FFTCalCS.SetFloat("Time", time);
       

        FFTCalCS.SetTexture(kernelCreateHeightSpectrum, "GaussianRandomRT", GaussianRandomRT);
        FFTCalCS.SetTexture(kernelCreateHeightSpectrum, "HeightSpectrumRT", HeightSpectrumRT);
        FFTCalCS.Dispatch(kernelCreateHeightSpectrum, fftSize / 8, fftSize / 8, 1);

        FFTCalCS.SetTexture(kernelCreateDisplaceSpectrum, "HeightSpectrumRT", HeightSpectrumRT);
        FFTCalCS.SetTexture(kernelCreateDisplaceSpectrum, "DisplaceXSpectrumRT", DisplaceXSpectrumRT);
        FFTCalCS.SetTexture(kernelCreateDisplaceSpectrum, "DisplaceZSpectrumRT", DisplaceZSpectrumRT);
        FFTCalCS.Dispatch(kernelCreateDisplaceSpectrum, fftSize / 8, fftSize / 8, 1);

        if (useGerstnerWave && createGerstnerBefore)
        {
            GerstnerCS.SetTexture(kernelCreateGerstnerWaveBeforeFFT, "HeightSpectrumRT", HeightSpectrumRT);
            GerstnerCS.SetTexture(kernelCreateGerstnerWaveBeforeFFT, "DisplaceXSpectrumRT", DisplaceXSpectrumRT);
            GerstnerCS.SetTexture(kernelCreateGerstnerWaveBeforeFFT, "DisplaceZSpectrumRT", DisplaceZSpectrumRT);
            GerstnerCS.Dispatch(kernelCreateGerstnerWaveBeforeFFT, fftSize / 8, fftSize / 8, 1);
        }
        


        //FFTHorizontal
        for (int m = 1; m <= TextureSizePow; m++)
        {
            int ns = (int)Mathf.Pow(2, m - 1);
            FFTCalCS.SetInt("Ns", ns);
            if(m == TextureSizePow)
            {
                ComputeFFT(kernelFFTHorizontalEnd, ref HeightSpectrumRT);
                ComputeFFT(kernelFFTHorizontalEnd, ref DisplaceXSpectrumRT);
                ComputeFFT(kernelFFTHorizontalEnd, ref DisplaceZSpectrumRT);
            }
            else
            {
                ComputeFFT(kernelFFTHorizontal, ref HeightSpectrumRT);
                ComputeFFT(kernelFFTHorizontal, ref DisplaceXSpectrumRT);
                ComputeFFT(kernelFFTHorizontal, ref DisplaceZSpectrumRT);
            }
        }

        //FFTVertical
        for (int m = 1; m <= TextureSizePow; m++)
        {
            int ns = (int)Mathf.Pow(2, m - 1);
            FFTCalCS.SetInt("Ns", ns);
            if(m == TextureSizePow)
            {
                ComputeFFT(kernelFFTVerticalEnd, ref HeightSpectrumRT);
                ComputeFFT(kernelFFTVerticalEnd, ref DisplaceXSpectrumRT);
                ComputeFFT(kernelFFTVerticalEnd, ref DisplaceZSpectrumRT);
            }
            else
            {
                ComputeFFT(kernelFFTVertical, ref HeightSpectrumRT);
                ComputeFFT(kernelFFTVertical, ref DisplaceXSpectrumRT);
                ComputeFFT(kernelFFTVertical, ref DisplaceZSpectrumRT);
            }
        }

        
        FFTCalCS.SetTexture(kernelDisplaceTextureGeneration, "HeightSpectrumRT", HeightSpectrumRT);
        FFTCalCS.SetTexture(kernelDisplaceTextureGeneration, "DisplaceXSpectrumRT", DisplaceXSpectrumRT);
        FFTCalCS.SetTexture(kernelDisplaceTextureGeneration, "DisplaceZSpectrumRT", DisplaceZSpectrumRT);
        FFTCalCS.SetTexture(kernelDisplaceTextureGeneration, "DisplaceRT", DisplaceRT);
        FFTCalCS.Dispatch(kernelDisplaceTextureGeneration, fftSize / 8, fftSize / 8, 1);

        if (useGerstnerWave && !createGerstnerBefore)
        {
            
            GerstnerCS.SetTexture(kernelCreateGerstnerWaveAfterFFT, "DisplaceRT", DisplaceRT);
            GerstnerCS.Dispatch(kernelCreateGerstnerWaveAfterFFT, fftSize / 8, fftSize / 8, 1);
        }

      
        FFTCalCS.SetTexture(kernelCreateNormalAndBubble, "DisplaceRT", DisplaceRT);
        FFTCalCS.SetTexture(kernelCreateNormalAndBubble, "NormalRT", NormalRT);
        FFTCalCS.SetTexture(kernelCreateNormalAndBubble, "BubblesRT", BubblesRT);
        FFTCalCS.Dispatch(kernelCreateNormalAndBubble, fftSize / 8, fftSize / 8, 1);

        SetMaterial();
    }


    void ComputeFFT(int kernelId, ref RenderTexture input)
    {
        FFTCalCS.SetTexture(kernelId, "InputRT", input);
        FFTCalCS.SetTexture(kernelId, "OutputRT", OutputRT);
        FFTCalCS.Dispatch(kernelId, fftSize / 8, fftSize / 8, 1);
        RenderTexture rt = input;
        input = OutputRT;
        OutputRT = rt;
    }

    void SetMaterial()
    {
        
        OceanMaterial.SetTexture("_Displace", DisplaceRT);
        OceanMaterial.SetTexture("_Normal", NormalRT);
        OceanMaterial.SetTexture("_Bubble", BubblesRT);
        
        DisplaceXMat.SetTexture("_MainTex", DisplaceXSpectrumRT);
        DisplaceYMat.SetTexture("_MainTex", HeightSpectrumRT);
        DisplaceZMat.SetTexture("_MainTex", DisplaceZSpectrumRT);
        DisplaceMat.SetTexture("_MainTex", DisplaceRT);
        NormalMat.SetTexture("_MainTex", NormalRT);
        BubblesMat.SetTexture("_MainTex", BubblesRT);

    }


    void CreateMesh()
    {
        meshTranIndices = new int[(MeshSize - 1) * (MeshSize - 1) * 6];
        vertPositons = new Vector3[MeshSize * MeshSize];
        uvPositions = new Vector2[MeshSize * MeshSize];

        int tranIndex = 0;
        for(int i = 0; i < MeshSize; i++)
        {
            for (int j=0; j < MeshSize; j++)
            {
                int index = i * MeshSize + j;
                vertPositons[index] = new Vector3((j - MeshSize / 2) * MeshLength / MeshSize, 0, (i - MeshSize / 2) * MeshLength / MeshSize);
                uvPositions[index] = new Vector2(j / (MeshSize - 1f), i / (MeshSize - 1f));

                if(i != MeshSize - 1 && j != MeshSize - 1)
                {
                    meshTranIndices[tranIndex++] = index;
                    meshTranIndices[tranIndex++] = index + MeshSize;
                    meshTranIndices[tranIndex++] = index + MeshSize + 1;

                    meshTranIndices[tranIndex++] = index;
                    meshTranIndices[tranIndex++] = index + MeshSize + 1;
                    meshTranIndices[tranIndex++] = index + 1;
                }
               

            }
        }
        mesh.vertices = vertPositons;
        mesh.SetIndices(meshTranIndices, MeshTopology.Triangles, 0);
        mesh.uv = uvPositions;
        
        filter.mesh = mesh;
    }

    void InitalCSValue()
    {
        fftSize = (int)Mathf.Pow(2, TextureSizePow);
        if (GaussianRandomRT != null && GaussianRandomRT.IsCreated())
        {
            GaussianRandomRT.Release();
            HeightSpectrumRT.Release();
            DisplaceXSpectrumRT.Release();
            DisplaceZSpectrumRT.Release();
           
            OutputRT.Release();
            DisplaceRT.Release();
            NormalRT.Release();
            BubblesRT.Release();
        }

        GaussianRandomRT = CreateRenderTexture(fftSize);
        HeightSpectrumRT = CreateRenderTexture(fftSize);
        DisplaceXSpectrumRT = CreateRenderTexture(fftSize);
        DisplaceZSpectrumRT = CreateRenderTexture(fftSize);
       
        OutputRT = CreateRenderTexture(fftSize);
        DisplaceRT = CreateRenderTexture(fftSize);
        NormalRT = CreateRenderTexture(fftSize);
        BubblesRT = CreateRenderTexture(fftSize);

        kernelGetGaussianRandom = FFTCalCS.FindKernel("GetGaussianRandom");
        kernelCreateHeightSpectrum = FFTCalCS.FindKernel("CreateHeightSpectrum");
        kernelCreateDisplaceSpectrum = FFTCalCS.FindKernel("CreateDisplaceSpectrum");
        kernelFFTHorizontal = FFTCalCS.FindKernel("FFTHorizontal");
        kernelFFTHorizontalEnd = FFTCalCS.FindKernel("FFTHorizontalEnd");
        kernelFFTVertical = FFTCalCS.FindKernel("FFTVertical");
        kernelFFTVerticalEnd = FFTCalCS.FindKernel("FFTVerticalEnd");
        kernelDisplaceTextureGeneration = FFTCalCS.FindKernel("DisplaceTextureGeneration");
        kernelCreateNormalAndBubble = FFTCalCS.FindKernel("CreateNormalAndBubble");

        kernelCreateGerstnerWaveBeforeFFT = GerstnerCS.FindKernel("CreateGerstnerWaveBeforeFFT");
        kernelCreateGerstnerWaveAfterFFT = GerstnerCS.FindKernel("CreateGerstnerWaveAfterFFT");

        FFTCalCS.SetInt("N", fftSize);
        FFTCalCS.SetFloat("OceanLength", MeshLength);
        FFTCalCS.SetFloat("A", A);
        FFTCalCS.SetFloat("HeightScale", HeightScale);
        FFTCalCS.SetFloat("LambdaX", LambdaX);
        FFTCalCS.SetFloat("LambdaZ", LambdaZ);
        FFTCalCS.SetFloat("BubblesThreshold", BubblesThreshold);
        FFTCalCS.SetFloat("BubbleScale", BubbleScale);
        GerstnerCS.SetFloat("GerstnerR", GerstnerR);
        GerstnerCS.SetFloat("GerstnerA", GerstnerA);
        GerstnerCS.SetFloat("GerstnerB", GerstnerB);
        GerstnerCS.SetVectorArray("childs", oceanObjectsPos);
      //  GerstnerCS.SetFloat("touchHeight", waveTouchHeight);

        FFTCalCS.SetTexture(kernelGetGaussianRandom, "GaussianRandomRT", GaussianRandomRT);
        FFTCalCS.Dispatch(kernelGetGaussianRandom, fftSize / 8, fftSize / 8, 1);

    }

    RenderTexture CreateRenderTexture(int size)
    {
        RenderTexture tex = new RenderTexture(size, size, 0, RenderTextureFormat.ARGBFloat);
        tex.enableRandomWrite = true;
        tex.Create();
        return tex;
    }

    void SetRenderTexture(ref RenderTexture tex, int size)
    {
        tex = RenderTexture.GetTemporary(size, size, 0, RenderTextureFormat.ARGBFloat);
        
    }
}
