# FPGA-Based Motion Visualization and Real-Time Fall Detection System
Final project - FPGA-Based Motion Visualization and Real-Time Fall Detection System 
## Project Overview
This project focuses on developing a real-time fall detection system using the DE-10 Lite FPGA board with an Altera MAX-10 FPGA and the ADXL345 accelerometer. The system communicates with the ADXL345 via the SPI protocol, processes the data to detect movement and falls, and displays the data graphically on a VGA monitor. Additionally, the data is transmitted to a computer using UART for further visualization.

The project can be extended for elderly monitoring, where the system can detect a fall and provide an alert in real-time.

## Features
- Real-time communication with ADXL345 accelerometer via SPI
- Detection of free-fall events using the ADXL345 functionality
- Real-time graphical display of movement using VGA
- 3D visualization of board orientation using a Python program
- Data transmission to the PC via UART
- Smooth interpolation and movement tracking using quaternion calculations

## Hardware Requirements
- DE-10 Lite FPGA board
- ADXL345 accelerometer
- VGA-compatible display
- RS232 converter (for UART communication)

## Software Requirements
- Quartus Prime (for FPGA synthesis and programming)
- ModelSim (for simulation)
- Python (for visualizing data on the computer)
  - Required libraries: `vispy`, `numpy`, `pyserial`

## System Architecture
The system is divided into multiple modules:
1. **SPI Module**: Handles communication with the ADXL345 sensor.
2. **Free-Fall Detection**: Uses the ADXL345’s interrupt to detect falls.
3. **UART Module**: Transmits data to the computer.
4. **VGA Module**: Displays real-time acceleration data graphically on the screen.
5. **7-Segment Display**: Displays raw accelerometer data for validation.
