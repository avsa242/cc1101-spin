{
    --------------------------------------------
    Filename: CC1101-Test.spin
    Author:
    Description:
    Copyright (c) 2019
    Started Mar 25, 2019
    Updated Mar 25, 2019
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

OBJ

    cfg : "core.con.boardcfg.flip"
    ser : "com.serial.terminal"
    time: "time"
    rf  : "wireless.transceiver.cc1101.spi"

VAR

    byte _ser_cog

PUB Main | i, j, tmp

    Setup
    ser.CharIn

    Flash (cfg#LED1)

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
