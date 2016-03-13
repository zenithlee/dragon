using UnityEngine;
using System.Collections;

public class CCamera : MonoBehaviour {


	Vector3 DestinationPos = Vector3.zero;
	public Transform LookAtNode;

	public Transform TargetPos1;
	public Transform TargetLookAt1;
	Quaternion TargetRotation = Quaternion.identity;

	public float Distance = 30;
	float yMinLimit = -20;
	float yMaxLimit = 80;
	float xSpeed = 250.0f;
	float ySpeed = 120.0f;
	float x = 0;
	float y = 0;
	public float SpeedCoefficient = 8;
	public UnityEngine.UI.Slider SpeedSlider;

	bool Animated = true;
	public UnityEngine.UI.Toggle AnimatedToggle;

	// Use this for initialization
	void Start () {
		DestinationPos = TargetPos1.position;
		TargetRotation = transform.rotation;
	}

	public void SetAnimated( ){
		Animated = AnimatedToggle.isOn;
	}

	public void SetSpeed( ){
		SpeedCoefficient = SpeedSlider.value;
	}

	public void MoveTo( Vector3 v )
	{
		DestinationPos = v;
	}

	public void Reset( ){
		DestinationPos = TargetPos1.localPosition;
	}

	public void LookAt( Vector3 v )
	{
		LookAtNode.localPosition = v;
		DestinationPos = TargetRotation * new Vector3(0.0f, 0.0f, -Distance) + LookAtNode.localPosition;
	}

	public void MoveToTopView( )
	{
		MoveTo ( new Vector3( 0, 100, 0 ));
		TargetRotation = Quaternion.Euler(90, 0, 0);
		//LookAt ( Vector3.zero );
	}

	void LateUpdate()
	{
		float f = Input.GetAxis("Mouse ScrollWheel");
		if ( f != 0 )
		{
			Distance -=  Input.GetAxis("Mouse ScrollWheel") * 10; 
			DestinationPos = TargetRotation * new Vector3(0.0f, 0.0f, -Distance) + LookAtNode.localPosition;
		}
		
		if ( Input.GetMouseButton( 1 ) )
		{
			if ( Input.GetKeyDown( KeyCode.LeftControl) ){
				Debug.Log ( "Shift" );
				DestinationPos += new Vector3( Input.GetAxis("Mouse X") * xSpeed * 0.02f, Input.GetAxis("Mouse Y") * ySpeed * 0.02f, 0 );
			}
			else
			{
				x += Input.GetAxis("Mouse X") * xSpeed * 0.02f;
				y -= Input.GetAxis("Mouse Y") * ySpeed * 0.02f;
				
				y = ClampAngle(y, yMinLimit, yMaxLimit);
				
				Quaternion rotation = Quaternion.Euler(y, x, 0);
				Vector3 position = rotation * new Vector3(0.0f, 0.0f, -Distance) + LookAtNode.localPosition;
				
				TargetRotation = rotation;
				DestinationPos = position;
			}
		}
	}

	static float ClampAngle (float angle, float min, float max) {
		if (angle < -360)
			angle += 360;
		if (angle > 360)
			angle -= 360;
		return Mathf.Clamp (angle, min, max);
	}
	
	// Update is called once per frame
	void Update () {
		if ( Animated ) {
			transform.localPosition = Vector3.Lerp( transform.localPosition, DestinationPos, Time.deltaTime * SpeedCoefficient );	
			transform.rotation = Quaternion.Lerp( transform.rotation, TargetRotation, Time.deltaTime * SpeedCoefficient );
		}
		else{
			transform.localPosition = DestinationPos;
			transform.rotation = TargetRotation;

		}
		//TargetLookAtCurrent = Vector3.Lerp ( TargetLookAtCurrent, TargetLookAt, Time.deltaTime * 5 );
		//transform.LookAt( TargetLookAtCurrent );
	}
}
