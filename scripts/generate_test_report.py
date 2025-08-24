#!/usr/bin/env python3
"""
Test Report Generator for FPGA Data Acquisition System
- Processes simulation/hardware test data
- Generates PDF/HTML reports with metrics
- Validates against project requirements
"""

import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime
import sys
import os
from fpdf import FPDF

# Configuration
REQUIREMENTS = {
    'max_latency': 1.0,    # µs
    'min_sample_rate': 10,  # MS/s
    'error_threshold': 0.01 # % allowed
}

class TestAnalyzer:
    def __init__(self):
        self.results = {
            'timestamp': [],
            'test_case': [],
            'latency': [],
            'throughput': [],
            'error_count': []
        }
        
    def parse_logs(self, log_path="uart_log.csv"):
        """Process UART/Saleae output logs"""
        try:
            df = pd.read_csv(log_path)
            
            # Calculate metrics
            self.results['timestamp'].append(datetime.now())
            self.results['test_case'].append("FULL_PIPELINE")
            self.results['latency'].append(
                df[df['Type'] == 'DATA']['Timestamp'].diff().mean() * 1e3
            )
            self.results['throughput'].append(
                1 / df[df['Type'] == 'DATA']['Timestamp'].diff().mean()
            )
            self.results['error_count'].append(
                len(df[df['Type'] == 'ERROR'])
            )
            
        except FileNotFoundError:
            print(f"Error: Log file {log_path} not found", file=sys.stderr)
            sys.exit(1)

    def generate_report(self, format="pdf"):
        """Create validation report"""
        df = pd.DataFrame(self.results)
        
        # Generate plots
        plt.figure(figsize=(10, 6))
        df.plot(x='timestamp', y=['latency', 'throughput'], secondary_y=['throughput'])
        plt.savefig("test_metrics.png")
        
        # Create PDF report
        pdf = FPDF()
        pdf.add_page()
        pdf.set_font("Arial", size=12)
        
        # Header
        pdf.cell(200, 10, txt="FPGA Data Acquisition System Test Report", ln=1, align='C')
        pdf.cell(200, 10, txt=f"Generated: {datetime.now()}", ln=1, align='C')
        
        # Results table
        pdf.cell(200, 10, txt="Key Metrics:", ln=1)
        pdf.cell(100, 10, txt="Parameter", border=1)
        pdf.cell(50, 10, txt="Measured", border=1)
        pdf.cell(50, 10, txt="Status", border=1, ln=1)
        
        metrics = [
            ("Latency (µs)", df['latency'].iloc[-1], REQUIREMENTS['max_latency']),
            ("Throughput (MS/s)", df['throughput'].iloc[-1]/1e6, REQUIREMENTS['min_sample_rate']),
            ("Error Rate (%)", df['error_count'].iloc[-1]/len(df)*100, REQUIREMENTS['error_threshold'])
        ]
        
        for name, value, req in metrics:
            status = "PASS" if (value <= req if name != "Throughput" else value >= req) else "FAIL"
            pdf.cell(100, 10, txt=name, border=1)
            pdf.cell(50, 10, txt=f"{value:.2f}", border=1)
            pdf.cell(50, 10, txt=status, border=1, ln=1)
        
        # Add plot
        pdf.image("test_metrics.png", x=10, y=100, w=180)
        
        # Save report
        report_file = f"TestReport_{datetime.now().strftime('%Y%m%d_%H%M')}.pdf"
        pdf.output(report_file)
        print(f"Report generated: {report_file}")

if __name__ == "__main__":
    analyzer = TestAnalyzer()
    analyzer.parse_logs()
    analyzer.generate_report()
