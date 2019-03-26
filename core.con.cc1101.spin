{
    --------------------------------------------
    Filename: core.con.cc1101.spin
    Author:
    Description:
    Copyright (c) 2019
    Started Mar 25, 2019
    Updated Mar 25, 2019
    See end of file for terms of use.
    --------------------------------------------
}

CON

' SPI Configuration
    CPOL                        = 0
    CLK_DELAY                   = 10
    MOSI_BITORDER               = 5             'MSBFIRST
    MISO_BITORDER               = 0             'MSBPRE

    W                           = 0
    R                           = 1 << 7

' Register definitions
'   Status byte
    SB_FLD_CHIP_RDY                 = 7
    SB_FLD_STATE                    = 4
    SB_FLD_FIFO_BYTES_AVAILABLE     = 0
    SB_BITS_STATE                   = %111
    SB_BITS_FIFO_BYTES_AVAILABLE    = %1111

    IOCFG2                          = $00
    IOCFG1                          = $01
    IOCFG0                          = $02
    FIFOTHR                         = $03
    SYNC1                           = $04
    SYNC0                           = $05
    PKTLEN                          = $06
    PKTCTRL1                        = $07
    PKTCTRL0                        = $08
    ADDR                            = $09
    CHANNR                          = $0A
    FSCTRL1                         = $0B
    FSCTRL0                         = $0C
    FREQ2                           = $0D
    FREQ1                           = $0E
    FREQ0                           = $0F
    MDMCFG4                         = $10
    MDMCFG3                         = $11
    MDMCFG2                         = $12
    MDMCFG1                         = $13
    MDMCFG0                         = $14
    DEVIATN                         = $15
    MCSM2                           = $16
    MCSM1                           = $17
    MCSM0                           = $18
    FOCCFG                          = $19
    BSCFG                           = $1A
    AGCTRL2                         = $1B
    AGCTRL1                         = $1C
    AGCTRL0                         = $1D
    WOREVT1                         = $1E
    WOREVT0                         = $1F
    WORCTRL                         = $20
    FREND1                          = $21
    FREND0                          = $22
    FSCAL3                          = $23
    FSCAL2                          = $24
    FSCAL1                          = $25
    FSCAL0                          = $26
    RCCTRL1                         = $27
    RCCTRL0                         = $28
    FSTEST                          = $29
    PTEST                           = $2A
    AGCTEST                         = $2B
    TEST2                           = $2C
    TEST1                           = $2D
    TEST0                           = $2E
    PARTNUM                         = $30
    VERSION                         = $31
    FREQEST                         = $32
    LQI                             = $33
    RSSI                            = $34
    MARCSTATE                       = $35
    WORTIME1                        = $36
    WORTIME0                        = $37
    PKTSTATUS                       = $38
    VCO_VC_DAC                      = $39
    TXBYTES                         = $3A
    RXBYTES                         = $3B
    RCCTRL1_STATUS                  = $3C
    RCCTRL0_STATUS                  = $3D

PUB Null
'' This is not a top-level object
