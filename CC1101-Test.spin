{
    --------------------------------------------
    Filename: CC1101-Test.spin
    Author: Jesse Burt
    Description: Test object for the cc1101 driver
    Copyright (c) 2019
    Started Mar 25, 2019
    Updated Mar 30, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

    CS_PIN      = 13
    SCK_PIN     = 8
    MOSI_PIN    = 9
    MISO_PIN    = 10

    COL_REG     = 0
    COL_SET     = 12
    COL_READ    = 24
    COL_PF      = 40

OBJ

    cfg : "core.con.boardcfg.flip"
    ser : "com.serial.terminal"
    time: "time"
    rf  : "wireless.transceiver.cc1101.spi"

VAR

    byte _ser_cog

PUB Main

    Setup

    rf.Idle

    AUTOCAL (1)
    DRATE (1)
    CHANBW (1)

    Flash (cfg#LED1)

PUB AUTOCAL(reps) | tmp, read

    repeat reps
        repeat tmp from 0 to 3
            rf.AutoCal (tmp)
            read := rf.AutoCal (-2)
            Message (string("FS_AUTOCAL"), tmp, read)

PUB DRATE(reps) | tmp, read

    repeat reps
        repeat tmp from 1 to 11
            rf.DataRate (lookup(tmp: 1000, 1200, 2400, 4800, 9600, 19_600, 38_400, 76_800, 153_600, 250_000, 500_000))
            read := rf.DataRate (-2)
            Message (string("DRATE"), lookup(tmp: 1000, 1200, 2400, 4800, 9600, 19_600, 38_400, 76_800, 153_600, 250_000, 500_000), read)

PUB CHANBW(reps) | tmp, read

    repeat reps
        repeat tmp from 1 to 16
            rf.RXBandwidth (lookup(tmp: 812, 650, 541, 464, 406, 325, 270, 232, 203, 162, 135, 116, 102, 81, 68, 58))
            read := rf.RXBandwidth (-2)
            Message (string("CHANBW"), lookup(tmp: 812, 650, 541, 464, 406, 325, 270, 232, 203, 162, 135, 116, 102, 81, 68, 58), read)

PUB Message(field, arg1, arg2)

    ser.PositionX ( COL_REG)
    ser.Str (field)

    ser.PositionX ( COL_SET)
    ser.Str (string("SET: "))
    ser.Dec (arg1)

    ser.PositionX ( COL_READ)
    ser.Str (string("   READ: "))
    ser.Dec (arg2)

    ser.PositionX (COL_PF)
    PassFail (arg1 == arg2)
    ser.NewLine

PUB PassFail(num)

    case num
        0: ser.Str (string("FAIL"))
        -1: ser.Str (string("PASS"))
        OTHER: ser.Str (string("???"))

PUB Setup

    repeat until _ser_cog := ser.Start (115_200)
    ser.Clear
    ser.Str(string("Serial terminal started", ser#NL))
    if rf.Start (CS_PIN, SCK_PIN, MOSI_PIN, MISO_PIN)
        ser.Str (string("CC1101 driver started", ser#NL))
    else
        ser.Str (string("CC1101 driver failed to start - halting", ser#NL))
        rf.Stop
        time.MSleep (500)
        ser.Stop

PUB Flash(pin)

    dira[pin] := 1
    repeat
        !outa[pin]
        time.MSleep (100)

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
