using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    [SerializeField]
    private float moveSpeed = 500f;
    [SerializeField]
    private float rotationSpeed = 50f;

    void FixedUpdate()
    {
        Vector3 translation = new Vector3(Input.GetAxis("Horizontal"), Input.GetAxis("UpDown"), Input.GetAxis("Vertical"));
        translation.Normalize();
        translation *= moveSpeed * Time.fixedDeltaTime;
        transform.Translate(translation);

        float yaw = Input.GetAxis("Yaw") * rotationSpeed * Time.fixedDeltaTime;
        float roll = Input.GetAxis("Roll") * rotationSpeed * Time.fixedDeltaTime;
        float pitch = Input.GetAxis("Pitch") * rotationSpeed * Time.fixedDeltaTime;

        transform.Rotate(-pitch, yaw, -roll);
    }
}
