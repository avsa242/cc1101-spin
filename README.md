# cc1101-spin 
-------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for Texas Instruments CC1101 low-power ISM-band (sub-1GHz) RF transceiver.

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* SPI connection at up to 1MHz (P1), ~5MHz (P2)
* Over-the-air (OTA) data rate from 1kBaud to 500kBaud
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
* P1: 1 extra core/cog for the PASM SPI driver

P2/SPIN2:
* p2-spin-standard-library

## Compiler Compatibility

* P1/SPIN1: OpenSpin (tested with 1.00.81)
* P2/SPIN2: FastSpin (tested with 4.1.10-beta)
* ~~BST~~ (incompatible - no preprocessor)
* ~~Propeller Tool~~ (incompatible - no preprocessor)
* ~~PNut~~ (incompatible - no preprocessor)

## Limitations

* Very early in development - may malfunction or outright fail to build
* Available OTA baud rates are currently just common presets from 1k to 500k.

## TODO

- [x] TX frequency deviation
- [x] GDO I/O pin config
- [x] Fine-grained carrier-freq setting
- [x] Method to set transmit power
- [ ] Fine-grained baudrate setting

