{
    --------------------------------------------
    Filename: wireless.transceiver.cc1101.spi.spin
    Author: Jesse Burt
    Description: Driver for TI's CC1101 ISM-band transceiver
    Copyright (c) 2019
    Started Mar 25, 2019
    Updated Mar 30, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON


VAR

    byte _CS, _MOSI, _MISO, _SCK
    byte _status_byte

OBJ

    spi : "SPI_Asm"                                             'PASM SPI Driver
    core: "core.con.cc1101"
    time: "time"                                                'Basic timing functions

PUB Null
''This is not a top-level object

PUB Start(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN): okay

    okay := Startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, core#CLK_DELAY, core#CPOL)

PUB Startx(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, SCK_DELAY, SCK_CPOL): okay
    if SCK_DELAY => 1 and lookdown(SCK_CPOL: 0, 1)
        if okay := spi.start (SCK_DELAY, SCK_CPOL)              'SPI Object Started?
            time.MSleep (5)
            _CS := CS_PIN
            _MOSI := MOSI_PIN
            _MISO := MISO_PIN
            _SCK := SCK_PIN

            outa[_CS] := 1
            dira[_CS] := 1
            if Version => $14                                   'Poll chip for version
                return okay

    return FALSE                                                'If we got here, something went wrong

PUB Stop

    spi.stop

PUB PartNumber
' Part number of device
'   Returns: $00
    readRegX (core#PARTNUM, 1, @result)

PUB SNOP

    writeRegX (core#CS_SNOP, 0, 0)
    return _status_byte

PUB Version
' Chip version number
'   Returns: $14
'   NOTE: Datasheet states this value is subject to change without notice
    readRegX (core#VERSION, 1, @result)

PUB readRegX(reg, nr_bytes, addr_buff) | i
' Read nr_bytes from register 'reg' to address 'addr_buff'
    case reg
        $00..$2E:
            reg |= core#R
        $30..$3D:                               'Status regs
            reg |= core#R | core#BURST          'Must set BURST mode bit to read them, else they're interpreted as
                                                '   command strobes
    outa[_CS] := 0
    spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg)
    
    repeat i from 0 to nr_bytes-1
        byte[addr_buff][i] := spi.SHIFTIN(_MISO, _SCK, core#MISO_BITORDER, 8)
    outa[_CS] := 1

PUB writeRegX(reg, nr_bytes, val) | i
' Write nr_bytes to register 'reg' stored in val
'HEADER BYTE:
' MSB   = R(1)/W(0) bit
' b6    = BURST ACCESS BIT (B)
' b5..0 = 6-bit ADDRESS (A5-A0)
'IF CS PULLED LOW, WAIT UNTIL SO LOW WHEN IN SLEEP OR XOFF STATES
    reg |= core#W
    outa[_CS] := 0
    spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg)

    case reg
        $30..$3D:
            _status_byte := spi.SHIFTIN (_MISO, _SCK, core#MISO_BITORDER, 8)
        OTHER:
            repeat i from 0 to nr_bytes
                spi.SHIFTOUT(_MOSI, _SCK, core#MISO_BITORDER, 8, val.byte[i])

    outa[_CS] := 1

DAT
{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
