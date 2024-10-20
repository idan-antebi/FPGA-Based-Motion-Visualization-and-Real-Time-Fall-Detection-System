from vispy import scene, app
from vispy.scene import visuals
import numpy as np
import serial
import threading
import math

# Set up the serial port
ser = serial.Serial('COM5', 38400, timeout=0.005)

marker = b'\xCB\xCA\xFE\xAB\xE5'

def twos_complement_to_signed(value, bits):
    """Convert a two's complement value to a signed integer."""
    if value & (1 << (bits - 1)):  # Check if the MSB is set (negative number)
        value -= (1 << bits)  # Subtract to get the correct negative value
    return value

def calculate_orientation(x, y, z):
    """Calculate roll and pitch from acceleration data using Arduino-style calculations."""
    roll = -math.atan2(y, math.sqrt(x**2 + z**2)) * 180 / math.pi  # Inverted sign
    pitch = -math.atan2(-x, math.sqrt(y**2 + z**2)) * 180 / math.pi  # Inverted sign
    yaw = 0  # Yaw can't be determined by accelerometer alone
    return roll, pitch, yaw

def quaternion_from_euler(roll, pitch, yaw):
    """Convert Euler angles to Quaternion."""
    cr = math.cos(math.radians(roll) * 0.5)
    sr = math.sin(math.radians(roll) * 0.5)
    cp = math.cos(math.radians(pitch) * 0.5)
    sp = math.sin(math.radians(pitch) * 0.5)
    cy = math.cos(math.radians(yaw) * 0.5)
    sy = math.sin(math.radians(yaw) * 0.5)

    qw = cr * cp * cy + sr * sp * sy
    qx = sr * cp * cy - cr * sp * sy
    qy = cr * sp * cy + sr * cp * sy
    qz = cr * cp * sy - sr * sp * cy

    return np.array([qw, qx, qy, qz])

def quaternion_slerp(q1, q2, t):
    """Perform Spherical Linear Interpolation (SLERP) between two quaternions."""
    dot = np.dot(q1, q2)

    # Ensure the shortest path for interpolation
    if dot < 0.0:
        q2 = -q2
        dot = -dot

    # If the quaternions are nearly identical, use linear interpolation
    if dot > 0.9995:
        result = q1 + t * (q2 - q1)
        return result / np.linalg.norm(result)

    theta_0 = math.acos(dot)  # angle between q1 and q2
    sin_theta_0 = math.sin(theta_0)

    theta = theta_0 * t  # Interpolated angle
    sin_theta = math.sin(theta)

    s0 = math.cos(theta) - dot * sin_theta / sin_theta_0
    s1 = sin_theta / sin_theta_0

    return (s0 * q1) + (s1 * q2)

def quaternion_to_matrix(q):
    """Convert a quaternion into a rotation matrix."""
    w, x, y, z = q
    return np.array([
        [1 - 2 * (y**2 + z**2), 2 * (x * y - z * w), 2 * (x * z + y * w), 0],
        [2 * (x * y + z * w), 1 - 2 * (x**2 + z**2), 2 * (y * z - x * w), 0],
        [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x**2 + y**2), 0],
        [0, 0, 0, 1]
    ])

# Create a canvas with 3D display
canvas = scene.SceneCanvas(keys='interactive', size=(800, 600), show=True)
view = canvas.central_widget.add_view()
view.camera = scene.cameras.TurntableCamera(fov=45)

# Create a 3D box using visuals.Box with larger dimensions
box = visuals.Box(width=5, height=0.5, depth=2.5, color=(0, 0, 1, 1), edge_color='white')  # Increased dimensions
view.add(box)

# Lock the camera to prevent moving
view.camera.elevation = 0
view.camera.azimuth = 0
view.camera.distance = 8
view.camera.center = (0, 0, 0)

# Global variables to store sensor data
current_rotation = np.array([1, 0, 0, 0])  # Initial rotation (Quaternion)
target_rotation = current_rotation.copy()  # Target rotation for interpolation

def read_sensor_data():
    global target_rotation
    while True:
        if ser.in_waiting >= 5:  # Wait for the marker to be available
            marker_data = ser.read(5)
            if marker_data == marker:
                while ser.in_waiting < 6:
                    pass  # Busy wait (no sleep) to keep checking for data

                data = ser.read(6)  # Read 6 bytes for axis data

                # Convert raw values to signed integers using two's complement
                x = twos_complement_to_signed(int.from_bytes(data[0:2], byteorder='big', signed=False), 16) / 256.0
                y = twos_complement_to_signed(int.from_bytes(data[2:4], byteorder='big', signed=False), 16) / 256.0
                z = twos_complement_to_signed(int.from_bytes(data[4:6], byteorder='big', signed=False), 16) / 256.0

                # Calculate roll, pitch, yaw from accelerometer data
                roll, pitch, yaw = calculate_orientation(x, y, z)

                # Convert Euler angles to Quaternion
                new_quaternion = quaternion_from_euler(roll, pitch, yaw)

                # Correct for shortest path rotation
                if np.dot(current_rotation, new_quaternion) < 0:
                    new_quaternion = -new_quaternion  # Invert to take shortest path

                # Update the target rotation quaternion
                target_rotation = new_quaternion

# Start the sensor reading thread
sensor_thread = threading.Thread(target=read_sensor_data)
sensor_thread.daemon = True
sensor_thread.start()

def update(event):
    global current_rotation, target_rotation
    # Apply SLERP to smoothly transition to the target rotation
    current_rotation = quaternion_slerp(current_rotation, target_rotation, 0.1)
    
    # Apply the quaternion rotation to the box
    box.transform = scene.transforms.MatrixTransform()
    matrix = quaternion_to_matrix(current_rotation)
    box.transform.matrix = matrix

# Use Timer from vispy.app to schedule updates
timer = app.Timer(interval=0.016, connect=update, start=True)

if __name__ == '__main__':
    canvas.app.run()
