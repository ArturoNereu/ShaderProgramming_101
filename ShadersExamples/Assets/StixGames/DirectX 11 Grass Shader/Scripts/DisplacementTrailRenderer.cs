using System;
using UnityEngine;
using System.Collections.Generic;

[AddComponentMenu("StixGames/Displacement Trail Renderer")]
public class DisplacementTrailRenderer : MonoBehaviour
{
    public float minVertexDistance = 0.5f;
    public float lifetime = 5;

    public AnimationCurve width = AnimationCurve.Linear(0, 1, 1, 0);
    public AnimationCurve strength = AnimationCurve.EaseInOut(0, 1, 1, 0);

    public Material material;

    [HideInInspector]
    public int layer;

    private Vector3 upDir = Vector3.up;

    private List<TrailPoint> points = new List<TrailPoint>();
    private Mesh mesh;

    private List<Vector3> vertices = new List<Vector3>();
    private List<int> triangles = new List<int>();
    private List<Vector2> uvs = new List<Vector2>();
    private List<Vector3> normals = new List<Vector3>();
    private List<Vector4> tangents = new List<Vector4>();
    private List<Color> colors = new List<Color>();

    void Start()
    {
        mesh = new Mesh();
    }

	void Update ()
    {
        //Remove points that are older than lifetime
        while (points.Count > 0)
        {
            if ((Time.time - points[0].creationTime) > lifetime)
            {
                points.RemoveAt(0);
            }
            else
            {
                break;
            }
        }

        Vector3 pos = transform.position;
	    bool addedPoint = false;

        //Add new point if list is empty or distance to last point is bigger than minVertexDistance
        if (points.Count == 0 || Vector3.Distance(points[points.Count - 1].pos, pos) > minVertexDistance)
        {
            points.Add(new TrailPoint(pos, Time.time));
            addedPoint = true;
        }

        List<TrailPoint> renderPoints = new List<TrailPoint>(points);

        //If no point was added this frame, use the current position as point
	    if (!addedPoint)
	    {
	        renderPoints.Add(new TrailPoint(pos, Time.time));
	    }

        //If there are less than 2 points, don't render the trail.
        if (renderPoints.Count < 2)
        {
            return;
        }

        UpdateMesh(renderPoints);

        Graphics.DrawMesh(mesh, Matrix4x4.identity, material, layer);
    }

    private void UpdateMesh(List<TrailPoint> renderPoints)
    {
        mesh.Clear();
        if (renderPoints.Count < 2)
        {
            return;
        }
        
        //Clear lists
        vertices.Clear();
        triangles.Clear();
        uvs.Clear();
        normals.Clear();
        tangents.Clear();
        colors.Clear();

        float uvFactor = 1.0f/(renderPoints.Count-1);

        //Iterate though all previous points
        for (int i = 0; i < renderPoints.Count; i++)
        {
            //First point
            TrailPoint point = renderPoints[i];
            if (i == 0)
            {
                AddPoint(point, renderPoints[i+1].pos - point.pos, 0);
                continue;
            }

            //Last point
            TrailPoint lastPoint = renderPoints[i - 1];
            if (i == renderPoints.Count - 1)
            {
                AddPoint(point, point.pos - lastPoint.pos, 1);
                break;
            }

            //In-between points
            TrailPoint nextPoint = renderPoints[i + 1];

            AddPoint(point, nextPoint.pos - lastPoint.pos, i * uvFactor);
        }

        mesh.vertices = vertices.ToArray();
        mesh.triangles = triangles.ToArray();
        mesh.uv = uvs.ToArray();
        mesh.normals = normals.ToArray();
        mesh.tangents = tangents.ToArray();
        mesh.colors = colors.ToArray();

        //Those only work in Unity 5.2 and above... shouldn't be much faster anyways.
        //mesh.SetVertices(vertices);
        //mesh.SetTriangles(triangles, 0);
        //mesh.SetUVs(0, uvs);
        //mesh.SetNormals(normals);
        //mesh.SetTangents(tangents);
        //mesh.SetColors(colors);
    }

    private void AddPoint(TrailPoint point, Vector3 direction, float uv)
    {
        float lifePercent = (Time.time - point.creationTime) / lifetime;
        float halfWidth = width.Evaluate(lifePercent);
        float normalStrength = strength.Evaluate(lifePercent);
        Color normalStrengthColor = new Color(normalStrength, normalStrength, normalStrength, normalStrength);

        direction.Normalize();
        Vector3 pos = point.pos;
        Vector3 right = Vector3.Cross(upDir, direction);

        vertices.Add(pos - right * halfWidth);
        vertices.Add(pos + right * halfWidth);
        uvs.Add(new Vector2(0, uv));
        uvs.Add(new Vector2(1, uv));
        normals.Add(upDir);
        normals.Add(upDir);
        tangents.Add(new Vector4(direction.x, direction.y, direction.z, 1));
        tangents.Add(new Vector4(direction.x, direction.y, direction.z, 1));
        colors.Add(normalStrengthColor);
        colors.Add(normalStrengthColor);

        int lastVert = vertices.Count-1;
        if (lastVert >= 3)
        {
            triangles.Add(lastVert - 1);
            triangles.Add(lastVert);
            triangles.Add(lastVert - 2);

            triangles.Add(lastVert - 2);
            triangles.Add(lastVert - 3);
            triangles.Add(lastVert - 1);
        }
    }
}

[Serializable]
public struct TrailPoint
{
    public Vector3 pos;
    public float creationTime;

    public TrailPoint(Vector3 pos, float creationTime)
    {
        this.pos = pos;
        this.creationTime = creationTime;
    }
}