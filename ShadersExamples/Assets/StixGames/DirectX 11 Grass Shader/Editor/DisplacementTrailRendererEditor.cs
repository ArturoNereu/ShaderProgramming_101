using UnityEditor;

[CustomEditor(typeof(DisplacementTrailRenderer))]
public class DisplacementTrailRendererEditor : Editor
{
    private SerializedProperty layer;

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        var trailRenderer = (DisplacementTrailRenderer) target;

        trailRenderer.layer = EditorGUILayout.LayerField("Layer", trailRenderer.layer);
    }
}