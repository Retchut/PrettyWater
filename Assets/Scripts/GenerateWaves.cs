using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static System.Runtime.InteropServices.Marshal; // required for SizeOf

public class Water : MonoBehaviour
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
    [SerializeField]
    private float maxSpeed = 30f;
    private float minAmplitude = 0.1f;
    [SerializeField]
    private float maxAmplitude = 10f;
    [SerializeField]
    private float minWaveLength = 0.5f;
    [SerializeField]
    private float maxWaveLength = 10f;
    [SerializeField]
    private float minPhase = 0.5f;
    [SerializeField]
    private float maxPhase = 10f;

    // Buffers
    private ComputeBuffer waveBuffer;
    private Wave[] waves;

    // Scene references
    [SerializeField]
    private Material waveMat;
    private Transform sun;

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
        sun = GameObject.FindWithTag("Sun").transform;
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
        if (Input.GetKeyDown(KeyCode.W))
        {
            ReGenerateWaves();
        }
        Debug.Log(sun.forward);
        SetShaderVars();
    }

    void SetShaderVars()
    {
        waveMat.SetVector("_SunDirection", sun.forward);
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
                // direction = new Vector2(1, 1);
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
}
