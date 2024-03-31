using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIController : MonoBehaviour
{
    public GameObject[] buttons;
    public GameObject[] tabs;

    void Start()
    {
        if (tabs.Length > 0)
        {
            foreach (GameObject tab in tabs)
            {
                tab.SetActive(false);
            }
            tabs[0].SetActive(true);
        }
    }

    public void MakeTabVisible(int i)
    {
        if (tabs[i] == null)
        {
            return;
        }

        if (tabs[i].activeSelf == true)
        {
            return;
        }

        foreach (GameObject tab in tabs)
        {
            tab.SetActive(false);
        }
        tabs[i].SetActive(true);
    }
}
