using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using static System.Runtime.InteropServices.Marshal; // required for SizeOf

public class GenerateWaves : MonoBehaviour
{
    // Wave Properties
    public int waveNumber = 64;
    public Color waterColor;
    public Color ambientColor;
    public float ambientAttenuation;
    public float diffuseCoeff = 0.5f;
    public float specularCoeff = 0.5f;
    public float specularConcentration = 90f;
    public float fresnelConcentration = 90f;
    public float fresnelStrength = 0.1f;
    private int prevWaveNumber = 64;
    private int minDirection = -1;
    private int maxDirection = 1;
    private float minSpeed = 1f;
    public float maxSpeed = 30f;
    private float minAmplitude = 0.1f;
    public float maxAmplitude = 10f;
    public float minWaveLength = 0.5f;
    public float maxWaveLength = 10f;
    public float minPhase = 0.5f;
    public float maxPhase = 10f;

    // Buffers
    private ComputeBuffer waveBuffer;
    private Wave[] waves;

    // Scene references
    private Material waveMat;
    private Transform sunTransform;
    private Light sunLight;

    private struct Wave
    {
        private Vector2 direction;
        private float speed;
        private float amplitude;
        private float frequency;
        private float phase;
        public Wave(Vector2 direction, float speed, float amplitude, float phase, float waveLength)
        {
            this.direction = direction;
            this.speed = speed;
            this.amplitude = amplitude;
            this.phase = phase;
            this.frequency = 2 / waveLength;
        }
    }

    void Start()
    {
        GameObject sunObj = GameObject.FindWithTag("Sun");
        sunTransform = sunObj.transform;
        sunLight = sunObj.GetComponent<Light>();
        waveMat = GetComponent<Renderer>().material;
        ReGenBuffers();
        ReGenerateWaves();
        SetShaderVars();
    }

    // Update is called once per frame
    void Update()
    {
        if (prevWaveNumber != waveNumber)
        {
            ReGenBuffers();
            prevWaveNumber = waveNumber;
            ReGenerateWaves();
        }
        if (Input.GetKeyDown(KeyCode.P))
        {
            ReGenerateWaves();
        }
        Debug.Log(sunTransform.forward);
        SetShaderVars();
    }

    void SetShaderVars()
    {
        waveMat.SetVector("_SunDirection", sunTransform.forward);
        waveMat.SetVector("_WaterColor", waterColor);
        waveMat.SetVector("_AmbientColor", ambientColor);
        waveMat.SetFloat("_AmbientAttenuation", ambientAttenuation);
        waveMat.SetFloat("_DiffuseCoeff", diffuseCoeff);
        waveMat.SetFloat("_SpecularCoeff", specularCoeff);
        waveMat.SetFloat("_SpecularConcentration", specularConcentration);
        waveMat.SetFloat("_FresnelConcentration", fresnelConcentration);
        waveMat.SetFloat("_FresnelStrength", fresnelStrength);
    }

    void ReGenBuffers()
    {
        waveBuffer = new ComputeBuffer(waveNumber, SizeOf(typeof(Wave)));
        waves = new Wave[waveNumber];
        waveMat.SetInt("_WaveNumber", waveNumber);
    }

    void ReGenerateWaves()
    {
        for (int i = 0; i < waveNumber; i++)
        {
            Vector2 direction = Vector2.zero;
            while (direction == Vector2.zero)
            {
                direction = new Vector2(Random.Range(minDirection, maxDirection), Random.Range(minDirection, maxDirection));
            }
            float speed = Random.Range(minSpeed, maxSpeed);
            float amplitude = Random.Range(minAmplitude, maxAmplitude);
            float waveLength = Random.Range(minWaveLength, maxWaveLength);
            float phase = Random.Range(minPhase, maxPhase);
            waves[i] = new Wave(direction, speed, amplitude, phase, waveLength);
        }
        waveBuffer.SetData(waves);
        waveMat.SetBuffer("_Waves", waveBuffer);
    }

    // Setters for runtime input fields
    Color BuildColor(string inputR, string inputG, string inputB)
    {
        float r = float.Parse(inputR) / 255.0f;
        float g = float.Parse(inputG) / 255.0f;
        float b = float.Parse(inputB) / 255.0f;
        return new Color(r, g, b);
    }

    public void SetLightingValues()
    {
        GameObject controlsParent = GameObject.FindGameObjectWithTag("LightingControlsParent");
        TMP_InputField[] inputFields = controlsParent.GetComponentsInChildren<TMP_InputField>();
        for (int i = 0; i < inputFields.Length; i++)
        {
            if (!float.TryParse(inputFields[i].text, out _))
            {
                Debug.LogError("Field number " + i + " could not be parsed. Is it a float?");
                return;
            }
        }
        waterColor = BuildColor(inputFields[0].text, inputFields[1].text, inputFields[2].text);
        float inputX = float.Parse(inputFields[3].text);
        float inputY = float.Parse(inputFields[4].text);
        float inputZ = float.Parse(inputFields[5].text);
        sunTransform.rotation = Quaternion.LookRotation(new Vector3(inputX, inputY, inputZ));
        sunLight.color = BuildColor(inputFields[6].text, inputFields[7].text, inputFields[8].text);
        ambientColor = BuildColor(inputFields[9].text, inputFields[10].text, inputFields[11].text);
        ambientAttenuation = float.Parse(inputFields[12].text);
        diffuseCoeff = float.Parse(inputFields[13].text);
        specularCoeff = float.Parse(inputFields[14].text);
        specularConcentration = float.Parse(inputFields[15].text);
        fresnelStrength = float.Parse(inputFields[16].text);
        fresnelConcentration = float.Parse(inputFields[17].text);
        SetShaderVars();
    }

    public void SetWaveValues()
    {
        GameObject controlsParent = GameObject.FindGameObjectWithTag("WaveControlsParent");
        TMP_InputField[] inputFields = controlsParent.GetComponentsInChildren<TMP_InputField>();
        for (int i = 0; i < inputFields.Length; i++)
        {
            if (!float.TryParse(inputFields[i].text, out _))
            {
                Debug.LogError("Field number " + i + " could not be parsed. Is it a float?");
                return;
            }
        }
        waveNumber = int.Parse(inputFields[0].text);
        maxSpeed = float.Parse(inputFields[1].text);
        maxAmplitude = float.Parse(inputFields[2].text);
        minWaveLength = float.Parse(inputFields[3].text);
        maxWaveLength = float.Parse(inputFields[4].text);
        minPhase = float.Parse(inputFields[5].text);
        maxPhase = float.Parse(inputFields[6].text);
        SetShaderVars();
        ReGenerateWaves();
    }
}
