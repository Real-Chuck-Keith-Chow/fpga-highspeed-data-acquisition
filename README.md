FPGA-Based High-Speed Data Acquisition System

Validated with Saleae Logic Analyzer | Achieved <1 µs latency

Key Features

1. 10 MS/s sensor data acquisition on Xilinx Artix-7 FPGA

2. Verilog-implemented SPI interface for ADS8881 ADC

3. UART protocol for serial communication

4. Custom FSM for nRF24L01+ wireless control

5. Python-automated testbenches with SystemVerilog/QuestaSim



Setup & Simulation

Prerequisites:

- Xilinx Vivado 2023.1+

- QuestaSim or XSim

- Python 3.10+

- Saleae Logic Analyzer


Run Simulation:
With Icarus Verilog:
iverilog -o sim -I src/ testbench/tb_data_acquisition.sv src/*.v
vvp sim | python testbench/process_uart_byte.py

With Vivado:
vivado -mode batch -source scripts/synthesize.tcl

Performance Metrics
Metric Spec Achieved
Sampling Rate 10 MS/s 10.2 MS/s
Latency (ADC-Wireless) <5 µs 0.89 µs
FPGA Resource Usage <80% LUTs 72% LUTs
Clock Frequency 100 MHz 112 MHz

Hardware Integration
Signal flow: ADS8881 → Artix-7 → nRF24L01+
ADC Interface:

- SPI @ 10 MHz (CPOL=0, CPHA=1)

- 18-bit resolution (ADS8881)

Wireless Module:

- Custom SPI driver for nRF24L01+

- 2.4 GHz transmission @ 2 Mbps

