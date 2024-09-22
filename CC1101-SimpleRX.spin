{
----------------------------------------------------------------------------------------------------
    Filename:       CC1101-SimpleRX.spin
    Description:    Simple receive demo of the cc1101 driver
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
    NODE_ADDRESS    = $01                       ' this node's address (1..254)
' --

    POS_TONODE      = 0
    POS_PAYLD       = 1
    MAX_PAYLD       = 255


OBJ

    time:   "time"
    str:    "string"
    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200
    cc1101: "wireless.transceiver.cc1101" | CS=0, SCK=1, MOSI=2, MISO=3, ...
                                            PPB = 65_000 { optional CC1101 crystal offset correction }


VAR

    byte _pkt_tmp[MAX_PAYLD]
    byte _recv[MAX_PAYLD]
    byte _pktlen


PUB main() | rxbytes

    setup()

    cc1101.preset_robust1()                     ' use preset settings
    cc1101.carrier_freq(433_900_000)            ' set carrier frequency
    cc1101.node_addr(NODE_ADDRESS)              ' this node's address

    ser.clear()
    ser.pos_xy(0, 0)
    ser.printf1(@"Receive mode - %dHz\n\r", cc1101.carrier_freq())

    repeat
        bytefill(@_pkt_tmp, $00, MAX_PAYLD)     ' clear out buffers 
        bytefill(@_recv, $00, MAX_PAYLD)

        cc1101.rx_mode()                        ' set to receive mode
        repeat until cc1101.fifo_rx_bytes() => 1' wait for first recv'd bytes
        cc1101.rx_payld(1, @rxbytes)            ' get length of recv'd payload
                                                ' (1st byte of packet in
                                                '   default variable-length
                                                '   packet mode)

        repeat until cc1101.fifo_rx_bytes() => rxbytes
        cc1101.rx_payld(rxbytes, @_pkt_tmp)     ' now, read that many bytes
        cc1101.flush_rx()                       ' flush receive buffer

        ser.pos_xy(0, 3)
        ser.printf2(@"Received (%d): %s", strsize(@_pkt_tmp), @_pkt_tmp)
        ser.clear_line()
        ser.newline()

        { show the packet received as a simple hex dump }
        ser.hexdump(@_pkt_tmp, 0, 2, strsize(@_pkt_tmp), 16 <# strsize(@_pkt_tmp))

        ser.strln(@"    |  |")
        ser.strln(@"    |  *- start of payload/data")
        ser.strln(@"    *---- address packet was sent to")


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

