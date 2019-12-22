# cc1101-spin 
-------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for Texas Instruments CC1101 low-power ISM-band (sub-1GHz) RF transceiver.

## Salient Features

<<<<<<< HEAD
* SPI connection at up to 1MHz (P1), ~5MHz (P2)
=======
* SPI connection at up to 5MHz
>>>>>>> p2-testing
* Over-the-air (OTA) data rate from 1kBaud to 500kBaud
* 2FSK, 4FSK, GFSK, ASK/OOK, MSK modulation formats
* Set common RF parameters: Receive bandwidth, IF, carrier freq, DC block filter, RX Gain, FSK deviation freq
* Set number of preamble bytes
* Set function of CC1101's GPIO pins
* Address filtering
* Options for increasing transmission robustness: Data whitening, Manchester encoding, FEC, syncword
<<<<<<< HEAD
=======
* On-chip I/O pin signal output configuration (currently a few different common modes available)
>>>>>>> p2-testing
* RSSI measurement

## Requirements

* 1 extra core/cog for the PASM SPI driver

## Compiler Compatibility

* P1/SPIN1: OpenSpin (tested with 1.00.81)
* P2/SPIN2: FastSpin (tested with 4.0.4)

## Limitations

* Very early development - feature incomplete and may malfunction or outright fail to build
* Available OTA baud rates are currently just common presets from 1k to 500k.
* Transmit power setting not currently supported

## TODO

- [x] TX frequency deviation
- [x] GDO I/O pin config
- [x] Fine-grained carrier-freq setting
- [ ] Method to set transmit power
- [ ] Fine-grained baudrate setting

