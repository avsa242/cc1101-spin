{
    --------------------------------------------
    Filename: CC1101-RXDemo.spin
    Author: Jesse Burt
    Description: Simple receive demo of the cc1101 driver
    Copyright (c) 2020
    Started Nov 23, 2019
    Updated Apr 14, 2020
    See end of file for terms of use.
    --------------------------------------------
}
CON

    _clkmode        = cfg#_clkmode
    _xinfreq        = cfg#_xinfreq

' -- User-modifiable constants
    LED             = cfg#LED1
    SER_BAUD        = 115_200

    CS_PIN          = 0                             ' Change to your module's connections
    SCK_PIN         = 1
    MOSI_PIN        = 2
    MISO_PIN        = 3

    NODE_ADDRESS    = $01
' --

OBJ

    ser         : "com.serial.terminal.ansi"
    cfg         : "core.con.boardcfg.flip"
    time        : "time"
    int         : "string.integer"
    cc1101      : "wireless.transceiver.cc1101.spi"

VAR

    long _fifo[16]
    byte _pktlen

PUB Main{} | i, tmp

    setup{}
{
    ser.charin
    cc1101.readreg($0d, 3, @tmp)
    ser.hex(tmp, 8)
    ser.newline
    ser.dec(cc1101.carrierfreq(-2))
    repeat
}
    
    cc1101.gpio0(cc1101#IO_HI_Z)                   ' Set CC1101 GPIO0 to Hi-Z mode
    cc1101.autocal(cc1101#IDLE_RXTX)                ' Perform auto-calibration when transitioning from Idle to RX
    ser.str(string("Autocal setting: "))
    ser.dec(cc1101.autocal(-2))
    ser.newline{}
    cc1101.idle{}
    
    ser.str(string("Waiting for radio idle status..."))
    repeat until cc1101.state{} == 1
    ser.strln(string("done"))

    cc1101.carrierfreq(433_900_000)                 ' Set carrier frequency

    ser.str(string("Waiting for PLL lock..."))
    repeat until cc1101.plllocked{}                 ' Don't proceed until PLL is locked
    ser.strln(string("done"))

    ser.strln(string("Press any key to begin receiving"))
    ser.charin{}

    receive{}

PUB Receive{} | rxbytes, tmp, from_node

    _pktlen := 10
    cc1101.nodeaddress(NODE_ADDRESS)                ' Set this node's address
    cc1101.payloadLenCfg(cc1101#PKTLEN_FIXED)      ' Fixed payload length
    cc1101.payloadLen(_pktlen)                     ' Set payload length to _pktlen
    cc1101.crccheckEnabled(TRUE)                   ' Enable CRC checks on received payloads
    cc1101.syncmode(cc1101#SYNCMODE_3032_CS)       ' Accept payload as valid only if:
                                                    '   At least 30 of 32 syncword bits match
                                                    '   Carrier sense is above set threshold

    ser.clear{}
    ser.position(0, 0)
    ser.str(string("Receive mode - "))
    ser.dec(cc1101.carrierfreq(-2))
    ser.str(string("Hz"))
    ser.newline{}

    ser.str(string("Listening for traffic on node address $"))
    ser.hex(cc1101.nodeaddress(-2), 2)

    cc1101.afterrx(cc1101#RXOFF_IDLE)              ' What state to change the radio to after reception
    cc1101.addresscheck(cc1101#ADRCHK_CHK_NO_BCAST)' Address validation mode

    repeat
        bytefill(@_fifo, $00, 64)                  ' Clear RX fifo

        cc1101.rxmode{}                               ' Change radio state to receive mode
        ser.position(0, 5)
        ser.str(string("Radio state: "))
        ser.str(@MARC_STATE[17 * cc1101.State])

        repeat                                      ' Wait to proceed
            rxbytes := cc1101.fiforxbytes{}
        until rxbytes => _pktlen                    ' until we've received at least _pktlen bytes

        cc1101.rxpayload(rxbytes, @_fifo)
        cc1101.flushrx{}

        from_node := _fifo.byte[1]                  ' Node we've received a packet from
        ser.position(0, 9)
        ser.str(string("Received packet from node $"))
        ser.hex(from_node, 2)
        repeat tmp from 2 to rxbytes-1              ' Show received packet, minus the 2 'header' bytes
            ser.position(((tmp-1) * 3), 10)
            ser.hex(_fifo.byte[tmp], 2)
            case _fifo.byte[tmp]
                32..127:
                    ser.position(((tmp-1) * 3), 11)
                    ser.char(_fifo.byte[tmp])
                other:
                    ser.position(((tmp-1) * 3), 11)
                    ser.char(".")

PUB Setup{}

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear{}
    ser.strln(string("Serial terminal started"))
    if cc1101.start(CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN)
        ser.strln(string("CC1101 driver started"))
    else
        ser.strln(string("CC1101 driver failed to start - halting"))
        repeat

DAT
' Radio states
MARC_STATE  byte    "SLEEP           ", 0 {0}
            byte    "IDLE            ", 0 {1}
            byte    "XOFF            ", 0 {2}
            byte    "VCOON_MC        ", 0 {3}
            byte    "REGON_MC        ", 0 {4}
            byte    "MANCAL          ", 0 {5}
            byte    "VCOON           ", 0 {6}
            byte    "REGON           ", 0 {7}
            byte    "STARTCAL        ", 0 {8}
            byte    "BWBOOST         ", 0 {9}
            byte    "FS_LOCK         ", 0 {10}
            byte    "IFADCON         ", 0 {11}
            byte    "ENDCAL          ", 0 {12}
            byte    "RX              ", 0 {13}
            byte    "RX_END          ", 0 {14}
            byte    "RX_RST          ", 0 {15}
            byte    "TXRX_SWITCH     ", 0 {16}
            byte    "RXFIFO_OVERFLOW ", 0 {17}
            byte    "FSTXON          ", 0 {18}
            byte    "TX              ", 0 {19}
            byte    "TX_END          ", 0 {20}
            byte    "RXRX_SWITCH     ", 0 {21}

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

