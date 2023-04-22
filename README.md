# cc1101-spin 
-------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for Texas Instruments CC1101 low-power ISM-band (sub-1GHz) RF transceiver.

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* SPI connection at up to 1MHz (P1), ~5MHz (P2)
* Over-the-air (OTA) data rate from 600 Baud to 500kBaud
* 2FSK, 4FSK, GFSK, ASK/OOK, MSK modulation formats
* Set common RF parameters: Receive bandwidth, IF, carrier freq, DC block filter, RX Gain, TX power, FSK deviation freq, channel spacing
* Set number of preamble bytes
* Set function of CC1101's GPIO pins
* Address filtering
* Options for increasing transmission robustness: Data whitening, Manchester encoding, FEC, syncword
* RSSI measurement

## Requirements

P1/SPIN1:
* spin-standard-library
* P1: 1 extra core/cog for the PASM SPI engine (none if bytecode-based engine is used)

P2/SPIN2:
* p2-spin-standard-library

## Compiler Compatibility

| Processor | Language | Compiler               | Backend     | Status                |
|-----------|----------|------------------------|-------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.1.1)       | Bytecode    | OK                    |
| P1        | SPIN1    | FlexSpin (6.1.1)       | Native code | OK                    |
| P1        | SPIN1    | OpenSpin (1.00.81)     | Bytecode    | Untested (deprecated) |
| P2        | SPIN2    | FlexSpin (6.1.1)       | NuCode      | FTBFS                 |
| P2        | SPIN2    | FlexSpin (6.1.1)       | Native code | OK                    |
| P1        | SPIN1    | Brad's Spin Tool (any) | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | Propeller Tool (any)   | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | PNut (any)             | Bytecode    | Unsupported           |

## Limitations

* TBD

