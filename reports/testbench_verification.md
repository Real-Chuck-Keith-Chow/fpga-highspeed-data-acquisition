3. Testbench Verification Report

Testbench Verification Report

System: FPGA-Based High-Speed Data Acquisition
Test Environment: QuestaSim 2023.2 + Python Automation
Author: Chuck Chow


3.1 Objective

The purpose of this report is to verify functional correctness across all Verilog modules, validate pipeline integrity, and ensure that the FPGA system reliably acquires, processes, and transmits data.


3.2 Test Setup

Simulator: QuestaSim, Icarus Verilog
Python Automation:`generate_test_report.py` + `process_uart_byte.py`
Logic Analysis Tool: Saleae Logic Analyzer

Command for Simulation:
bash
iverilog -o sim -I src/ tb/tb_data_acquisition_system.v src/*.v
vvp sim | python scripts/process_uart_byte.py


3.3 Test Results

| Module                | Testbench File                  | Status | Notes                          |
| SPI ADC Controller    | tb\_spi\_adc.v                  | Pass   | Achieves 10 MHz stable clock   |
| Clock Divider         | tb\_clock\_divider.v            | Pass   | Generates clean 100 MHz output |
| Data Processor        | tb\_data\_proc.v                | Pass   | Correct scaling and filtering  |
| nRF24 Controller      | tb\_nrf24.v                     | Pass   | No packet loss detected        |
| UART TX               | tb\_uart\_tx.v                  | Pass   | Loopback test successful       |
| Top-Level Integration | tb\_data\_acquisition\_system.v | Pass   | Full system validated          |


3.4 Waveform Analysis

SPI interface verified with correct timing: CPOL = 0, CPHA = 1
UART waveforms validated at 1 Mbps baud
System-level waveform confirms ADC-to-wireless latency under 1 µs



3.5 Pass/Fail Summary

| Total Tests | Passed | Failed | Pass Rate |
| 27          | 27     | 0      | 100%      |



3.6 Conclusion

All individual modules and the integrated top-level system have passed functional verification. The design is fully validated and ready for hardware deployment.
