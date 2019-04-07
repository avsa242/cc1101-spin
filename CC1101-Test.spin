{
    --------------------------------------------
    Filename: CC1101-Test.spin
    Author: Jesse Burt
    Description: Test object for the cc1101 driver
    Copyright (c) 2019
    Started Mar 25, 2019
    Updated Apr 2, 2019
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
    COL_SET     = 25
    COL_READ    = 37
    COL_PF      = 52

OBJ

    cfg : "core.con.boardcfg.flip"
    ser : "com.serial.terminal"
    time: "time"
    rf  : "wireless.transceiver.cc1101.spi"

VAR

    long _fails, _expanded
    byte _ser_cog, _row

PUB Main

    Setup

    rf.Idle
    _row := 1
    RXOFF_MODE (1)
    AUTOCAL (1)
    DRATE (1)
    CHANBW (1)
    ADDR(1)
    CHANNR (1)
    CRC_EN (1)
    DEM_DCFILT_OFF (1)
    FEC_EN (1)
    IOCFG0 (1)
    IOCFG1 (1)
    IOCFG2 (1)
    MANCHESTER_EN (1)
    MOD_FORMAT (1)
    NUM_PREAMBLE (1)
    SYNC1 (1)
    TXOFF_MODE (1)
    LENGTH_CONFIG (1)
    PKTCTRL1_APPEND_STATUS (1)
    CARRIER_SENSE_REL_THR (1)
    ser.NewLine
    ser.Str (string("Total failures: "))
    ser.Dec (_fails)
    Flash (cfg#LED1)

PUB CARRIER_SENSE_REL_THR(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 1 to 4
            rf.CarrierSense (lookup(tmp: 0, 6, 10, 14))
            read := rf.CarrierSense (-2)
            Message (string("CARRIER_SENSE_REL_THR"), lookup(tmp: 0, 6, 10, 14), read)

PUB PKTCTRL1_APPEND_STATUS(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to -1
            rf.AppendStatus (tmp)
            read := rf.AppendStatus (-2)
            Message (string("PKTCTRL1 (APPEND_STATUS)"), tmp, read)

PUB PKTLEN(reps) | tmp, read

    _row++
'    _expanded := TRUE
'    rf.Reset
'    rf.Idle
'    rf.PacketLenCfg (rf#PKTLEN_FIXED)
    repeat reps
        repeat tmp from 1 to 255
            rf.PacketLen (tmp)
            read := rf.PacketLen (-2)
            Message (string("PKTLEN"), tmp, read)
'            time.MSleep (10)

PUB LENGTH_CONFIG(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 2
            rf.PacketLenCfg (tmp)
            read := rf.PacketLenCfg (-2)
            Message (string("LENGTH_CONFIG"), tmp, read)

PUB TXOFF_MODE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 3
            rf.TXOff (tmp)
            read := rf.TXOff (-2)
            Message (string("TXOFF_MODE"), tmp, read)

PUB SYNC1(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from $0000 to $00FF '$FFFF
            rf.SyncWord (tmp)
            read := rf.SyncWord (-2)
            Message (string("SYNC1"), tmp, read)

PUB NUM_PREAMBLE(reps) | tmp, read

'    _expanded := TRUE
    _row++
    repeat reps
        repeat tmp from 1 to 8
            rf.Preamble (lookup(tmp: 2, 3, 4, 6, 8, 12, 16, 24))
            read := rf.Preamble (-2)
            Message (string("NUM_PREAMBLE"), lookup(tmp: 2, 3, 4, 6, 8, 12, 16, 24), read)

PUB MOD_FORMAT(reps) | tmp, read

    _row++
    repeat tmp from 0 to 7
        case tmp
            0, 1, 3, 4, 7:
                rf.Modulation (tmp)
                read := rf.Modulation (-2)
                Message (string("MOD_FORMAT"), tmp, read)

            OTHER:
                next

PUB MANCHESTER_EN(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to -1
            rf.ManchesterEnc (tmp)
            read := rf.ManchesterEnc (-2)
            Message (string("MANCHESTER_EN"), tmp, read)

PUB IOCFG2(reps) | tmp, read

    _row++
    repeat tmp from $00 to $3F
        case tmp
            $00..$0F, $16..$17, $1B..$1D, $24..$27, $29, $2B, $2E..$3F:
                rf.GDO2 (tmp)
                read := rf.GDO2 (-2)
                Message (string("IOCFG2"), tmp, read)

            OTHER:
                next

PUB IOCFG1(reps) | tmp, read

    _row++
    repeat tmp from $00 to $3F
        case tmp
            $00..$0F, $16..$17, $1B..$1D, $24..$27, $29, $2B, $2E..$3F:
                rf.GDO1 (tmp)
                read := rf.GDO1 (-2)
                Message (string("IOCFG1"), tmp, read)

            OTHER:
                next

PUB IOCFG0(reps) | tmp, read

    _row++
    repeat tmp from $00 to $3F
        case tmp
            $00..$0F, $16..$17, $1B..$1D, $24..$27, $29, $2B, $2E..$3F:
                rf.GDO0 (tmp)
                read := rf.GDO0 (-2)
                Message (string("IOCFG0"), tmp, read)

            OTHER:
                next

PUB FEC_EN(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to -1
            rf.FEC (tmp)
            read := rf.FEC (-2)
            Message (string("FEC_EN"), tmp, read)

PUB DEM_DCFILT_OFF(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to -1
            rf.DCBlock (tmp)
            read := rf.DCBlock (-2)
            Message (string("DEM_DCFILT_OFF"), tmp, read)

PUB CRC_EN(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to -1
            rf.CRCCheck (tmp)
            read := rf.CRCCheck (-2)
            Message (string("CRC_EN"), tmp, read)

PUB CHANNR(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 255
            rf.Channel (tmp)
            read := rf.Channel (-2)
            Message (string("CHANNR"), tmp, read)

PUB ADDR(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 255
            rf.Address (tmp)
            read := rf.Address (-2)
            Message (string("ADDR"), tmp, read)

PUB RXOFF_MODE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 3
            rf.RXOff (tmp)
            read := rf.RXOff (-2)
            Message (string("RXOFF_MODE"), tmp, read)

PUB AUTOCAL(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 0 to 3
            rf.AutoCal (tmp)
            read := rf.AutoCal (-2)
            Message (string("FS_AUTOCAL"), tmp, read)

PUB DRATE(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 1 to 11
            rf.DataRate (lookup(tmp: 1000, 1200, 2400, 4800, 9600, 19_600, 38_400, 76_800, 153_600, 250_000, 500_000))
            read := rf.DataRate (-2)
            Message (string("DRATE"), lookup(tmp: 1000, 1200, 2400, 4800, 9600, 19_600, 38_400, 76_800, 153_600, 250_000, 500_000), read)

PUB CHANBW(reps) | tmp, read

    _row++
    repeat reps
        repeat tmp from 1 to 16
            rf.RXBandwidth (lookup(tmp: 812, 650, 541, 464, 406, 325, 270, 232, 203, 162, 135, 116, 102, 81, 68, 58))
            read := rf.RXBandwidth (-2)
            Message (string("CHANBW"), lookup(tmp: 812, 650, 541, 464, 406, 325, 270, 232, 203, 162, 135, 116, 102, 81, 68, 58), read)

PUB Message(field, arg1, arg2)

    case _expanded
        TRUE:
            ser.PositionX (COL_REG)
            ser.Str (field)

            ser.PositionX (COL_SET)
            ser.Str (string("SET: "))
            ser.Dec (arg1)

            ser.PositionX (COL_READ)
            ser.Str (string("READ: "))
            ser.Dec (arg2)

            ser.PositionX (COL_PF)
            PassFail (arg1 == arg2)
            ser.NewLine

        FALSE:
            ser.Position (COL_REG, _row)
            ser.Str (field)

            ser.Position (COL_SET, _row)
            ser.Str (string("SET: "))
            ser.Hex (arg1, 4)

            ser.Position (COL_READ, _row)
            ser.Str (string("READ: "))
            ser.Hex (arg2, 8)

            ser.Position (COL_PF, _row)
            PassFail (arg1 == arg2)
            ser.NewLine
        OTHER:
            ser.Str (string("DEADBEEF"))
PUB PassFail(num)

    case num
        0:
            ser.Str (string("FAIL"))
            _fails++

        -1:
            ser.Str (string("PASS"))

        OTHER:
            ser.Str (string("???"))

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
