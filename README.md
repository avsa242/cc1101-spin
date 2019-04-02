# cc1101-spin 
---------------

This is a P8X32A/Propeller driver object for Texas Instruments CC1101 low-power ISM-band (sub-1GHz) RF transceiver (SPI).

## Salient Features

* Over-the-air (OTA) data rate from 1kBaud to 500kBaud
* 2FSK, 4FSK, GFSK, ASK/OOK, MSK modulation formats
* Receive bandwidth from 58kHz to 812kHz
* User-set number of preamble bytes
* Intermediate Frequency from 25kHz to 787kHz
* On-chip I/O pin signal output configuration (currently a few different common modes available)

## Requirements

* 1 extra core/cog for the PASM SPI driver

## Limitations

* Very early development - feature incomplete and may malfunction or outright fail to build
* Carrier frequency can currently only be selected from a fixed 315, 433 or 868MHz
* Available OTA baud rates are currently just common presets from 1k to 500k.

## TODO

- [ ] TX frequency deviation
- [x] GDO I/O pin config
- [ ] Fine-grained carrier-freq setting
- [ ] Fine-grained baudrate setting
