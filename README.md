# Sifting Module

The **Sifting Module** in the Quantum Key Distribution (QKD) system utilizes the **Coherent One-Way (COW) Protocol** to encode qubits. Each qubit is represented by two pulse bits. This module performs two essential tasks:

1. **Key Extraction**: Filters out positions where neither photons nor decoy signals are detected, generating the **sifted key**.
2. **Parameter Recording**: Records visibility parameters for use in subsequent processing.

---

## Features

- **Key Extraction**: 
  - Eliminates invalid positions to produce sifted keys.
  - Writes sifted keys to URAM in 64-bit blocks.

- **Parameter Recording**:
  - Simultaneously calculates visibility parameters during the sifting process.
  - Transfers visibility parameters to FIFO after accumulating 8,192 bits.

- **Network Layer Integration**:
  - Facilitates communication between Alice and Bob to exchange detected positions and decoy information.
  - Ensures robust and reliable data transmission.

- **Storage Optimization**:
  - Utilizes URAM for efficient key storage.
  - Stores temporary visibility parameters in FIFOs.

---

## Workflow

1. **Data Transmission**: 
   - Bob transmits detected positions for X-basis and Z-basis measurements to Alice via the network layer.

2. **Data Processing**:
   - Alice processes received data to perform sifting and calculates visibility parameters.
   - Alice sends decoy position information back to Bob to finalize the sifted key.

3. **Key Storage**:
   - Both Alice and Bob store processed sifted keys in URAM for subsequent distillation stages.

---

## Technical Details

### Protocol: Coherent One-Way (COW)
- **Qubit Encoding**:
  - Each qubit is encoded using two pulse bits.
  - Encoding table:

| Qubit Type       | Pulse Bit |
|-------------------|-----------|
| Qubit Decoy       | `11`      |
| Qubit Not Detected| `00`      |
| Qubit 0           | `10`      |
| Qubit 1           | `01`      |

### Key Storage and Transmission
- **Alice**:
  - Continuously reads data from Qubit BRAM and RX FIFOs.
  - Simultaneously sifts data and calculates visibility parameters.
  - Stores sifted keys in URAM.

- **Bob**:
  - Transmits detected positions for both bases to Alice.
  - Waits for decoy signal validation before writing sifted keys to URAM.

---

## Importance

The Sifting Module is critical for ensuring:
- **Accurate Key Extraction**: Filters unnecessary data to generate high-quality sifted keys.
- **Reliable Parameter Recording**: Collects visibility parameters essential for error reconciliation.
- **System Integrity**: Ensures robust and reliable communication between Alice and Bob.

This module lays the foundation for subsequent processes, such as **Error Reconciliation** and **Privacy Amplification**, by ensuring the sifted keys and parameters are ready for secure key distillation.

# Error Reconciliation Module

The **Error Reconciliation Module** ensures consistency between Alice's and Bob's keys in a Quantum Key Distribution (QKD) system by addressing discrepancies caused by measurement errors, environmental interference, or potential eavesdropping. It integrates two critical components: **Error Correction (EC)** and **Error Verification (EV)**.

---

## Features

### Error Correction (EC)
- Implements the **Cascade Protocol** for parity-based error correction.
- Processes data frame by frame (8192 bits per frame) with a total of 128 frames (1048576 bits).
- Utilizes key modules like:
  - Shuffle
  - Parity Tree
  - Parity Comparison
  - Control and Key Loader
  - TXRX I/O for communication
- Records information leakage and error bit counts for security and reconciliation efficiency.

### Error Verification (EV)
- Employs **Toeplitz Hashing** for error verification.
- Compares hash tags between Alice and Bob to ensure the correctness of reconciled keys.
- Discards frames with mismatched hash tags to prevent compromised keys.

---

## Workflow

### Error Correction Process
1. **Alice**:
   - Responds to Bob's parity requests for the sifted key.
   - Restores the key to its original form after reshuffling.
   - Concludes the process once the top-level parity is verified.

2. **Bob**:
   - Iteratively identifies and corrects errors by comparing parities.
   - Adjusts the row index systematically until errors are resolved.
   - Determines the initial row index for the next frame based on the error bit count.

3. **Reconciliation Efficiency**:
   - Evaluates efficiency using the formula:
     \[
     RE = \frac{\text{leakedinfo}}{(- \text{qber} \times \log_2 (\text{qber}) - (1 - \text{qber}) \times \log_2 (1-\text{qber})) \times \text{qber}}
     \]
   - Optimal initial row indices for different Quantum Bit Error Rates (QBER) are outlined in the specification.

### Error Verification Process
1. **Hash Tag Calculation**:
   - Alice and Bob generate hash tags using Toeplitz hashing.
   - Bob uses the random bits provided by Alice for consistent hashing.

2. **Verification**:
   - Compares transmitted and received hash tags.
   - Matches confirm correctness, while mismatches result in discarded frames.

---

## Technical Specifications

### Error Correction
| Parameter             | Value                  |
|-----------------------|------------------------|
| Input Frame Size      | 8192 bits             |
| Protocol              | Cascade Protocol      |
| Initial Row Index     | Variable (QBER-dependent) |

### Error Verification
| Parameter             | Value                  |
|-----------------------|------------------------|
| Input Frame Size ($n$)| 8192 bits             |
| Output Hash Size ($m$)| 32 bits               |
| Toeplitz Hashing      | Matrix Multiplication |
| MAC Units ($k$)       | 32                    |
| Word Width ($w$)      | 32 bits               |

---

## Block Diagrams

### Error Correction
- **Alice's EC Module**:
![398139596-11b457f0-787e-4efb-bd61-78c7f96bf7bf](https://github.com/user-attachments/assets/3d2341ab-3031-49d0-80a5-5a679e508394)
  
- **Bob's EC Module**:
![398139682-d65c98a3-7b1e-4cc2-a405-6514d88b2276](https://github.com/user-attachments/assets/582b127f-6cb7-476f-99fb-d94102165286)

### Error Verification
- **Alice's EV Module**:
![398139750-11f94155-fe81-44ee-a20a-178cadc1fd4d](https://github.com/user-attachments/assets/ab3e471b-3753-4e3a-ba86-39125c724899)

- **Bob's EV Module**:
![398139773-ade4fd5e-4422-4551-bc06-008b88de601f](https://github.com/user-attachments/assets/5023a3e2-03fb-476f-b5df-e8ce0055b871)

---

## Importance

The Error Reconciliation Module plays a vital role in:
- **Maintaining Key Consistency**: Ensures secure reconciliation of keys between Alice and Bob.
- **Reducing Information Leakage**: Monitors and minimizes leaked information during error correction.
- **Validating Key Integrity**: Verifies reconciled keys through robust hash-based error verification.

This module provides a secure foundation for subsequent processes, including **Privacy Amplification**, ensuring the QKD system's reliability and security.

# Privacy Amplification Module

The **Privacy Amplification Module** ensures the transformation of reconciled keys into secure secret keys in a Quantum Key Distribution (QKD) system. This process mitigates information leakage by leveraging **Toeplitz matrix multiplication** and **exclusive OR (XOR)** operations, making it well-suited for FPGA-based implementations.

---

## Features

### Key Transformation
- Multiplies the reconciled key ($n$ bits) with a random Toeplitz matrix ($m \times (n-m)$) to produce a secure secret key.
- Combines the resulting product with the remaining $m$ bits of the reconciled key using XOR.
- Supports fixed input key size of $n = 1048576$ bits and a variable output secret key size of approximately $m \approx 10^5$ bits.

### Efficient Processing
- Utilizes FPGA for efficient matrix multiplication and XOR operations.
- Segments the secret key vector into parts of $k$ bits to handle large matrix operations efficiently.
- Designed to achieve secure and high-performance key generation.

---

## Workflow

### Privacy Amplification Process
1. **Toeplitz Matrix Multiplication**:
   - Multiplies the $n-m$ bits of the reconciled key with the Toeplitz matrix.
   - Divides the computation into manageable segments for efficiency.

2. **XOR Operation**:
   - Combines the matrix product with the remaining $m$ bits of the reconciled key to produce the final secret key.

3. **Parameter Transmission**:
   - Alice computes and transmits the secret key length to Bob.
   - Bob uses this information to ensure consistency in the distillation process.

---

## Technical Specifications

| Parameter                   | Value                          | Remarks                          |
|-----------------------------|--------------------------------|----------------------------------|
| Input Key Size ($n$)        | 1048576 $\approx 10^6$ bits    | Fixed                           |
| Output Secret Key Size ($m$)| $\approx 10^5$ bits            | Variable                        |
| Hashing Technique           | Toeplitz Matrix + XOR          |                                  |
| MAC Units ($k$)             | 1024                           |                                  |
| Word Width ($w$)            | 64                             |                                  |

---

## Block Diagrams

### Module Architecture
![圖片](https://github.com/user-attachments/assets/a8f36604-1a0d-4450-9dfd-abd8cb7f1746)

### Flowchart
![圖片](https://github.com/user-attachments/assets/88b114d0-efae-4189-ad57-78b428cd33a1)

### Alice's Module
- **Block Diagram**:
![圖片](https://github.com/user-attachments/assets/84b7ba56-86b0-44d2-ba4f-5f2236679f7e)
- **Detailed I/O**:
![圖片](https://github.com/user-attachments/assets/5e9aa11e-24ff-4e1b-8e85-cc4b3f6c85f8)

### Bob's Module
- **Block Diagram**:
![圖片](https://github.com/user-attachments/assets/739835a5-be66-4576-a8cb-ef93d8c9b06f)
- **Detailed I/O**:
![圖片](https://github.com/user-attachments/assets/c28e32a7-995d-4ae0-9ea6-aab3fe84ccff)

---

## Importance

The Privacy Amplification Module plays a critical role in:
- **Mitigating Information Leakage**: Ensures secure key generation by transforming reconciled keys.
- **Efficient FPGA Utilization**: Leverages FPGA's capabilities for high-speed matrix operations.
- **Scalability**: Handles large key sizes effectively through segmentation and efficient computation.

This module is integral to maintaining the security and integrity of the QKD system, serving as the final step in secret key distillation.

# Packet and Unpacket Modules

The **Packet and Unpacket Modules** are integral components of the Quantum Key Distribution (QKD) system, enabling efficient data handling between various distillation processes and the network layer. These modules ensure seamless data encapsulation and extraction, facilitating robust communication between Alice and Bob.

---

## Features

### Packet Module
- **Data Encapsulation**:
  - Reads data from the sifting, error reconciliation, and (for Alice) privacy amplification modules.
  - Writes encapsulated packets into the TX BRAM for transmission.
- **Handshaking Protocol**:
  - Utilizes a multi-step handshake process to ensure efficient data transfer and avoid overwrites.
- **Clock Domains**:
  - Operates with post-processing at 100 MHz and $clkTX\_msg$ at 93.75 MHz.

### Unpacket Module
- **Data Extraction**:
  - Reads data from the RX BRAM and routes it to appropriate RX BRAMs or RX FIFOs based on the header information.
  - Handles 64-bit wide data by combining information from two RX BRAM addresses.
- **Handshaking Mechanism**:
  - Ensures no overwriting occurs before data is completely read.

---

## Workflows

### Packet Module Workflow
1. Data is encapsulated into packets based on input from various processing modules.
2. Encapsulated packets are written to TX BRAM.
3. A handshake ensures that the network module can read the data efficiently.
4. The next packet is written after the network module completes reading.

### Unpacket Module Workflow
1. Data is read from the RX BRAM.
2. Headers are analyzed to direct data to the appropriate RX BRAMs or RX FIFOs.
3. A handshake ensures that data in RX BRAM is not overwritten until completely read.
4. Combines 64-bit data from multiple RX BRAM addresses.

---

## Technical Specifications

### Packet Module Handshaking
| **Step** | **Action** |
|----------|------------|
| 1        | `busy_PP2Net_TX = 1` |
| 2        | Packet module storing... |
| 3        | Packet module completes storing, `busy_PP2Net_TX = 0` |
| 4        | `msg_stored = 1` |
| 5        | Wait for `busy_Net2PP_TX = 1` |
| 6        | `msg_stored = 0` |
| 7        | Network module completes reading, `busy_Net2PP_TX = 0` |

### Unpacket Module Handshaking
| **Step** | **Action** |
|----------|------------|
| 1        | `busy_Net2PP_RX = 1` |
| 2        | Network module storing... |
| 3        | Network module completes storing, `busy_Net2PP_RX = 0` |
| 4        | Wait for `msg_accessed = 1` |
| 5        | `busy_PP2Net_RX = 1` |
| 6        | `msg_accessed = 0` |
| 7        | Unpacket module completes reading, `busy_PP2Net_RX = 0` |

---

## Block Diagrams

### Packet Module
- **Alice's Side**:
![圖片](https://github.com/user-attachments/assets/adbe78ee-3344-4a47-9a77-cc3b778ae529)
- **Bob's Side**:
![圖片](https://github.com/user-attachments/assets/cf041e5f-f4d0-45b3-b5ad-7914cdfb452c)

### Unpacket Module
- **Alice's Side**:
![圖片](https://github.com/user-attachments/assets/e6b76c81-b037-4afb-b414-2feeff230ffd)
- **Bob's Side**:
![圖片](https://github.com/user-attachments/assets/89e2e8f0-13f0-40cd-b62b-787ad8ca9018)

---

## Input/Output Details

### Packet Module
- **Alice's Side**:
![圖片](https://github.com/user-attachments/assets/b1b5b5fa-ff7a-46d5-8cd1-4f63f1334378)
- **Bob's Side**:
![圖片](https://github.com/user-attachments/assets/b4951d07-8f41-43af-9350-b53769cd6de7)

### Unpacket Module
- **Alice's Side**:
![圖片](https://github.com/user-attachments/assets/18f97790-0087-4d19-9782-443adebdc6b7)
- **Bob's Side**:
![圖片](https://github.com/user-attachments/assets/cfb5ae65-9762-4a60-adb3-efcbbee5efe9)

---

## Importance

The Packet and Unpacket Modules:
- Facilitate robust communication between QKD distillation processes and the network layer.
- Ensure data integrity through precise encapsulation, extraction, and handshaking mechanisms.
- Optimize performance across different clock domains, enabling efficient operation in the QKD system.

# Classical Channel

The **Classical Channel** module is a key component of the Quantum Key Distribution (QKD) system, enabling robust message exchange between post-processing modules and the network central controller. It ensures efficient data transmission using Ethernet frames and reliable TCP-based communication, supported by FPGA hardware.

---

## Features

### Communication Framework
- **Message Exchange**:
  - Data is encapsulated into Ethernet frames by the FrameGenerator and transmitted to the 1 G PHY.
  - Received frames are processed by the FrameSniffer, which extracts and forwards messages to post-processing modules.
- **Data Rates**:
  - Message access rate: **600 Mbps**
  - Packet transmission rate: **1 Gbps**

### PHY Integration
- **1 G PHY**:
  - Implements data transmission via AMD LogiCORE™ IP Ethernet PCS/PMA or SGMII core.
  - Interfaces with the FPGA's gigabit transceiver (GT) through optical signals converted by an SFP module.

### TCP-Based Protocol
- **Reliability**:
  - Uses TCP with a maximum payload of **1460 bytes** to avoid segmentation.
  - Fixed packet size of **1036 bytes** reduces hardware overhead and simplifies error handling.
- **Timeout Protocol**:
  - Ensures retransmission in case of acknowledgment timeout.

---

## Components

### `networkCentCtrl`
- Manages TCP-based communication.
- Includes **FrameGenerator** and **FrameSniffer** modules.
- Utilizes busy signals and handshaking mechanisms to prevent data loss or overwrites.
- Supports 3-way TCP handshakes for connection establishment and reliable data transfer.

### `FrameGenerator`
- Prepares and transmits Ethernet frames.
- Computes IP and TCP checksums and appends protocol headers.
- Transmits frames through the PHY and validates data integrity using Frame Check Sequence (FCS).

### `FrameSniffer`
- Processes incoming Ethernet frames, validating headers, addresses, and checksums.
- Computes the FCS and confirms packet validity.
- Extracts the TCP body for further post-processing.

---

## Technical Details

### Data Transmission Specifications
| **Parameter**              | **Value**         |
|----------------------------|------------------|
| Message access rate        | > 600 Mbps       |
| Packet transmission rate   | 1 Gbps           |

### I/O Description (Receiving Path)
| **Signal Name**      | **Direction** | **Description**                                          |
|----------------------|---------------|----------------------------------------------------------|
| `msg_accessed`       | Out           | Indicates the current batch of messages has been stored. |
| `busy_PP2Net_RX`     | In            | Indicates post-processing module access to `BRAMMsgRX`.  |
| `busy_Net2PP_RX`     | Out           | Indicates FrameSniffer access to `BRAMMsgRX`.            |
| `addrRX_msg[10:0]`   | Out           | Address for storing `dataRX_msg`.                       |
| `clkRX_msg`          | Out           | Clock for `BRAMMsgRX` ports.                            |
| `sizeRX_msg[10:0]`   | Out           | Size of the received message.                           |
| `dataRX_msg[31:0]`   | Out           | Received message to store in `BRAMMsgRX`.               |
| `weRX_msg`           | Out           | Write enable for `dataRX_msg`.                          |
| `gmii_rx_clk`        | In            | Clock for `gmii_rxd`.                                   |
| `gmii_rxd[7:0]`      | In            | Received frame data from 1 G PHY.                       |
| `gmii_rx_dv`         | In            | Valid signal for `gmii_rxd`.                            |
| `gmii_rx_er`         | In            | Indicates an error in `gmii_rxd`.                       |

### I/O Description (Transmitting Path)
| **Signal Name**      | **Direction** | **Description**                                          |
|----------------------|---------------|----------------------------------------------------------|
| `msg_stored`         | In            | Indicates the current batch of messages has been stored. |
| `busy_PP2Net_TX`     | In            | Indicates post-processing module access to `BRAMMsgTX`.  |
| `busy_Net2PP_TX`     | Out           | Indicates FrameGenerator access to `BRAMMsgTX`.          |
| `addrTX_msg[10:0]`   | Out           | Address for accessing `dataTX_msg`.                     |
| `clkTX_msg`          | Out           | Clock for `BRAMMsgTX` ports.                            |
| `sizeTX_msg[10:0]`   | In            | Size of the transferred message.                        |
| `dataTX_msg[31:0]`   | In            | Transferred message from `BRAMMsgTX`.                   |
| `link_status`        | In            | Indicates PHY connection status.                        |
| `gmii_tx_clk`        | In            | Clock for `gmii_txd`.                                   |
| `gmii_txd[7:0]`      | In            | Transmitted frame data to 1 G PHY.                      |
| `gmii_tx_en`         | In            | Valid signal for `gmii_txd`.                            |
| `gmii_tx_er`         | In            | Indicates an error in `gmii_txd`.                       |

---

## Block Diagram
![Classical Channel Block Diagram](figsrc/CH3_classicalchannel_block_IO.drawio.png)

---

## Importance
The **Classical Channel** module ensures:
- Reliable and efficient data exchange in the QKD system.
- Secure TCP-based communication with minimal packet loss.
- Robust operation leveraging FPGA-based components for precise control.

# Distillation Control Module

The **Distillation Control Module** manages the sequential execution of quantum key distillation processes, including sifting, error reconciliation, and privacy amplification. It coordinates the flow of qubit data, ensures the completion of each distillation phase, and triggers subsequent processes as necessary. Separate configurations for Alice and Bob guarantee synchronized operations.

---

## Features

### Process Management
- **State Control**:
  - Manages start and end signals for key calculations.
  - Monitors and signals readiness for each phase (sifted key, reconciled key, secret key).
- **Sequential Execution**:
  - Ensures each distillation phase is fully completed before starting new qubit processing.

### Alice-Specific Features
- Controls secret key length calculation prior to privacy amplification.

### Bob-Specific Features
- Focuses on readiness signals and qubit data flow synchronization.

---

## Components

### Control Block
- The block diagram for the control modules of Alice and Bob is shown below.
![圖片](https://github.com/user-attachments/assets/d5bdaff0-2275-4156-bcfc-ed3450aa19ee)

### State Diagrams
- Alice's Control State:
![圖片](https://github.com/user-attachments/assets/7dac4f26-2b5b-4e6c-b04e-2843c6107d66)
- Bob's Control State:
![圖片](https://github.com/user-attachments/assets/6d230d89-bf8a-42d4-98a8-7d5c35a5476f)

### I/O Descriptions
- Alice's I/O:
![圖片](https://github.com/user-attachments/assets/e16a2dd1-875a-4e5a-b634-6801fb2adb19)
- Bob's I/O:
![圖片](https://github.com/user-attachments/assets/03d51ac9-aa0c-4dd7-a1f9-9f53296d2a97)

---

## Functionality

1. **Phase Progression**:
   - Tracks and verifies the completion of sifting, error reconciliation, and privacy amplification.
   - Prevents new qubit writes until the current batch completes distillation.

2. **Readiness Indication**:
   - Signals readiness when sufficient keys are generated for the next phase.

3. **Synchronization**:
   - Guarantees that Alice and Bob operate in lockstep, maintaining the integrity of the distillation process.

---

## Importance

The **Distillation Control Module** is critical for the systematic and reliable execution of key distillation processes. Its state-based design and readiness monitoring ensure seamless coordination between phases, supporting the secure generation of quantum keys in a QKD system.

# AXI BRAM Controller Module

The **AXI BRAM Controller** facilitates synchronized data exchange between the AXI BRAM and the distillation process control module, ensuring efficient and reliable system operation. This module updates the FPGA state address in the AXIstate BRAM based on valid request signals and triggers subsequent operations once data verification is complete.

---

## Features

### Core Functions
- **State Management**:
  - Updates FPGA state in AXIstate BRAM based on incoming requests.
  - Monitors valid signals to ensure updates are synchronized and accurate.
- **Ready Signal Generation**:
  - Indicates system readiness to the distillation process control module after data integrity verification.

### Architecture
- **Port B Access**:
  - Handles both read and write operations for AXIstate BRAM using Port B.
- **State Machine**:
  - Implements a finite state machine (FSM) to manage the module’s operations efficiently.

---

## Components

### Block Diagram
- Block Diagram of the AXI BRAM Controller:
![圖片](https://github.com/user-attachments/assets/9b9539c1-5aae-431e-9127-782f10a65a56)

### State Diagram
- FSM for AXI BRAM Controller:
![圖片](https://github.com/user-attachments/assets/111fb998-8bca-4998-82ce-3bd24ef5c57b)

### State Outputs
- Outputs for each state of the FSM:
![圖片](https://github.com/user-attachments/assets/865dc58b-c9ea-4427-81cc-619187f2712f)

### I/O Descriptions
- Alice's Side:
![圖片](https://github.com/user-attachments/assets/aae62be5-172f-4439-bbb6-3b982f1061e0)
- Bob's Side:
![圖片](https://github.com/user-attachments/assets/42eb3abe-398c-4380-b378-af68fb82f408)

---

## Functionality

1. **State Updates**:
   - Receives request signals for each BRAM and updates only when the request is valid.
   - Ensures state integrity through strict verification protocols.

2. **Data Verification**:
   - Confirms correctness of data updates before signaling readiness.
   - Prevents premature transitions that could compromise system synchronization.

3. **Readiness Signaling**:
   - Notifies the distillation process control module when the system is prepared for the next operation.

---

## Importance

The **AXI BRAM Controller** plays a pivotal role in managing the communication and synchronization between the AXI BRAM and other QKD system components. Its robust FSM ensures data integrity, while the ready signals streamline the workflow of the quantum key distillation process.

# AXI Manager IP

The **AXI Manager IP**, provided by Matlab, bridges the PC and FPGA, enabling efficient read and write operations to the FPGA's BRAM resources. It plays a crucial role in organizing and accessing data across various BRAMs on the FPGA.

---

## Features

### Key Capabilities
- **Bidirectional Communication**:
  - Facilitates seamless data transfer between the PC and FPGA.
- **Efficient Address Mapping**:
  - Maps a single 32-bit PC address to multiple BRAM addresses for optimized data organization.
- **BRAM Resource Utilization**:
  - Provides dedicated address spaces for various BRAMs on Alice's and Bob's sides.

---

## Components

### Block Diagrams
- **Alice's Side**:
![圖片](https://github.com/user-attachments/assets/7d02d7ff-c7a8-420a-a43b-3c2c85bbde76)
- **Bob's Side**:
![圖片](https://github.com/user-attachments/assets/222dd52f-fce9-4556-ac08-733baf5970b1)

---

## Address Mapping

The address mappings for the AXI Manager IP are tailored to allocate distinct regions for each BRAM resource, ensuring efficient data handling.

### Alice's Side Address Mapping
| **Name**            | **Master Base Address** | **Range** | **Master High Address** |
|----------------------|-------------------------|-----------|-------------------------|
| Qubit BRAM          | `0x0000_0000`           | 256K      | `0x0003_FFFF`          |
| EVrandombit BRAM    | `0x1000_0000`           | 128K      | `0x1001_FFFF`          |
| PArandombit BRAM    | `0x2000_0000`           | 128K      | `0x2001_FFFF`          |
| Secretkey BRAM      | `0x4000_0000`           | 256K      | `0x4003_FFFF`          |
| AXIstate BRAM       | `0x8000_0000`           | 4K        | `0x8000_0FFF`          |

### Bob's Side Address Mapping
| **Name**                   | **Master Base Address** | **Range** | **Master High Address** |
|----------------------------|-------------------------|-----------|-------------------------|
| AXIstate BRAM              | `0x0000_0000`           | 4K        | `0x0000_0FFF`          |
| Secretkey BRAM             | `0x1000_0000`           | 256K      | `0x1003_FFFF`          |
| Xbasis detected pos BRAM   | `0x4000_0000`           | 256K      | `0x4003_FFFF`          |
| Zbasis detected pos BRAM   | `0x8000_0000`           | 256K      | `0x8003_FFFF`          |

---

## Workflow

### PC Side
- Utilizes a 32-bit address input for specifying BRAM addresses.
- Efficiently maps PC-level operations to FPGA BRAM resources.

### FPGA Side
- Uses Port A of the AXI Manager storage element for all read and write operations.
- Ensures consistent data synchronization and integrity across all BRAM resources.

---

## Importance

The **AXI Manager IP** is pivotal in ensuring efficient communication between the PC and FPGA in a QKD system. Its robust address mapping and streamlined data access mechanisms enhance the utilization of FPGA BRAM resources, supporting the overall quantum key distillation process.

# Host Program

## Overview

The **Host Program** is responsible for managing input data and coordinating the quantum key distillation process. It ensures seamless interaction between the host computer and the FPGA-based quantum key distribution (QKD) system.

## Key Features

### Data Input

- **Alice Side**:
  - Qubit information.
  - Random bits for:
    - Error reconciliation.
    - Privacy amplification.

- **Bob Side**:
  - Detected qubit information for:
    - X-basis measurements.
    - Z-basis measurements.

- **Data Handling**:
  - All input data is written to the FPGA's BRAM using the address mappings specified in:
![圖片](https://github.com/user-attachments/assets/5bf205cb-f5b5-42f7-8d8d-98e01a31d6e9)
![圖片](https://github.com/user-attachments/assets/a4c0a33c-390e-4390-8026-a11cd1a4b4b4)

### System Initialization

- A **start signal** is written to the AXI State BRAM after all required data is provided, triggering the system to begin the distillation process.

### Monitoring Progress

- **AXI State BRAM**:
  - Periodically read to track the system's current operational step.
  - For example:
    - During the **sifting phase**, the sifted key must accumulate to a sufficient size before transitioning to the **error reconciliation phase**.
  - Multiple iterations of processing qubit and decoy qubit information may be required.

### Process Completion

- At the conclusion of the distillation process:
  - The AXI State BRAM is examined to verify that all operations are complete.
  - Once verified, the **secret key** can be retrieved from the system.

## Advantages

- Provides a structured and reliable framework for managing the QKD system.
- Ensures accurate tracking of the distillation process.
- Guarantees the integrity of the generated secret key.
