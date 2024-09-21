{
----------------------------------------------------------------------------------------------------
    Filename:       CC1101-SimpleTX.spin
    Description:    Simple transmit demo of the cc1101 driver
    Author:         Jesse Burt
    Started:        Nov 29, 2020
    Updated:        Sep 21, 2024
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

    _clkmode        = xtal1+pll16x
    _xinfreq        = 5_000_000

' -- User-modifiable constants
    TO_NODE         = $01                       ' address to send to (01..FE)
' --

    POS_PKTLEN      = 0
    POS_TONODE      = 1
    POS_PAYLD       = 2
    MAX_PAYLD       = 251                       ' 255 - pktlen - addr - CRC
                                                '       (1byte, 1byte, 2bytes)


OBJ

    time:   "time"
    str:    "string"
    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200
    cc1101: "wireless.transceiver.cc1101" | CS=0, SCK=1, MOSI=2, MISO=3, ...
                                            PPB=65_000 { optional CC1101 crystal offset correction }


VAR

    byte _pkt_tmp[MAX_PAYLD]
    long _user_str[8]


PUB main() | counter, i, pktlen

    setup()

    _user_str := @"TEST"                        ' any string up to 251 bytes

    cc1101.preset_robust1()                     ' use preset settings
    cc1101.carrier_freq(433_900_000)            ' freq. to transmit on
    cc1101.tx_pwr(0)                            ' -30, -20, -15, -10, 0, 5, 7, 10

    ser.clear()
    ser.pos_xy(0, 0)
    ser.printf1(@"Transmit mode - %dHz\n\r", cc1101.carrier_freq())

    counter := 0
    repeat
        bytefill(@_pkt_tmp, 0, MAX_PAYLD)       ' clear out buffer

        { assemble the payload and copy it to the temporary buffer }
        str.sprintf2(@_pkt_tmp[POS_PAYLD], @"%s%04.4d", _user_str, counter++)

        { payload size is user string, the counter digits, and the address }
        pktlen := strsize(@_pkt_tmp[POS_PAYLD]) + 1
        _pkt_tmp[POS_PKTLEN] := pktlen          ' 1st byte is payload length
        _pkt_tmp[POS_TONODE] := TO_NODE         ' 2nd byte is destination addr

        ser.pos_xy(0, 3)
        ser.printf2(@"Sending (%d): %s\n\r", pktlen, @_pkt_tmp[POS_PAYLD])

        { show hexdump of the packet, including non-payload data (length) }
        ser.hexdump(@_pkt_tmp, 0, 2, (pktlen+1), 16 <# (pktlen+1))
        ser.strln(@"    |  |  |")
        ser.strln(@"    |  |  *- start of payload/data")
        ser.strln(@"    |  *---- node address to transmit to")
        ser.strln(@"    *------- length of payload (including address byte)")

        cc1101.flush_tx()                       ' flush transmit buffer
        cc1101.tx_mode()                        ' set to transmit mode
        cc1101.tx_payld(pktlen+1, @_pkt_tmp)    ' transmit the data

        time.msleep(1_000)                      ' delay between packets to
                                                '   avoid abusing the airwaves


PUB setup()

    ser.start()
    time.msleep(30)
    ser.clear()
    ser.strln(@"Serial terminal started")

    if ( cc1101.start() )
        ser.strln(@"CC1101 driver started")
    else
        ser.strln(@"CC1101 driver failed to start - halting")
        repeat


DAT
{
Copyright 2024 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

