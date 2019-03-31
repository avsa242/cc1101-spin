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

    F_XOSC = 26_000_000     'CC1101 XTAL Oscillator freq, in Hz

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

PUB AutoCal(when) | tmp
' When to perform auto-calibration
'   Valid values:
'       NEVER (0) - Never (manually calibrate)
'       IDLE_RXTX (1) - When transitioning from IDLE to RX/TX
'       RXTX_IDLE (2) - When transitioning from RX/TX to IDLE
'       RXTX_IDLE4 (3) - Every 4th time when transitioning from RX/TX to IDLE (power-saving)
    readRegX (core#MCSM0, 1, @tmp)'reg, nr_bytes, addr_buff)
    case when
        0..3:
            when := when << core#FLD_FS_AUTOCAL
        OTHER:
            result := (tmp >> core#FLD_FS_AUTOCAL) & core#BITS_FS_AUTOCAL
            return result

    tmp &= core#MASK_FS_AUTOCAL
    tmp := (tmp | when)
    writeRegX (core#MCSM0, 1, @tmp)'reg, nr_bytes, buf_addr)

PUB CalFreqSynth
' Calibrate the frequency synthesizer
    writeRegX (core#CS_SCAL, 0, 0)

PUB CrystalOff
' Turn off crystal oscillator
    writeRegX (core#CS_SXOFF, 0, 0)

PUB DataRate(Baud) | tmp, tmp_e, tmp_m, DRATE_E, DRATE_M
' Set on-air data rate, in bps
'   Valid values: 1000, 1200, 2400, 4800, 9600, 19_600, 38_400, 76_800, 153_600, 250_000, 500_000
'   Any other value polls the chip and returns the current setting
    tmp := tmp_e := tmp_m := DRATE_E := DRATE_M := 0

    readRegX (core#MDMCFG4, 1, @tmp_e)
    readRegX (core#MDMCFG3, 1, @tmp_m)
    case Baud := lookdown(Baud: 1000, 1200, 2400, 4800, 9600, 19_600, 38_400, 76_800, 153_600, 250_000, 500_000)
        1..11:
            DRATE_E := lookup(Baud: $05, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E) & core#BITS_DRATE_E
            DRATE_M := lookup(Baud: $42, $83, $83, $83, $83, $8B, $83, $83, $83, $3B, $3B) & core#MDMCFG3_MASK
        OTHER:
            tmp_e &= core#BITS_DRATE_E
            tmp := (tmp_e << 8) | tmp_m
            result := lookdown(tmp: $0542, $0583, $0683, $0783, $0883, $098B, $0A83, $0B83, $0C83, $0D3B, $0E3B)
            return lookup(result: 1000, 1200, 2400, 4800, 9600, 19_600, 38_400, 76_800, 153_600, 250_000, 500_000)

    tmp_e &= core#MASK_DRATE_E
    tmp_e := (tmp_e | DRATE_E)

    writeRegX (core#MDMCFG4, 1, @tmp_e)
    writeRegX (core#MDMCFG3, 1, @DRATE_M)

PUB FIFO
' Returns number of bytes available in RX FIFO or free bytes in TX FIFO
    return Status & %1111

PUB FlushRX
' Flush receive FIFO/buffer
'   NOTE: Will only flush RX buffer if overflowed or if chip is idle, per datasheet recommendation
    case _status_byte
        core#MARCSTATE_RXFIFO_OVERFLOW, core#MARCSTATE_IDLE:
            writeRegX (core#CS_SFRX, 0, 0)
        OTHER:
            return

PUB FlushTX
' Flush transmit FIFO/buffer
'   NOTE: Will only flush TX buffer if underflowed or if chip is idle, per datasheet recommendation
    case _status_byte
        core#MARCSTATE_TXFIFO_UNDERFLOW, core#MARCSTATE_IDLE:
            writeRegX (core#CS_SFTX, 0, 0)
        OTHER:
            return

PUB Idle
' Change chip state to IDLE
    writeRegX (core#CS_SIDLE, 0, 0)

PUB IntFreq(kHz) | tmp
' Intermediate Frequency (IF), in kHz
'   Valid values: 25..787 (result will be rounded to the nearest 5-bit result)
'   Any other value polls the chip and returns the current setting
    readRegX (core#FSCTRL1, 1, @tmp)
    case kHz
        25..787:
            kHz := 1024/(F_XOSC/kHz)
        OTHER:
            return ((F_XOSC / 1024) * tmp) / 1000

    writeRegX (core#FSCTRL1, 1, kHz)

PUB PartNumber
' Part number of device
'   Returns: $00
    readRegX (core#PARTNUM, 1, @result)

PUB PARead(buf_addr)
' Read 8-byte PA table into buf_addr
'   NOTE: Ensure buf_addr is at least 8 bytes
    readRegX (core#PATABLE | core#BURST, 8, buf_addr)

PUB PAWrite(buf_addr)
' Write 8-byte PA table from buf_addr
'   NOTE: Table will be written starting at index 0 from the LSB of buf_addr
    writeRegX (core#PATABLE | core#BURST, 8, buf_addr)

PUB Reset
' Reset the chip
    writeRegX (core#CS_SRES, 0, 0)

PUB RX
' Change chip state to RX (receive)
    writeRegX (core#CS_SRX, 0, 0)

PUB RXBandwidth(kHz) | tmp
' Set receiver channel filter bandwidth, in kHz
'   Valid values: 812, 650, 541, 464, 406, 325, 270, 232, 203, 162, 135, 116, 102, 81, 68, 58
'   Any other value polls the chip and returns the current setting
    readRegX (core#MDMCFG4, 1, @tmp)
    case kHz := lookdown(kHz: 812, 650, 541, 464, 406, 325, 270, 232, 203, 162, 135, 116, 102, 81, 68, 58)
        1..16:
            kHz := (kHz-1) << core#FLD_CHANBW
'            return kHz
        OTHER:
            result := ((tmp >> core#FLD_CHANBW) & core#BITS_CHANBW)+1
            return lookup(result: 812, 650, 541, 464, 406, 325, 270, 232, 203, 162, 135, 116, 102, 81, 68, 58)

    tmp &= core#MASK_CHANBW
    tmp := (tmp | kHz)
    writeRegX ( core#MDMCFG4, 1, @tmp)'reg, nr_bytes, buf_addr)

PUB RXData(nr_bytes, buf_addr) | tmp
' Read data queued in the RX FIFO
'   nr_bytes Valid values: 1..64
'   Any other value is ignored
'   NOTE: Ensure buffer at address buf_addr is at least as big as the number of bytes you're reading
    case nr_bytes
        1:
            tmp := core#FIFO | core#R
        2..64:
            tmp := core#FIFO | core#R | core#BURST
        0:
            return

    readRegX (tmp, nr_bytes, buf_addr)

PUB Sleep
' Power down chip
    writeRegX (core#CS_SPWD, 0, 0)

PUB State
' Read state-machine register
    readRegX (core#MARCSTATE, 1, @result)

PUB Status
' Read the status byte
    writeRegX (core#CS_SNOP, 0, 0)
    return _status_byte

PUB TX
' Change chip state to TX (transmit)
    writeRegX (core#CS_STX, 0, 0)

PUB TXData(nr_bytes, buf_addr) | tmp
' Queue data to transmit in the TX FIFO
'   nr_bytes Valid values: 1..64
'   Any other value is ignored
    case nr_bytes
        1:
            tmp := core#FIFO
        2..64:
            tmp := core#FIFO | core#BURST
        0:
            return

    writeRegX (tmp, nr_bytes, buf_addr)

PUB Version
' Chip version number
'   Returns: $14
'   NOTE: Datasheet states this value is subject to change without notice
    readRegX (core#VERSION, 1, @result)

PUB WOR
' Change chip state to WOR (Wake-on-Radio)
    writeRegX (core#CS_SWOR, 0, 0)

PUB readRegX(reg, nr_bytes, addr_buff) | i
' Read nr_bytes from register 'reg' to address 'addr_buff'
    case reg
        $00..$2E:                               'Config regs
            reg |= core#R
        $30..$3D:                               'Status regs
            reg |= core#R | core#BURST          'Must set BURST mode bit to read them, else they're interpreted as
                                                '   command strobes
    outa[_CS] := 0
    spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg)

    repeat i from 0 to nr_bytes-1
        byte[addr_buff][i] := spi.SHIFTIN(_MISO, _SCK, core#MISO_BITORDER, 8)
    outa[_CS] := 1

PUB writeRegX(reg, nr_bytes, buf_addr) | tmp
' Write nr_bytes to register 'reg' stored in val
'HEADER BYTE:
' MSB   = R(1)/W(0) bit
' b6    = BURST ACCESS BIT (B)
' b5..0 = 6-bit ADDRESS (A5-A0)
'IF CS PULLED LOW, WAIT UNTIL SO LOW WHEN IN SLEEP OR XOFF STATES

    case reg
        $00..$2E:                               ' R/W regs
            case nr_bytes
                0:                              ' Invalid nr_bytes - ignore
                    return
                1:
                OTHER:
                    reg |= core#BURST

            outa[_CS] := 0
            spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg)
            repeat tmp from 0 to nr_bytes-1
                spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, byte[buf_addr][tmp])
            outa[_CS] := 1

        $30..$3D:                               ' Command strobes
            outa[_CS] := 0
            spi.SHIFTOUT(_MOSI, _SCK, core#MOSI_BITORDER, 8, reg)
            _status_byte := spi.SHIFTIN (_MISO, _SCK, core#MISO_BITORDER, 8)
            outa[_CS] := 1

        OTHER:                                  ' Invalid reg - ignore
            return

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
