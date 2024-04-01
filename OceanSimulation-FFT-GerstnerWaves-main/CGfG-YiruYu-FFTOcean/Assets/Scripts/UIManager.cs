using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIManager : MonoBehaviour
{
    public Button btnStart;
    public Button btnStop;
    public Toggle togAnimate;
    public InputField inputTime;
    public FFTOcean fftOcean;

    private bool isAnimation = false;
 
    private float animationTime = 0;

    void Start()
    {
        btnStart.onClick.AddListener(onClickStart);
        btnStop.onClick.AddListener(onClickStop);
    }

    void onClickStart()
    {       
        isAnimation = togAnimate.isOn;
        if (isAnimation)
        {
            animationTime = float.Parse(inputTime.text);
            animationTime = animationTime <= 0 ? 0 : animationTime;
        }
        fftOcean.startRenderOcean(isAnimation, animationTime);
        btnStop.gameObject.SetActive(true);
        btnStart.gameObject.SetActive(false);
    }

    void onClickStop()
    {
        fftOcean.stopRenderOcean();
        btnStop.gameObject.SetActive(false);
        btnStart.gameObject.SetActive(true);
    }



    void Update()
    {
        
    }
}
