using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class RenderCubeMapWizard : ScriptableWizard {

    public Transform m_renderFromPosition;
    public Cubemap m_cubemap;

    private void OnWizardCreate()
    {
        GameObject go = new GameObject("CubeCamera");

        go.transform.position = m_renderFromPosition.position;
        go.transform.rotation = Quaternion.identity;

        go.AddComponent<Camera>();
        go.GetComponent<Camera>().RenderToCubemap(m_cubemap);

        DestroyImmediate(go);
    }


    [MenuItem("GameObject/Render To CubeMap" )]
    static void RenderToCubeMap()
    {
        ScriptableWizard.DisplayWizard<RenderCubeMapWizard>("Render Cube", "Render!");
    }


}





