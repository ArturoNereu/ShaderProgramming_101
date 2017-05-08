using UnityEditor;
using UnityEditor.SceneManagement;

public class SceneSwitcherMenu
{
	[MenuItem("Shaders101/Shader1")]
    public static void OpenScene01()
    {
        LoadScene("Scene01");
    }

    [MenuItem("Shaders101/Shader2")]
    public static void OpenScene02()
    {
        LoadScene("Scene02");
    }

    [MenuItem("Shaders101/Shader3")]
    public static void OpenScene03()
    {
        LoadScene("Scene03");
    }

    [MenuItem("Shaders101/Shader4")]
    public static void OpenScene04()
    {
        LoadScene("Scene04");
    }

    [MenuItem("Shaders101/Shader6")]
    public static void OpenScene06()
    {
        LoadScene("Scene06");
    }

    [MenuItem("Shaders101/Shader7")]
    public static void OpenScene07()
    {
        LoadScene("Scene07");
    }

    [MenuItem("Shaders101/Shader8")]
    public static void OpenScene08()
    {
        LoadScene("Scene08");
    }

    [MenuItem("Shaders101/Shader9")]
    public static void OpenScene09()
    {
        LoadScene("Scene09");
    }

    [MenuItem("Shaders101/Shader10")]
    public static void OpenScene10()
    {
        LoadScene("Scene10");
    }

    [MenuItem("Shaders101/Shader11")]
    public static void OpenScene11()
    {
        LoadScene("Scene11");
    }

    [MenuItem("Shaders101/Shader13")]
    public static void OpenScene13()
    {
        LoadScene("Scene13");
    }

    static void LoadScene(string sceneName)
    {
        EditorSceneManager.OpenScene("Assets/Scenes/" + sceneName  + ".unity");
    }
}
