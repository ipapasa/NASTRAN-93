      BLOCK DATA SMA2BD
CSMA2BD
C
      INTEGER         CLSRW,  CLSNRW, EOR,   OUTRW
      COMMON /SMA2IO/ IFCSTM, IFMPT,  IFDIT, IDUM1, IFECPT, IGECPT,
     1                IFGPCT, IGGPCT, IDUM2, IDUM3, IFMGG,  IGMGG,
     2                IFBGG,  IGBGG,  IDUM4, IDUM5, INRW,   OUTRW,
     3                CLSNRW, CLSRW,  NEOR,  EOR, MCBMGG(7),MCBBGG(7)
C
C     SMA2 VARIABLE CORE BOOKKEEPING PARAMETERS
C
      COMMON /SMA2BK/ ICSTM,  NCSTM,  IGPCT, NGPCT, IPOINT, NPOINT,
     1                I6X6M,  N6X6M,  I6X6B, N6X6B
C
C     SMA2 PROGRAM CONTROL PARAMETERS
C
      COMMON /SMA2CL/ IOPT4,  BGGIND, NPVT,  LEFT,  FROWIC, LROWIC,
     1                NROWSC, TNROWS, JMAX,  NLINKS,LINK(10),NOGO,
     2                DUMMY(202)
C
C     ECPT COMMON BLOCK
C
      COMMON /SMA2ET/ ECPT(200)
C
      DATA    NLINKS/ 10 /                                                   
      DATA    NOGO  / 0  /                                                     
      DATA    IFCSTM, IFMPT,IFECPT,IFGPCT,IFDIT  / 101,102,103,104,105 / 
      DATA    IFMGG , IFBGG       /     201,202  / 
      DATA    INRW  , CLSRW,CLSNRW,EOR,NEOR,OUTRW/ 0,1,2,1,0,1 /    
      END
