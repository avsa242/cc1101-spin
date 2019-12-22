{
    --------------------------------------------
    Filename: CC1101-RXDemo.spin
    Author: Jesse Burt
    Description: Simple receive demo of the cc1101 driver
    Copyright (c) 2019
    Started Nov 23, 2019
    Updated Dec 21, 2019                                                                                         
    See end of file for terms of use.
    --------------------------------------------
}
CON

    XTAL            = cfg#XTAL
    XDIV            = cfg#XDIV
    XMUL            = cfg#XMUL
    XDIVP           = cfg#XDIVP
    XOSC            = cfg#XOSC
    XSEL            = cfg#XSEL
    XPPPP           = cfg#XPPPP
    CLOCKFREQ       = cfg#CLOCKFREQ
    SETFREQ         = cfg#SETFREQ
    ENAFREQ         = cfg#ENAFREQ

    LED             = cfg#LED1
    SER_RX          = cfg#SER_RX
    SER_TX          = cfg#SER_TX
    SER_BAUD        = 2_000_000

    CS_PIN          = 27                            ' Change to your module's connections
    SCK_PIN         = 26
    MOSI_PIN        = 24
    MISO_PIN        = 25
    SCK_FREQ        = 5_000_000

    NODE_ADDRESS    = $01

OBJ

    ser         : "com.serial.terminal.ansi"
    cfg         : "core.con.boardcfg.p2eval"
    io          : "io"
    time        : "time"
    int         : "string.integer"
    cc1101      : "wireless.transceiver.cc1101.spi.spin2"

VAR

    long _ser_cog, _cc1101_cog
    long _fifo[16]
    byte _pktlen

PUB Main | choice

    Setup

    cc1101.GPIO0 (cc1101#IO_HI_Z)                   ' Set CC1101 GPIO0 to Hi-Z mode
    ser.printf("Version: %x\n", cc1101.Version)
    cc1101.AutoCal(cc1101#IDLE_RXTX)                ' Perform auto-calibration when transitioning from Idle to RX
    ser.printf("Autocal setting: %d\n", cc1101.AutoCal)
    cc1101.Idle
    
    ser.printf("Waiting for radio idle status...")
    repeat until cc1101.State == 1
    ser.printf("done\n")

    cc1101.CarrierFreq(433_900_000)                 ' Set carrier frequency

    ser.printf("Waiting for PLL lock...")
    repeat until cc1101.PLLLocked == TRUE           ' Don't proceed until PLL is locked
    ser.printf("done\n")

    ser.printf("Press any key to begin receiving\n")
    ser.CharIn

    Receive

    FlashLED(LED, 100)

PUB Receive | rxbytes, tmp, from_node

    _pktlen := 10
    cc1101.NodeAddress(NODE_ADDRESS)                ' Set this node's address
    cc1101.PayloadLenCfg (cc1101#PKTLEN_FIXED)      ' Fixed payload length
    cc1101.PayloadLen (_pktlen)                     ' Set payload length to _pktlen
    cc1101.CRCCheckEnabled (TRUE)                   ' Enable CRC checks on received payloads
    cc1101.SyncMode (cc1101#SYNCMODE_3032_CS)       ' Accept payload as valid only if:
                                                    '   At least 30 of 32 syncword bits match
                                                    '   Carrier sense is above set threshold

    ser.Clear
    ser.Position(0, 0)
    ser.printf("Receive mode - %dHz\n", cc1101.CarrierFreq)
    ser.printf("Listening for traffic on node address $")
    ser.Hex(cc1101.NodeAddress, 2)

    cc1101.AfterRX (cc1101#RXOFF_IDLE)              ' What state to change the radio to after reception
    cc1101.AddressCheck (cc1101#ADRCHK_CHK_NO_BCAST)' Address validation mode

    repeat
        bytefill (@_fifo, $00, 64)                  ' Clear RX fifo

        cc1101.RXMode                               ' Change radio state to receive mode
        ser.Position(0, 5)
        ser.PrintF("Radio state: ")
        ser.Str (@MARC_STATE[17 * cc1101.State])

        repeat                                      ' Wait to proceed
            rxbytes := cc1101.FIFORXBytes
        until rxbytes => _pktlen                    ' until we've received at least _pktlen bytes

        cc1101.RXData(rxbytes, @_fifo)
        cc1101.FlushRX

        from_node := _fifo.byte[1]                  ' Node we've received a packet from
        ser.Position(0, 9)
        ser.Printf("Received packet from node $")
        ser.Hex(from_node, 2)
        repeat tmp from 2 to rxbytes-1              ' Show received packet, minus the 2 'header' bytes
            ser.Position(((tmp-1) * 3), 10)
            ser.Hex(_fifo.byte[tmp], 2)
            case _fifo.byte[tmp]
                32..127:
                    ser.Position(((tmp-1) * 3), 11)
                    ser.Char(_fifo.byte[tmp])
                OTHER:
                    ser.Position(((tmp-1) * 3), 11)
                    ser.Char(".")

PUB Setup

    clkset(ENAFREQ, CLOCKFREQ, XSEL)
    repeat until _ser_cog := ser.StartRXTX (SER_RX, SER_TX, 0, SER_BAUD)
    ser.Clear
    ser.PrintF("Serial terminal started\n")
    if _cc1101_cog := cc1101.Start (CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN, SCK_FREQ)
        ser.printf("CC1101 driver started\n")
    else
        ser.printf("CC1101 driver failed to start - halting\n")
        FlashLED (LED, 500)

PUB FlashLED(led_pin, delay_ms)

    io.Output(led_pin)
    repeat
        io.Toggle(led_pin)
        time.MSleep(delay_ms)

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

