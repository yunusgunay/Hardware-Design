# UART Hardware Communication Protocol

## Overview

This project is an implementation of the **Universal Asynchronous Receiver-Transmitter (UART)** module using **SystemVerilog**. The project demonstrates the principles of asynchronous serial communication between two Basys3 FPGA boards. The project involves the design and implementation of UART, capable of both transmitting and receiving data simultaneously (full duplex mode).

## Features

- **8 data bits per transmission (1 byte)**
- **1 parity bit**
- **1 stop bit**
- Configurable baud rate
- **Transmit and Receive Buffers (TXBUF and RXBUF)** for storing incoming and outgoing data
- **FIFO structure** for handling multiple bytes of data
- **7-segment display** integration for visualizing data in memory
- Support for **automatic data transfer** that transmits 4 bytes at once

## Project Stages

### Stage 1: UART Device
- Implement the UART transmitter and receiver modules.
- Load the data to transmit from switches on the Basys3 board.
- Display the transmitted and received data using LEDs.
  
### Stage 2: FIFO Buffer Integration
- Implement 4-byte memory buffers for both transmit (TXBUF) and receive (RXBUF) operations.
- Use a FIFO structure for data storage.

### Stage 3: 7-Segment Display Integration
- Display the contents of the TXBUF and RXBUF on the 7-segment display of the Basys3 board.
- Navigate the display using buttons to scroll through memory pages.

### Stage 4: Automatic Transfer
- Implement automatic transmission of all 4 bytes in the TXBUF using a switch.
